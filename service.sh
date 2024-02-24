# auto-start service, it likes `docker --restart unless-stopped`
podman generate systemd --name my-jenkins --restart-policy=always > /etc/systemd/system/my-jenkins.service

systemctl daemon-reload
systemctl enable my-jenkins
systemctl start my-jenkins

