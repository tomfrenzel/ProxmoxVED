#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Tom Frenzel (tomfrenzel)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/dmarcguardhq/parse-dmarc

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

fetch_and_deploy_gh_release "parse-dmarc" "dmarcguardhq/parse-dmarc" "prebuild" "latest" "/opt/parse-dmarc" "parse-dmarc_linux_amd64.tar.gz"

msg_info "Generating initial configuration"
cd /opt/parse-dmarc
./parse-dmarc --gen-config
msg_ok "Generated initial configuration"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/parse-dmarc.service
[Unit]
Description=Parse-DMARC
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/parse-dmarc
ExecStart=/opt/parse-dmarc/parse-dmarc
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q parse-dmarc
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
