#!/bin/sh

set -e

cd ../app
go build -o ../dist/bootstrap

cd ../infra
terraform init
terraform plan
terraform apply -auto-approve