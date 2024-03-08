#! /usr/bin/env bash

set -euo pipefail

kubectl --namespace=website \
  wait --for=condition=ready pod \
  -l app=website
