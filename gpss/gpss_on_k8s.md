- Pipeline job defination for concurse.
  - pull gpss and gpss-operator
  - build gpss-operator
  - package gpss
  - build gpss-operator 
  - How to set 
- Pipeline runnning environment
  - docker install (baking? run_task.sh?)
    - make gpss installation image for k8s
  - kubectl install (baking? run_task.sh?)
    - operate k8s cluster
  - User permission for pipeline.
- Script for pipeline
  - download gpss-operator code repository (run_task.sh)
  - build binary file for gpss-operator (run_task.sh)
  - install CRD on k8s (run_task.sh)
  - add IP clusters of k8s in gpdb pg_hb.
  - add binnary file for installation package (cmake?)

how to make gcr.io/data-gpdb-dev2/gp-extensions


# Problem
- docker can not run docker 
  - solution 1 : change our docker running config, docker in docker
- GCP_SVC_ACCT_KEY how to get it ?