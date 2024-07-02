
```go
func CreateOrUpdate(ctx context.Context, c client.Client, obj client.Object, f MutateFn) (OperationResult, error)
```

# Process for Creation

![Creation](./images/Creation.svg)


```go
if err := c.Get(ctx, key, obj); err != nil {
    if !apierrors.IsNotFound(err) {
        return OperationResultNone, err
    }
    if err := mutate(f, key, obj); err != nil {
        return OperationResultNone, err
    }
    if err := c.Create(ctx, obj); err != nil {
        return OperationResultNone, err
    }
    return OperationResultCreated, nil
}
```

```go
func() error {
    return builder.Update(resource)
}
```
`builder` is an interface `ResourceBuilder`.
```go
type ResourceBuilder interface {
	Build() (client.Object, error)
	Update(client.Object) error
	UpdateMayRequireStsRecreate() bool
}
```


For example, `Update` for `StatefulSetBuilder`
```go
func (builder *StatefulSetBuilder) Update(object client.Object) error {
	sts := object.(*appsv1.StatefulSet)

	//Replicas
	sts.Spec.Replicas = builder.Instance.Spec.Replicas

	//Update Strategy
	sts.Spec.UpdateStrategy = appsv1.StatefulSetUpdateStrategy{
		RollingUpdate: &appsv1.RollingUpdateStatefulSetStrategy{
			Partition: ptr.To(int32(0)),
		},
		Type: appsv1.RollingUpdateStatefulSetStrategyType,
	}

	//Annotations
	sts.Annotations = metadata.ReconcileAndFilterAnnotations(sts.Annotations, builder.Instance.Annotations)

	//Labels
	sts.Labels = metadata.GetLabels(builder.Instance.Name, builder.Instance.Labels)

	// PVC storage capacity
	updatePersistenceStorageCapacity(&sts.Spec.VolumeClaimTemplates, builder.Instance.Spec.Persistence.Storage)

	// pod template
	sts.Spec.Template = builder.podTemplateSpec(sts.Spec.Template.Annotations)

	if !sts.Spec.Template.Spec.Containers[0].Resources.Limits.Memory().Equal(*sts.Spec.Template.Spec.Containers[0].Resources.Requests.Memory()) {
		logger := ctrl.Log.WithName("statefulset").WithName("RabbitmqCluster")
		logger.Info(fmt.Sprintf("Warning: Memory request and limit are not equal for \"%s\". It is recommended that they be set to the same value", sts.GetName()))
	}

	if builder.Instance.Spec.Override.StatefulSet != nil {
		if err := applyStsOverride(builder.Instance, builder.Scheme, sts, builder.Instance.Spec.Override.StatefulSet); err != nil {
			return fmt.Errorf("failed applying StatefulSet override: %w", err)
		}
	}

	if err := controllerutil.SetControllerReference(builder.Instance, sts, builder.Scheme); err != nil {
		return fmt.Errorf("failed setting controller reference: %w", err)
	}
	return nil
}
```

```go
func (builder *StatefulSetBuilder) Build() (client.Object, error) {
	// PVC, ServiceName & Selector: can't be updated without deleting the statefulset
	pvc, err := persistentVolumeClaim(builder.Instance, builder.Scheme)
	if err != nil {
		return nil, err
	}

	sts := &appsv1.StatefulSet{
		ObjectMeta: metav1.ObjectMeta{
			Name:      builder.Instance.ChildResourceName(stsSuffix),
			Namespace: builder.Instance.Namespace,
		},
		Spec: appsv1.StatefulSetSpec{
			ServiceName: builder.Instance.ChildResourceName(headlessServiceSuffix),
			Selector: &metav1.LabelSelector{
				MatchLabels: metadata.LabelSelector(builder.Instance.Name),
			},
			VolumeClaimTemplates: pvc,
			PodManagementPolicy:  appsv1.ParallelPodManagement,
		},
	}

	// StatefulSet Override
	// override is applied to PVC, ServiceName & Selector
	// other fields are handled in Update()
	overrideSts := builder.Instance.Spec.Override.StatefulSet
	if overrideSts != nil && overrideSts.Spec != nil {
		if overrideSts.Spec.Selector != nil {
			sts.Spec.Selector = overrideSts.Spec.Selector
		}

		if overrideSts.Spec.ServiceName != "" {
			sts.Spec.ServiceName = overrideSts.Spec.ServiceName
		}

	}

	return sts, nil
}
```


# Why we need both `Build` and `Update` for one resource

A simple example from `Service` and `Role`

```go
func (builder *ServiceBuilder) Build() (client.Object, error) {
	return &corev1.Service{
		ObjectMeta: metav1.ObjectMeta{
			Name:      builder.Instance.ChildResourceName(ServiceSuffix),
			Namespace: builder.Instance.Namespace,
		},
	}, nil
}

func (builder *ServiceBuilder) Update(object client.Object) error {
	service := object.(*corev1.Service)
	builder.setAnnotations(service)
	service.Labels = metadata.GetLabels(builder.Instance.Name, builder.Instance.Labels)
	service.Spec.Type = builder.Instance.Spec.Service.Type
	service.Spec.Selector = metadata.LabelSelector(builder.Instance.Name)
	service.Spec.IPFamilyPolicy = builder.Instance.Spec.Service.IPFamilyPolicy

	service.Spec.Ports = builder.updatePorts(service.Spec.Ports)

	if builder.Instance.Spec.Service.Type == "ClusterIP" || builder.Instance.Spec.Service.Type == "" {
		for i := range service.Spec.Ports {
			service.Spec.Ports[i].NodePort = int32(0)
		}
	}

	if builder.Instance.Spec.Override.Service != nil {
		if err := applySvcOverride(service, builder.Instance.Spec.Override.Service); err != nil {
			return fmt.Errorf("failed applying Service override: %w", err)
		}
	}

	if err := controllerutil.SetControllerReference(builder.Instance, service, builder.Scheme); err != nil {
		return fmt.Errorf("failed setting controller reference: %w", err)
	}

	return nil
}
```

```go
func (builder *RoleBuilder) Build() (client.Object, error) {
	return &rbacv1.Role{
		ObjectMeta: metav1.ObjectMeta{
			Namespace: builder.Instance.Namespace,
			Name:      builder.Instance.ChildResourceName(roleName),
		},
	}, nil
}

func (builder *RoleBuilder) Update(object client.Object) error {
	role := object.(*rbacv1.Role)
	role.Labels = metadata.GetLabels(builder.Instance.Name, builder.Instance.Labels)
	role.Annotations = metadata.ReconcileAndFilterAnnotations(role.GetAnnotations(), builder.Instance.Annotations)
	role.Rules = []rbacv1.PolicyRule{
		{
			APIGroups: []string{""},
			Resources: []string{"endpoints"},
			Verbs:     []string{"get"},
		},
		{
			APIGroups: []string{""},
			Resources: []string{"events"},
			Verbs:     []string{"create"},
		},
	}

	if err := controllerutil.SetControllerReference(builder.Instance, role, builder.Scheme); err != nil {
		return fmt.Errorf("failed setting controller reference: %w", err)
	}
	return nil
}
```

`Build` is responsible for configuring fields that are immutable after creation.

`Update` is responsible for configuring fields that are mutable after creation.


# Update

![Update](./images/Update.svg)

```go
existing := obj.DeepCopyObject()
if err := mutate(f, key, obj); err != nil {
    return OperationResultNone, err
}

if equality.Semantic.DeepEqual(existing, obj) {
    return OperationResultNone, nil
}

if err := c.Update(ctx, obj); err != nil {
    return OperationResultNone, err
}
return OperationResultUpdated, nil
```


# To-do List

- Comparation for the deployment and services before Update.