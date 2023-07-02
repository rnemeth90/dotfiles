#!/bin/bash
set -e

kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t\t"}{.metadata.labels.kubernetes\.azure\.com\/node-image-version}{"\n"}{end}'
