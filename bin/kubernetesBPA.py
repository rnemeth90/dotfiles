#!/usr/bin/env python

from kubernetes import client, config
import argparse

def check_pods(namespace):
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

from kubernetes import client, config
import argparse

def check_services(namespace):
    v1 = client.CoreV1Api()
    services = v1.list_namespaced_service(namespace)
    for svc in services.items:
        if not svc.spec.selector:
            print("- [WARNING] Service '{}' does not use a selector.".format(svc.metadata.name))

def check_ingresses(namespace):
    ext_v1 = client.ExtensionsV1beta1Api()
    ingresses = ext_v1.list_namespaced_ingress(namespace)
    for ing in ingresses.items:
        for rule in ing.spec.rules:
            if not rule.host:
                print("- [WARNING] Ingress rule in '{}' does not specify a host.".format(ing.metadata.name))
            for tls in ing.spec.tls:
                if not tls.hosts:
                    print("- [WARNING] Ingress '{}' TLS configuration does not specify hosts.".format(ing.metadata.name))

def check_roles(namespace):
    rbac_v1 = client.RbacAuthorizationV1Api()
    roles = rbac_v1.list_namespaced_role(namespace)
    for role in roles.items:
        for rule in role.rules:
            if '*' in rule.resources or '*' in rule.verbs:
                print("- [WARNING] Role '{}' has overly broad permissions.".format(role.metadata.name))

def check_cluster_roles():
    rbac_v1 = client.RbacAuthorizationV1Api()
    cluster_roles = rbac_v1.list_cluster_role()
    for role in cluster_roles.items:
        for rule in role.rules:
            if '*' in rule.resources or '*' in rule.verbs:
                print("- [WARNING] ClusterRole '{}' has overly broad permissions.".format(role.metadata.name))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Check Kubernetes best practices.')
    parser.add_argument('namespace', type=str, help='The namespace to check')
    parser.add_argument('--services', action='store_true', help='Check best practices for services')
    parser.add_argument('--ingresses', action='store_true', help='Check best practices for ingresses')
    parser.add_argument('--roles', action='store_true', help='Check best practices for roles in the namespace')
    parser.add_argument('--cluster-roles', action='store_true', help='Check best practices for cluster roles')
    
    args = parser.parse_args()

    if args.services:
        check_services(args.namespace)
    if args.ingresses:
        check_ingresses(args.namespace)
    if args.roles:
        check_roles(args.namespace)
    if args.cluster_roles:
        check_cluster_roles()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Check Kubernetes best practices.')
    parser.add_argument('namespace', type=str, help='The namespace to check')
    parser.add_argument('--pods', action='store_true', help='Check best practices for pods')
    parser.add_argument('--services', action='store_true', help='Check best practices for services')
    parser.add_argument('--ingresses', action='store_true', help='Check best practices for ingresses')
    parser.add_argument('--roles', action='store_true', help='Check best practices for roles in the namespace')
    parser.add_argument('--cluster-roles', action='store_true', help='Check best practices for cluster roles')
    
    args = parser.parse_args()

    if args.pods:
        check_pods(args.namespace)
    if args.services:
        check_services(args.namespace)
    if args.ingresses:
        check_ingresses(args.namespace)
    if args.roles:
        check_roles(args.namespace)
    if args.cluster_roles:
        check_cluster_roles()

