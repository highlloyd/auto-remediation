#!/bin/bash
cd prometheus/
terraform init
terraform apply -auto-approve
cd ..
cd stackstorm/
terraform init 
terraform apply -auto-approve