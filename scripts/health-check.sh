#!/usr/bin/env bash
# InfraLab — read-only local health check.
# Checks Linux services and the local HTTPS endpoint.
# Requires infra.test to resolve locally and ~/infra.test.crt to exist.
# Learning tool; not a production monitoring system.

check_service() {
    local service="$1"
    local status
    status=$(systemctl is-active "$service")

    if [ "$status" = "active" ]; then
        echo "$service: OK"
        return 0
    else
        echo "$service: ALERT"
        return 1
    fi
}

main() {
    local overall=0
    local service
    local http

    http=$(curl -fsS --cacert "$HOME/infra.test.crt" https://infra.test > /dev/null; echo $?)

    for service in nginx ssh; do
        if ! check_service "$service"; then
            overall=1
        fi
    done

    if [ "$http" -ne 0 ]; then
        echo "HTTPS: ALERT (curl exit: $http)"
        overall=1
    else
        echo "HTTPS: OK"
    fi

    if [ "$overall" -eq 0 ]; then
        echo "Final: OK"
    else
        echo "Final: ALERT"
    fi

    return "$overall"
}

main
