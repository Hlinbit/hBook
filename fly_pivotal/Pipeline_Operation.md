# Login a url

```
fly -t <tag> login -n <team_name> -c <url>
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

# run a pipeline

```
fly -t <tag> set-pipeline -p <pipeline_name> -c <config_file>  -v gpss-git-branch=<github_branch> -v github-access-token=<github_token>
```