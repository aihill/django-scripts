#!/usr/bin/env python2.7

import socket
import subprocess
import argparse


def tmux_celery_worker_kill(hostname, session_name):
    try:
        output = subprocess.check_output(["tmux", "ls"])
    except:
        output = None

    killed = False
    if output:
        for line in output.split('\n'):
            if line.startswith("%s: " % session_name):
                print "%s: Killing worker:\n    %s" % (hostname, line.strip())
                subprocess.check_call(["tmux", "kill-session", "-t", session_name])
                killed = True
                break

    return killed

if __name__ == "__main__":

    hostname = socket.gethostname().split('.')[0]

    parser = argparse.ArgumentParser(
        description='Kill a tmux worker.'
    )
    parser.add_argument(
        '-q', '--queue', metavar='<name>', default='celery',
        help='Celery queue name'
    )
    args = parser.parser_args()

    session_name = "celery-%s" % args.queue
    killed = tmux_celery_worker_kill(hostname, session_name)
    if not killed:
        print "%s: No worker killed." % hostname
