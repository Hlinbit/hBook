# Run rabbitmq

```bash
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672  -p 5552:5552 --hostname localhost rabbitmq:3.11-management
```

# Run rabbitmq

```bash
docker exec -it rabbitmq bash
```

# Install Softwares

- install netstat 
```bash
apt install net-tools
```

- install python
```bash 
sudo apt install python3-pip
sudo yum install python-pip
```

# Using stream

```bash 
rabbitmq-plugins enable rabbitmq_stream
rabbitmq-server -detached
rabbitmqctl await_startup

rabbitmqctl add_vhost vhost_gpss
rabbitmqctl add_user gpadmin changeme
rabbitmqctl set_permissions -p vhost_gpss gpadmin ".*" ".*" ".*"
rabbitmqctl set_permissions -p / gpadmin ".*" ".*" ".*"
rabbitmqctl set_user_tags gpadmin administrator
```
368e32cd47c13f74de5d0c07dfb3551ca253689e