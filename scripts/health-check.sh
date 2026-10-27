#!/usr/bin/env bash
check(){
        local service="$1"
        local failed=0
        local healthy=0
        local total=0
        local http=$(curl -fsS --cacert /home/electrou/infra.test.crt https://infra.test > /dev/null;echo $?)
        local html=$(curl -fsS --cacert /home/electrou/infra.test.crt https://infra.test)
        if echo "$html" | grep -qF "InfraLab - Web Server"; then
        echo "HTML CONTENT: OK"; ((healthy++)); ((total++))
        else
        echo "HTML CONTENT: ALERT!"; ((failed++)); ((total++))
        fi
        if [ "$http" -ne 0 ];then
        ((failed++)); echo "http : ALERT!"; ((total++))
        else
        ((healthy++)); echo "http : OK"; ((total++))
        fi
        for service in nginx ssh cron; do
        local status=$(systemctl is-active "$service")
                ((total++))
                if [ "$status" = "active" ];then
                echo "$service : OK" && ((healthy++))
                else
                echo "$service : ALERT!" && ((failed++))
                fi
        done
        echo "total cheked : $total"
        echo "Healthy : $healthy"
        echo "Failed : $failed"
        if [ "$failed" -ne 0 ];then
        echo "SYSTEM DEGRADED!"
        return 1
        else
        echo "SYSTEM HEALTHY"
        return 0
        fi
}
check
