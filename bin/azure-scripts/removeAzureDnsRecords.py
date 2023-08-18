#!/usr/bin/env python

import subprocess
import json
import argparse
import datetime

def is_az_installed():
    """verify the az cli tool is installed"""
    try:
        subprocess.check_output(["az","--version"], text=True)
        return True
    except subprocess.CalledProcessError:
        return False
    except FileNotFoundError:
        return False

def is_valid_parameter(value, param_name):
    """verify our parameters are valid"""
    if not value or value.strip() == "":
        print("[ERROR] Invalid value for {}.".format_map(param_name))
        return False
    return True

def get_records(resource_group, dns_zone_name, prefix, exclude_pattern):
    """Return a list of DNS records"""
    dns_records = json.loads(subprocess.check_output(['az', 'network', 'dns', 'record-set', 'list', '-g', resource_group, '-z', dns_zone_name]))
    records = []

    for dns_record in dns_records:
        if dns_record['name'].startswith(prefix) and (not exclude_pattern or exclude_pattern not in dns_record['name']):
            records.append(dns_record)
    return records

def backup_dns_records(dns_records):
    """Backup all the DNS records to a JSON file."""
    timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    dns_zone_name = dns_records[0]['fqdn'].split('.', 1)[1]
    backup_file_name = "backup_{}_{}.json".format(dns_zone_name, timestamp)

    with open(backup_file_name, 'w') as backup_file:
        json.dump(dns_records, backup_file, indent=4)

    print("[INFO] Backup completed. DNS records saved to: {}".format(backup_file_name))


def remove_dns_records_with_prefix(dns_records, dryrun):
    """Remove DNS Records if DryRun is false"""
    for dns_record in dns_records:
        record_name = dns_record['name']
        record_type = dns_record['type'].split('/')[-1].lower()
        resource_group = dns_record['resourceGroup']
        dns_zone_name = dns_record['fqdn'].split(".", 1)[1]

        if not dryrun:
            print('[INFO] Removing DNS record: {}'.format(record_name))
            try:
                subprocess.check_call(['az', 'network', 'dns', 'record-set', record_type, 'delete', '-g', resource_group, '-z', dns_zone_name, '-n', record_name, '--yes'])
            except subprocess.CalledProcessError as e:
                print("[ERROR]\nReturnCode: {}\nMessage: {}\n".format(e.returncode, e.output))
        else:
            print('[DRYRUN] Removing DNS record: {}'.format(record_name))

# main
if __name__ == "__main__":
    if not is_az_installed:
        print("[ERROR] Azure CLI ('az') is not installed or cannot be found in your path.")
        exit(1)

    parser = argparse.ArgumentParser()
    parser.add_argument("-r","--resource_group", required=True, help="name of the resource group containing the Azure DNS zone")
    parser.add_argument("-z","--zone", required=True, help="name of the DNS zone containing the records")
    parser.add_argument("-p","--prefix", required=True, help="prefix of the DNS records to search for and remove")
    parser.add_argument("-d","--dryrun", action="store_true", required=False, help="if passed, only log the records to be removed")
    parser.add_argument("-e", "--exclude", default=None, required=False, help="pattern to exclude from deletion. Records containing this substring will not be deleted.")
    parser.add_argument("-b", "--backup", action="store_true", required=False, help="backup the records to a json file before deleting?")
    args = parser.parse_args()

    if not (is_valid_parameter(args.resource_group, "resource_group") 
            and is_valid_parameter(args.zone, "zone")
            and is_valid_parameter(args.prefix, "prefix")):
        parser.print_help()
        exit(1)

    dns_records = get_records(args.resource_group, args.zone, args.prefix, args.exclude)

    if args.backup:
        backup_dns_records(dns_records)

    remove_dns_records_with_prefix(dns_records, args.dryrun)

