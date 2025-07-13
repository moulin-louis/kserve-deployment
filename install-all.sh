#!/bin/bash

set -e  # Exit on any error

# Function to run terragrunt with error handling
run_terragrunt() {
    local dir=$1
    local message=$2
    
    echo "Deploying $message..."
    if terragrunt apply --working-dir="$dir" --non-interactive --auto-approve; then
        echo "✓ $message"
    else
        echo "✗ Failed to deploy $message"
        exit 1
    fi
}

# Deploy components in sequence
run_terragrunt "./terragrunt/k8s-cluster/" "Kubernetes Cluster"
run_terragrunt "./terragrunt/istio/" "Istio"
run_terragrunt "./terragrunt/cert-manager/" "Cert Manager"
run_terragrunt "./terragrunt/knative-operator/" "Knative Operator"
run_terragrunt "./terragrunt/knative-serving/" "Knative Serving"
run_terragrunt "./terragrunt/kserve/" "KServe"

echo "🎉 All components deployed successfully!"
