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
        'ssl': 'true',
        'enable_starttls_auto': 'true',
        'address': os.environ.get('SMTP_HOST', 'smtp.gmail.com'),
        'port': os.environ.get('SMTP_PORT', 587),
        'domain': os.environ.get('SMTP_DOMAIN', 'helpdesk.eaudeweb.ro'),
        'authentication': ':login',
        'user_name': os.environ.get('SMTP_USERNAME', 'username'),
        'password': os.environ.get('SMTP_PASSWORD', 'secret'),
    }
}
with open(CONFIG_FILE, 'w') as f:
    yaml.dump(data, f, Dumper=yaml.RoundTripDumper, indent=4)
