#!/usr/bin/env python

import subprocess
import sys

def get_output(cmd):
    try:
        return subprocess.check_output(cmd, shell=True).decode('utf-8').strip()
    except:
        return ""

def prompt_delete(namespace):
    if DELETE_FLAG:
        decision = input("Do you want to delete namespace {}? [y/N]: ".format(namespace))
        if decision.lower() == "y":
            subprocess.check_output(["kubectl", "delete", "namespace", namespace])
            print("Namespace {} deleted.".format(namespace))
        else:
            print("Skipped deletion for namespace {}.".format(namespace))

# Check if --delete argument is passed
DELETE_FLAG = "--delete" in sys.argv

# Get all namespaces
namespaces = get_output("kubectl get namespaces -o=jsonpath='{.items[*].metadata.name}'").split()

for namespace in namespaces:
    # Get the number of pods in the current namespace
    total_pod_count = int(get_output("kubectl get pods --namespace={} --no-headers 2>/dev/null | wc -l".format(namespace)))
    
    # Get the number of pods in a 'Pending' state in the current namespace
    pending_output = get_output("kubectl get pods --namespace={} --no-headers 2>/dev/null | grep -c Pending".format(namespace))
    pending_pod_count = int(pending_output) if pending_output else 0

    # If no pods in the namespace, display and prompt for deletion if --delete flag is set
    if total_pod_count == 0:
        print("{} is empty.".format(namespace))
        prompt_delete(namespace)
    # If all pods in the namespace are pending, display and prompt for deletion if --delete flag is set
    elif total_pod_count == pending_pod_count:
        print("{} only has pods in a Pending state.".format(namespace))
        prompt_delete(namespace)

