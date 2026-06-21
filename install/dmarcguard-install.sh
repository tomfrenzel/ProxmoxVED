#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Tom Frenzel (tomfrenzel)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/dmarcguardhq/dmarcguard

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

fetch_and_deploy_gh_release "dmarcguard" "dmarcguardhq/dmarcguard" "prebuild" "latest" "/opt/dmarcguard" "dmarcguard_linux_amd64.tar.gz"

msg_info "Generating initial configuration"
cd /opt/dmarcguard
./parse-dmarc --gen-config
msg_ok "Generated initial configuration"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/dmarcguard.service
[Unit]
Description=DMARC Guard
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/dmarcguard
ExecStart=/opt/dmarcguard/parse-dmarc
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q dmarcguard
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
