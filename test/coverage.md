# SOP For test coverage decreasing

- Check coverage detail
  
```bash 
cd {dir}
go test -coverprofile=coverage.out
```

- Read the coverage file

```bash
# Coverage information structure:
github.com/pivotal/gp-stream-server/server/loader/kafkaload/job.go:1573.70,1575.19 2 0
# {file_name}:{start_line}.{offset},{end_line}.{offset} { number_of_instructions} {hit_count}
```

- Select a code segment with a 0 hit, and add tests.