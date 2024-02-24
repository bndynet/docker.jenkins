podman rm -f -v my-jenkins || true
podman image rm bndynet/jenkins || true
podman build -t bndynet/jenkins .
podman run --name my-jenkins -p 8080:8080 -p 50000:50000  \
  -d \
  bndynet/jenkins

open http://127.0.0.1:8080