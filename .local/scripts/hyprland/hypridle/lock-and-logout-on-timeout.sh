#!/usr/bin/env bash

loginctl lock-session &
hyprctl dispatch dpms off
