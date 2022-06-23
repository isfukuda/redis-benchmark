#!/bin/sh
docker run -it --net=docker_default  --link redis-test:redis --rm redis redis-benchmark -h 10.0.0.3 -p 6379 -r 1000 -n 2000 -t get,set,lpush,lpop -P 16 -q
