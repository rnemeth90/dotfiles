#!/bin/bash

ACR_NAME="prod02registry01acr"
UNPARSE_IMAGES=$(kubectl get deployments --all-namespaces -o jsonpath="{.items[*].spec.template.spec.containers[*].image}")
IMAGES=$(echo "$UNPARSE_IMAGES" | tr ' ' '\n' | grep -i "prod02registry01acr.azurecr.io" | sort -u)

while IFS= read -r IMAGE; do
    REPO=$(echo "$IMAGE" | cut -d'/' -f2- | cut -d':' -f1)
    TAG=$(echo "$IMAGE" | cut -d':' -f2)
    EXISTS=$(az acr repository show-tags --name "$ACR_NAME" --repository "$REPO" --query "[?contains(@, '$TAG')]" --output tsv)

    if [ -n "$EXISTS" ]; then
        echo "[Y] Image $IMAGE exists in ACR."
    else
        echo "[N] Image $IMAGE does NOT exist in ACR."
    fi
done <<< "$IMAGES"
