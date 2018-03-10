docker rm -f -v my-jenkins || true
docker image remove bndynet/jenkins || true
docker build -t bndynet/jenkins .
docker run --name my-jenkins -p 8080:8080 -p 50000:50000  \
  -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --restart unless-stopped \
  --user root \
  bndynet/jenkins

open http://127.0.0.1:8080