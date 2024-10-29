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

# Update values.yaml using sed
sed -i "s|infrastructure:\n  vpc:\n    id:.*|infrastructure:\n  vpc:\n    id: ${vpc_id}|g" values.yaml
sed -i "s|    public:.*|    public: ${public_subnet_id}|g" values.yaml
sed -i "s|    private:\n      -.*\n      -.*|    private:\n      - ${private_subnet_1_id}\n      - ${private_subnet_2_id}|g" values.yaml
sed -i "s|    fileSystemId:.*|    fileSystemId: ${efs_id}|g" values.yaml