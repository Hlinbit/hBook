# Delete built image

```bash
docker image rm [image_id]
docker image prune -a
```

# Copy file from local to container

```bash
docker cp [local_path] [image_id]:[dest_path]
```

# Pause the running container

```bash
docker ps -q | xargs docker pause
```

# Stop a running container

```bash
docker stop <name>
```

# Stop all running containers

```bash
docker stop $(docker ps -aq)
```

# Show all running docker container

```bash
docker ps
```

```bash
sudo usermod -aG docker $USER
```