#!/usr/bin/env python

from kubernetes import client, config
import argparse

def check_best_practices(namespace):
    try:
        config.load_kube_config()
    except:
        print("[ERR] Cannot load kube config. Ensure the file exists and is in your $PATH")

    v1 = client.CoreV1Api()

    pod_list = v1.list_namespaced_pod(namespace)

    for pod in pod_list.items:
        print("\nChecking pod {}...".format(pod.metadata.name))

        for container in pod.spec.containers:
            # Check resource limits and requests
            if not container.resources.limits or not container.resources.requests:
                print("- [WARNING] Container '{}' does not have resource limits and/or requests set.".format(container.name))

            # Check liveness and readiness probes
            if not container.liveness_probe:
                print("- [WARNING] Container '{}' does not have a liveness probe defined.".format(container.name))
            if not container.readiness_probe:
                print("- [WARNING] Container '{}' does not have a readiness probe defined.".format(container.name))

            # Check security context and running as root
            if not container.security_context:
                print("- [WARNING] Container '{}' does not have a security context defined.".format(container.name))
            elif container.security_context and container.security_context.run_as_user == 0:
                print("- [WARNING] Container '{}' runs as root.".format(container.name))

            # Check image pull policy
            if container.image_pull_policy == "Always":
                print("- [INFO] Container '{}' has image pull policy set to Always.".format(container.name))
            if ':latest' in container.image:
                print("- [WARNING] Container '{}' uses the latest tag for its image.".format(container.name))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Check Kubernetes best practices for a given namespace.')
    parser.add_argument('namespace', type=str, help='The namespace to check')
    args = parser.parse_args()

    check_best_practices(args.namespace)

