#!/usr/bin/env python
""" Update EEA repositories
    Reusing https://github.com/eea/eea.docker.redmine/blob/master/crons/redmine.py
"""
import os
import argparse
import json
import urllib2
import logging
import contextlib
from datetime import datetime
from subprocess import Popen, PIPE, STDOUT

class Sync(object):
    """ Usage: redmine.py <loglevel>

    loglevel:
      - info   Log only status messages (default)

      - debug  Log all messages

    """
    def __init__(
        self,
        folder='.',
        github="https://api.github.com/orgs/eea/repos?per_page=100&page=%s",
        redmine="https://taskman.eionet.europa.eu/sys/fetch_changesets?key=%s",
        api_key="",
        timeout=60,
        loglevel=logging.INFO):

        self.folder = folder
        self.github = github
        self.redmine = redmine % api_key
        self.timeout = timeout
        self.repos = []

        self.loglevel = loglevel
        self._logger = None

    @property
    def logger(self):
        """ Logger
        """
        if self._logger:
            return self._logger

        # Setup logger
        self._logger = logging.getLogger('redmine')
        self._logger.setLevel(self.loglevel)
        ch = logging.StreamHandler()
        ch.setLevel(logging.DEBUG)
        formatter = logging.Formatter(
            '%(asctime)s - %(lineno)3d - %(levelname)7s - %(message)s')
        ch.setFormatter(formatter)
        self._logger.addHandler(ch)
        return self._logger

    def refresh_repo(self):
        """ Refresh redmine repositories
        """
        self.logger.info('Fetching changesets on all repos')
        try:
            with contextlib.closing(
                    urllib2.urlopen(self.redmine, timeout=self.timeout)) as con:
                self.logger.debug(con.read())
        except urllib2.HTTPError, err:
            self.logger.warn(err)
        except Exception, err:
            self.logger.exception(err)

    def update_repo(self, name):
        """ Update repo
        """
        self.logger.info('Updating repo: %s', name)
        cmd = 'cd {folder}/{name} && git fetch --all'.format(
            folder=self.folder,
            name=name
        )
        process = Popen(cmd, shell=True,
                        stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True)
        res = process.stdout.read()
        self.logger.debug(res)

    def sync_repo(self, repo):
        """ Sync repo
        """
        existing = os.listdir(self.folder)

        name = repo.get('name', '') + '.git'
        if name in existing:
            return self.update_repo(name)

        self.logger.info('Syncing repo: %s', name)
        cmd = 'git clone --mirror {url} {folder}/{name}'.format(
            url=repo.get('clone_url', ''),
            folder=self.folder,
            name=name
        )

        process = Popen(cmd, shell=True,
                        stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True)
        res = process.stdout.read()
        self.logger.debug(res)
        return self.update_repo(name)

    def sync_repos(self):
        """ Sync all repos
        """
        count = len(self.repos)
        self.logger.info('Syncing %s repositories', count)
        start = datetime.now()
        for repo in self.repos:
            self.sync_repo(repo)

        # Refresh default redmine repository
        self.refresh_repo()

        end = datetime.now()
        self.logger.info('DONE Syncing %s repositories in %s seconds',
                         count, (end - start).seconds)

    def start(self):
        """ Start syncing
        """
        self.repos = []
        links = [self.github % count for count in range(1, 100)]
        try:
            for link in links:
                with contextlib.closing(
                        urllib2.urlopen(link, timeout=self.timeout)) as conn:
                    repos = json.loads(conn.read())
                    if not repos:
                        break
                    self.logger.info('Adding repositories from %s', link)
                    self.repos.extend(repos)
            self.sync_repos()
        except Exception, err:
            self.logger.exception(err)

    __call__ = start


def parse_args():
    """ Parse arguments """
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help="Increase logging verbosity")

    parser.add_argument(
        '-o', '--output',
        help="Destination folder where to output github repos",
        default=os.environ.get(
            "SYNC_FOLDER",
            ".")
    )

    parser.add_argument(
        '-g', '--github',
        help="Github org repo template",
        default=os.environ.get(
            "SYNC_GITHUB_URL",
            "https://api.github.com/orgs/eea/repos?per_page=100&page=%s")
    )

    parser.add_argument(
        '-r', '--redmine',
        help="Redmine fetch_changesets template",
        default=os.environ.get(
            "SYNC_REDMINE_URL",
            "https://taskman.eionet.europa.eu/sys/fetch_changesets?key=%s")
    )

    parser.add_argument(
        '-k', '--key',
        help="Redmine API Key",
        default=os.environ.get(
            "SYNC_API_KEY",
            "")
    )

    parser.add_argument(
        '-t', '--timeout',
        help="Timeout",
        type=int,
        default=60)

    return parser.parse_args()


def main():
    """ Main
    """
    args = parse_args()

    Sync(
        folder=args.output,
        github=args.github,
        redmine=args.redmine,
        api_key=args.key,
        timeout=args.timeout,
        loglevel=logging.DEBUG if args.verbose else logging.INFO
    ).start()

if __name__ == "__main__":
    main()
