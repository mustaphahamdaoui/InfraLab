#!/usr/bin/env bash
# InfraLab Week 03 — small, read-only local health check.
# Publication copy reconstructed from the tested learning script.
# Uses the local certificate and hostname mapping configured in this lab.

status=$(systemctl is-active nginx)
curl_exit_code=$(curl -fsS --cacert "$HOME/infra.test.crt" https://infra.test > /dev/null; echo $?)

if [ "$status" = "active" ] && [ "$curl_exit_code" = "0" ]; then
    echo "OK"
    exit 0
else
    echo "Alert!"
    # Basic diagnostic only; this grep is not an exact port matcher.
    status_ports=$(ss -lntp | grep -E '80|443')
    echo "$status_ports"
    exit 1
fi
