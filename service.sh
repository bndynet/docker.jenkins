# auto-start service on boot (docker equivalent of `podman generate systemd`)
# NOTE: the container must already exist (created by rebuild.sh)
cat > /etc/systemd/system/my-jenkins.service <<'EOF'
[Unit]
Description=Jenkins Container
Requires=docker.service
After=docker.service network-online.target

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a my-jenkins
ExecStop=/usr/bin/docker stop -t 10 my-jenkins

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable my-jenkins
systemctl start my-jenkins

