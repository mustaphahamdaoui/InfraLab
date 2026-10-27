#!/usr/bin/env bash

check() {
    local failed=0
    local healthy=0
    local total=0
    local service
    local status
    local html
        local curl_code
    # HTTPS + HTML
    if html=$(curl -fsS --max-time 10 --cacert /home/electrou/infra.test.crt https://infra.test); then curl_code=$?
        echo "HTTPS: OK (curl code: $curl_code)"
        ((healthy+=1))
        ((total+=1))

        if echo "$html" | grep -qF "InfraLab - Web Server"; then
            echo "HTML CONTENT: OK"
            ((healthy+=1))
        else
            echo "HTML CONTENT: ALERT!"
            ((failed+=1))
        fi
        ((total+=1))

    else
        curl_code=$?
        echo "HTTPS: ALERT! (curl code: $curl_code)"
        ((failed+=1))
        ((total+=1))
        echo "HTML CONTENT: NOT CHECKED"
    fi

    # Linux services
    for service in nginx ssh cron; do
        status=$(systemctl is-active "$service")
        ((total+=1))

        if [ "$status" = "active" ]; then
            echo "$service : OK"
            ((healthy+=1))
        else
            echo "$service : ALERT!"
            ((failed+=1))
        fi
    done

    # Final report
    echo "total checked : $total"
    echo "Healthy : $healthy"
    echo "Failed : $failed"

    if [ "$failed" -ne 0 ]; then
        echo "SYSTEM DEGRADED!"
        return 1
    else
        echo "SYSTEM HEALTHY"
        return 0
    fi
}

check
