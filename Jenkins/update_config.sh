#!/bin/bash

# Check if all required arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <vpc_id> <public_subnet_id> <private_subnet_1_id> <private_subnet_2_id> <efs_id>"
    exit 1
fi

# Assign arguments to variables
vpc_id=$1
public_subnet_id=$2
private_subnet_1_id=$3
private_subnet_2_id=$4
efs_id=$5

# Update cluster.yaml using yq
yq e -i ".vpc.id = \"${vpc_id}\"" cluster.yaml
yq e -i ".vpc.subnets.public.\"eu-west-3a\"[0] = \"${public_subnet_id}\"" cluster.yaml
yq e -i ".vpc.subnets.private.\"eu-west-3a\"[0] = \"${private_subnet_1_id}\"" cluster.yaml
yq e -i ".vpc.subnets.private.\"eu-west-3b\"[0] = \"${private_subnet_2_id}\"" cluster.yaml

# Update values.yaml for EFS
yq e -i ".storage.efs.fileSystemId = \"${efs_id}\"" values.yaml
