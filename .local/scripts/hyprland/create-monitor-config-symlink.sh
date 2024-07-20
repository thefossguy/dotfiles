#!/usr/bin/env bash

set -e

if [[ ! -h "${HOME}/.config/hypr/host-monitor.conf" ]]; then
    pushd "${HOME}/.config/hypr"
    host_monitor_config="host-monitor-configs/$(hostname).conf"
    if [[ ! -f "${host_monitor_config}" ]]; then
        host_monitor_config="host-monitor-configs/generic.conf"
    fi
    ln -s "${host_monitor_config}" host-monitor.conf
    popd
fi
