

wait job failed, err: rpc error: code = Unavailable desc = closing transport due to: connection error: desc = "error reading from server: EOF", received prior goaway: code: NO_ERROR, debug data: "graceful_stop"


20240515 08:29:28 2823177 [INFO] start job: end2end_cluster_kafka_simple failed, code: Unavailable, message: connection error: desc = "transport: Error while dialing: dial tcp 34.30.241.40:5000: i/o timeout"


探针机制可以没有ready，pod就是没有ready，同时，service也不会转发流量给pod。initialDelaySeconds决定了第一次触发的时间，只要没触发，pod就没有ready

deployment对于

docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
docker.io/library/nginx@sha256:a484819eb60211f5299034ac80f6a681b06f89e65866ce91f356ed7c72af059c
