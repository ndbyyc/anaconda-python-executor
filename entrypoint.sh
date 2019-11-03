#!/bin/bash

# Echo environment variables from docker to /etc/environment for cron jobs to use
printenv | grep -v "no_proxy" >> /etc/environment

exec "$@"
