#!/usr/bin/env python3
"""Parse content.yaml and output enabled entries as pipe-delimited lines.

Output format: name|type|zim_prefix|url
Only entries with enabled: true are emitted.
"""

import sys
import yaml

def main():
    if len(sys.argv) < 2:
        print("Usage: parse_content.py <content.yaml>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1]) as f:
        data = yaml.safe_load(f)

    categories = data.get("categories", {})
    for category_name, items in categories.items():
        for item in items:
            if not item.get("enabled", False):
                continue

            name = item.get("name", "unknown")
            item_type = item.get("type", "zim")
            zim_prefix = item.get("zim", "")
            url = item.get("url", "")

            print(f"{name}|{item_type}|{zim_prefix}|{url}")

if __name__ == "__main__":
    main()
