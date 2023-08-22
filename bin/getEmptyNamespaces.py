#!/usr/bin/env python

import subprocess
import sys

def get_output(cmd):
    try:
        output = subprocess.check_output(cmd, shell=True).decode('utf-8').strip()
        return output
    except subprocess.CalledProcessError:
        return ""

def remove_namespace_finalizers(namespace):
    cmd = (
        'kubectl get namespace {} -o json '
        '| tr -d "\\n" '
        '| sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" '
        '| kubectl replace --raw /api/v1/namespaces/{}/finalize -f - > /dev/null 2>&1'
    ).format(namespace, namespace)
    subprocess.call(cmd, shell=True)

def remove_namespace(namespace):
    cmd = (
        'kubectl delete namespace {} --force &'.format(namespace)
    )
    subprocess.call(cmd, shell=True)

def get_namespace_status(namespace):
    cmd = "kubectl get namespace {} -o=jsonpath='{{.status.phase}}'".format(namespace)
    print("Namespace: {}".format(namespace))
    print("Executing cmd: {}".format(cmd))
    try:
        status = subprocess.check_output(cmd, shell=True).decode('utf-8').strip()
        return status
    except Exception as e:  # Explicitly catch the exception as 'e'
        print("Error: {}".format(str(e)))
        return None

def prompt_delete(namespace):
    if DELETE_FLAG:
        decision = raw_input("Do you want to remove finalizers and delete namespace {}? [y/N]: ".format(namespace))
        if decision.lower() == "y":
            namespace_status = get_namespace_status(namespace)
            print("Status: {}".format(namespace_status))
            print(namespace_status)
            if namespace_status == "Terminating":
                remove_namespace_finalizers(namespace)
                print("Finalizers for namespace {} removed.".format(namespace))
            else:
                remove_namespace(namespace)
                print("Namespace {} removed.".format(namespace))
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

    # If no pods in the namespace or all pods in the namespace are pending
    if total_pod_count == 0 or pending_pod_count > 0:
        print("Namespace {} is empty or only has pending pods".format(namespace))
        if DELETE_FLAG:
            prompt_delete(namespace)

