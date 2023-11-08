- Start a cluster
    ```bash
    minikube start --nodes 2 --cni calico
    ```
- Build a docker image
    ```bash
    docker build -t simple_http_server .
    ```
- Load docker image on cluster
    ```bash
    minikube image load simple_http_server:latest
    ```
- Deploy a image
    ```bash
    kubectl apply -f deploy.yml
    ```
- Deploy a service
    ```bash
    kubectl apply -f service.yml
    ```
- Start the service
    ```bash
    minikube service my-app-service
    ```