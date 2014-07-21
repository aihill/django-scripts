#!/usr/bin/env python2.7

import multiprocessing
import numpy as np
import argparse
import subprocess
import socket
import psutil


def start_tmux_worker(hostname, utilization, ram, config, queue, worker_dir, venv_dir):

    # ensure each worker has enough RAM
    concurrency = int(np.clip(args.utilization, 0.0, 1.0) * multiprocessing.cpu_count())
    max_concurrency = int(psutil.phymem_usage()[0] / (ram * 1024 * 1024))
    if concurrency > max_concurrency:
        concurrency = max_concurrency
        print("%s: each worker may use %sMB ram, so we are only starting %s workers" %
              (hostname, ram, concurrency))

    if concurrency < 1:
        print("%s: concurrency=%s --> exiting" % hostname, concurrency)

    if venv_dir:
        venv_cmd = "source '%s/bin/activate'" % venv_dir
    else:
        venv_cmd = "echo 'no venv'"

    worker_cmd = ' '.join([
        "builtin cd '%s';" % worker_dir,
        venv_cmd,
        "celery",
        "worker",
        "--loglevel=info",
        "--concurrency=%s" % concurrency,
        '--maxtasksperchild=1',
        "-A", config,
        "-Q", queue,
        "-n", "%s-%s" % (hostname, queue),
        "-Ofair"
    ])

    # kill existing worker (if any)
    session_name = "celery-%s" % queue
    from tmux_worker.kill import kill_tmux_worker
    kill_tmux_worker(hostname, session_name)

    # start new worker
    print "%s: %s" % (hostname, worker_cmd)
    subprocess.check_call(["tmux", "new", "-s", session_name, '-d', worker_cmd])

    # show result
    output = subprocess.check_output(["tmux", "ls"])
    for line in output.split('\n'):
        if line.startswith("%s:" % session_name):
            print "%s: started new worker:\n    %s" % (hostname, line)
            break


if __name__ == "__main__":

    hostname = socket.gethostname().split('.')[0]

    parser = argparse.ArgumentParser(
        description='(re)start a celery worker in a new tmux session.  If the '
        'worker is already running, it is force quit and restarted.  The workers '
        'are placed in tmux sessions for easy interaction with the workers and '
        'their log output.'
    )
    parser.add_argument(
        '-u', '--utilization', type=float, metavar='<float>', default=1.0,
        help='percent of the machine\'s CPUs that are used (0.0 to 1.0)')
    parser.add_argument(
        '-q', '--queue', metavar='<name>', default='celery',
        help='Celery queue name')
    parser.add_argument(
        '-r', '--ram', type=float, metavar='<MB>', default=1024.0,
        help='percent of the machine\'s CPUs that are used (0.0 to 1.0)')
    parser.add_argument(
        '-c', '--config', metavar='<config>',
        help='name of the celery config directory')
    parser.add_argument(
        '-d', '--worker_dir', metavar='<dir>',
        help='directory where the worker will run')
    parser.add_argument(
        '-v', '--venv_dir', metavar='<dir>', default='',
        help='virtualenv directory')

    args = parser.parse_args()
    start_tmux_worker(hostname, **vars(args))
