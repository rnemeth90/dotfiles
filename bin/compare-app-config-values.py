import argparse
from azure.appconfiguration import AzureAppConfigurationClient

def get_app_config_values(connection_string: str) -> dict:
    client = AzureAppConfigurationClient.from_connection_string(connection_string)
    settings = client.list_configuration_settings()
    config_dict = {s.key: s.value for s in settings}
    return config_dict

def compare_configs(config1: dict, config2: dict):
    print("🔍 Comparing keys with different values:\n")
    shared_keys = config1.keys() & config2.keys()
    diffs = []

    for key in shared_keys:
        if config1[key] != config2[key]:
            diffs.append((key, config1[key], config2[key]))

    if not diffs:
        print("All matching keys have the same value.")
    else:
        for key, val1, val2 in diffs:
            print(f"⚠️  Mismatch for key: {key}")
            print(f"  - Config A: {val1}")
            print(f"  - Config B: {val2}")
            print()

def main():
    parser = argparse.ArgumentParser(
        description="Compare values between two Azure App Configuration resources."
    )
    parser.add_argument(
        "--config-a", required=True, help="Connection string for App Config A"
    )
    parser.add_argument(
        "--config-b", required=True, help="Connection string for App Config B"
    )

    args = parser.parse_args()

    print("🔗 Fetching values from App Config A...")
    config_a = get_app_config_values(args.config_a)
    print("🔗 Fetching values from App Config B...")
    config_b = get_app_config_values(args.config_b)

    compare_configs(config_a, config_b)

if __name__ == "__main__":
    main()
