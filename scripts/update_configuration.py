#!/usr/bin/env python3

""" Update /usr/src/redmine/config/configuration.yml with config/extra-configuration.py
    Using environment variables
"""

import ruamel.yaml as yaml
import os

CONFIG_FILE_IN = '/usr/src/redmine/config/configuration.yml.example'
CONFIG_FILE = '/usr/src/redmine/config/configuration.yml'

with open(CONFIG_FILE_IN) as f:
    data = yaml.load(f, Loader=yaml.RoundTripLoader)

data['default']['email_delivery'] = {
    'delivery_method': ':smtp',
    'smtp_settings': {
        'address': 'smtp',
        'port': 25,
    }
}
with open(CONFIG_FILE, 'w') as f:
    yaml.dump(data, f, Dumper=yaml.RoundTripDumper, indent=4)
