#!/usr/bin/python3
#
# This script parses a git log from stdin, which should be given with:
# $ git log [<options>] -z --format="- %s (%an)%n%b" [<range>] [[--] <path>...] | ...
# And then outputs to stdout a trimmed changelog for use with rpm packaging
#
# Author: Herton R. Krzesinski <herton@redhat.com>
# Copyright (C) 2021 Red Hat, Inc.
#
# This software may be freely redistributed under the terms of the GNU
# General Public License (GPL).

"""Parses a git log from stdin, and output a log entry for an rpm."""

import re
import sys

def find_bz_in_line(line, prefix):
    """Return bug number from properly formated Bugzilla: line."""
    # BZs must begin with '{prefix}: ' and contain a complete BZ URL or id
    _bugs = []
    if not line.startswith(f"{prefix}: "):
        return _bugs
    bznum_re = re.compile(r'(?P<bug_ids> \d{4,8})|'
        r'( http(s)?://bugzilla\.redhat\.com/(show_bug\.cgi\?id=)?(?P<url_bugs>\d{4,8}))')
    for match in bznum_re.finditer(line[len(f"{prefix}:"):]):
        for group in [ 'bug_ids', 'url_bugs' ]:
            if match.group(group):
                bid = match.group(group).strip()
                if not bid in _bugs:
                    _bugs.append(bid)
    return _bugs


def find_cve_in_line(line):
    """Return cve number from properly formated CVE: line."""
    # CVEs must begin with 'CVE: '
    cve_list = []
    if not line.startswith("CVE: "):
        return cve_list
    _cves = line[len("CVE: "):].split()
    pattern = "(?P<cve>CVE-[0-9]+-[0-9]+)"
    cve_re = re.compile(pattern)
    for cve_item in _cves:
        cve = cve_re.match(cve_item)
        if cve:
            cve_list.append(cve.group('cve'))
    return cve_list


def parse_commit(commit):
    """Extract metadata from a commit log message."""
    lines = commit.split('\n')

    # remove any '%' character, since it'll be used inside the rpm spec changelog
    log_entry = lines[0].replace("%","")

    patchwork = lines[2].startswith("Patchwork-id: ") if len(lines) > 2 else False

    cve_list = []
    bug_list = []
    zbug_list = []
    for line in lines[1:]:
        # If this is a patch applied through patchwork, we can leave processing
        # when outside of Patchwork metadata block
        if patchwork and line == "":
            break

        # Process Bugzilla and ZStream Bugzilla entries
        _bugs = find_bz_in_line(line, 'Bugzilla')
        if _bugs:
            for bzn in _bugs:
                if not bzn in bug_list:
                    bug_list.append(bzn)
            continue
        _zbugs = find_bz_in_line(line, 'Z-Bugzilla')
        if _zbugs:
            for bzn in _zbugs:
                if not bzn in zbug_list:
                    zbug_list.append(bzn)
            continue

        # Grab CVE tags if they are present
        _cves = find_cve_in_line(line)
        for cve in _cves:
            if not cve in cve_list:
                cve_list.append(cve)

    return (log_entry, cve_list, bug_list, zbug_list)


if __name__ == "__main__":
    commits = sys.stdin.read().split('\0')
    for c in commits:
        if not c:
            continue
        log_item, cves, bugs, zbugs = parse_commit(c)
        entry = f"{log_item}"
        if bugs or zbugs:
            entry += " ["
            if zbugs:
                entry += " ".join(zbugs)
            if bugs and zbugs:
                entry += " "
            if bugs:
                entry += " ".join(bugs)
            entry += "]"
        if cves:
            entry += " {" + " ".join(cves) + "}"
        print(entry)
