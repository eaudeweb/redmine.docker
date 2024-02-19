#!/usr/bin/env python3

""" Update /usr/src/redmine/config/configuration.yml with config/extra-configuration.py
    Using environment variables
"""

import yaml
import os

CONFIG_DIR = "/usr/src/redmine/config/"
CONFIG_FILE_IN = os.path.join(CONFIG_DIR, "configuration.yml.example")
CONFIG_FILE = os.path.join(CONFIG_DIR, "configuration.yml")

with open(CONFIG_FILE_IN) as f:
    data = yaml.safe_load(f)

data["default"]["email_delivery"] = {
    "delivery_method": ":smtp",
    "smtp_settings": {
        "address": "smtp",
        "port": 25,
    },
}
with open(CONFIG_FILE, "w") as f:
    yaml.dump(data, f, indent=4)
