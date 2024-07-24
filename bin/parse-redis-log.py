#!/opt/homebrew/bin/python3
import argparse
import json


def parse_redis_status(status_message):
    status_dict = {}

    start_index = status_message.find("inst: ")
    if start_index == -1:
        return "No Redis log entry in the provided message."

    status_message = status_message[start_index:]
    parts = status_message.split(", ")
    for part in parts:
        if ": " in part:
            key, value = part.split(": ", 1)
            status_dict[key] = value
        elif ": (" in part:
            key, value = part.split(": (", 1)
            value = "(" + value
            status_dict[key] = value

    prettified = {
        "Number of instances": status_dict.get("inst", "N/A"),
        "Number of queries": status_dict.get("qu", "N/A"),
        "Queue size": status_dict.get("qs", "N/A"),
        "Asynchronous work": status_dict.get("aw", "N/A"),
        "Background work status": status_dict.get("bw", "N/A"),
        "Replication state": status_dict.get("rs", "N/A"),
        "Worker state": status_dict.get("ws", "N/A"),
        "Incoming requests": status_dict.get("in", "N/A"),
        "Server endpoint": status_dict.get("serverEndpoint", "N/A"),
        "Cache/Connection metrics": status_dict.get("mc", "N/A"),
        "Manager resources available": status_dict.get("mgr", "N/A"),
        "Client name and version": status_dict.get("clientName", "N/A"),
        "IO Completion Ports": status_dict.get("IOCP", "N/A"),
        "Worker threads status": status_dict.get("WORKER", "N/A"),
    }

    return json.dumps(prettified, indent=4)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parse a Redis log entry.")
    parser.add_argument(
        "status_message", type=str, help="The Redis log entry to be parsed."
    )

    args = parser.parse_args()
    message = parse_redis_status(args.status_message)

    print(message)
