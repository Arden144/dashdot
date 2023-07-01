#!/bin/sh

(trap 'kill 0' SIGINT; envoy -c envoy.yaml & cargo run)
