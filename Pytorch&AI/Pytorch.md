# Create a tensor

```python
import torch

torch.empty(4,4)
torch.zero(4,4)
torch.ones(4,4)
torch.rand(4,4) # Value between 0 and 1 
torch.tensor([2,3,4]) # Create tensor from array

ensor = torch.arange(-10, 11, 0.5) # Get a list from -10 to 10, with an interval of 0.5 between each element.
```

# Data type of a tensor
```python
x = torch.zero(4, 4, dtype=torch.float16)
print(x.dtype)
# default value: torch.float32
```

# Transform numpy from tensor and from tensor to numpy

```python
# tensor 2 numpy
# x and y share the same memory
x = torch.rand(4, 4, dtype=torch.float16)
y = x.numpy()

# numpy 2 tensor
x = numpy.ones(5)
# share the same memory
a = torch.from_numpy(x)
# create a copy
b = torch.tensor(x)
```

# Index the elements of tensor

```python
x = torch.rand(5, 3)
first_row = x[0, :]
second_col = x[:, 1]
first_ele = x[0, 0] # is is also a tensor

# Get the value, if there is only one element
first_val = first_ele.item()
```

# Reshape the tensor

```python
x = torch.rand(4, 4)
y = x.view(2, 8) # Shape ([2, 8]) 
z = x.view(16) # Shape ([16]) 
```

# Auto gradient calculation

## Caculate gradient for tensor

Pytorch has built-in product for computing the vector-Jacobian. The autograd package provides automatic differentiation for all operations on tensor. It computes partial derivates while applying the chain rule.

```python
# When requires_grad = True, Pytorch tracks all operations on the tensor.
x = torch.rand(3, requires_grad=True)
y = x + 2

print(x)
print(y) # tensor([2.5648, 2.3240, 2.3328], grad_fn=<AddBackward0>)
print(y.grad_fn) # <AddBackward0 object at 0x100b7b8b0>

z = y * y * 3 # z = (x + 2) * (x + 2) * 3
print(z) # tensor([19.7346, 16.2031, 16.3264], grad_fn=<MulBackward0>)
z = z.mean() # z = ((x + 2) * (x + 2) * 3).mean()
print(z) # tensor(17.4214, grad_fn=<MeanBackward0>)

# When the calculation ends, we call 'backward()' to calculate all the gradient in the process.
# All the gradients accumulate in the 'grad' attribute.
z.backward()
print(x.grad) # tensor([5.1296, 4.6480, 4.6657])

# We should clear the accumulated gradients before the next call of 'backward'
x.grad = torch.zeros(3)
```
## Stop tracking a tensor

It is useful to evaluate the effect after one round training.

```python
# 1
x.detach()
# 2
x.requires_grad_(False)
# 3
with torch.no_grad()
```


