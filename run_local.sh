#/bin/bash

# run local as powerdns-test with sqlite

# sometimes clearing cache is needed
#docker system prune -a -f

docker rm -f powerdns-test
docker rmi -f powerdns-test


docker build -t powerdns-test -f Dockerfile .
docker run --name powerdns-test -p 53:5053 -p 53:5053/udp -e AUTOCONF=sqlite docker.io/library/powerdns-test --cache-ttl=120 --allow-axfr-ips=127.0.0.1,123.1.2.3
