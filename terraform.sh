#!/usr/bin/env bash

### Usage: ./terraform <ENV> <regular terraform parameters>

ENV=$1
case "$ENV" in
  dev|integration|stage|production)
    ;;
  *)
    echo "No env specified."
    exit -1
    ;;
esac

PARAMETERS=("$@")

terraform ${PARAMETERS[@]:1} -state=$ENV.tfstate -var-file=$ENV.tfvars
