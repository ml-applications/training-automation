#!/usr/bin/env python3
import argparse
import os
import re
import subprocess

REMOTE_HOST_SPEC = re.compile(r'^\w+@[\w\.]+:')

def download(remote_path, local_path):
  #scp ubuntu@104.171.200.63:/home/ubuntu/code/glow-tts-samuel-l-jackson/logs/base/G_9450.pth .
  command = 'scp {} {}'.format(remote_path, local_path)
  print(command)
  subprocess.call(command, shell=True)

def download_model_range(args):
  for model_number in range(args.start, args.end + 1, args.skip):
    model_name = 'G_{}.pth'.format(model_number)
    local_name = os.path.join(args.local, model_name)
    if not os.path.exists(local_name):
      remote_model_name = '{}/{}'.format(args.remote, model_name)
      download(remote_model_name, args.local)

def parse_args():
  parser = argparse.ArgumentParser('Split audio into ingestible chunks')
  parser.add_argument('--remote', type=str, required=True)
  parser.add_argument('--local', type=str, required=True)
  parser.add_argument('--start', type=int, default=4000)
  parser.add_argument('--skip', type=int, default=500)
  parser.add_argument('--end', type=int, required=True)

  args = parser.parse_args()

  if not REMOTE_HOST_SPEC.match(args.remote):
    raise Exception('--remote must be a remote host and path, eg. user@0.0.0.0:/path')

  return args

args = parse_args()
download_model_range(args)

