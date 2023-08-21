# Login a url

```
fly -t <tag> login -c <url>
```

# Delete a pipeline

```
fly -t <tag> destroy-pipeline -p <pipeline_name>
```

# Get a pipeline config from remote tag

```
fly -t <tag> gp -p <pipeline_name>
```

# login a concourse container

```
fly -t <tag> hijack -u <url>
```