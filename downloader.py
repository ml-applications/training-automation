#!/usr/bin/env python3
import argparse
import os
import re
import subprocess

REMOTE_HOST_SPEC = re.compile(r'^\w+@[\w\.]+:')

# =========================
# Glow TTS Path Conventions
# =========================

class RemoteGlow:
  """
  Example files:
    ubuntu@104.171.200.145:/home/ubuntu/mount/checkpoints/moistkr1tikal/base/G_4430.pth
  """
  @classmethod
  def from_args(cls, args):
    if args.remote:
      return RemoteGlowStaticPath(args.remote)
    else:
      return RemoteGlowDestructured(args)

  def full_model_remote_path(self, model_number):
    """
    Get the complete path to a model file.
    """
    model_filename = self.model_filename(model_number)
    remote_path = self.remote_path()
    return '{}/{}'.format(remote_path, model_filename)

  def model_filename(self, model_number):
    """
    Filename format for Glow-TTS model files.
    """
    return 'G_{}.pth'.format(model_number)

  def remote_path(self):
    raise NotImplemented("This has not been implemented.")


class RemoteGlowStaticPath(RemoteGlow):
  def __init__(self, full_path):
    if not REMOTE_HOST_SPEC.match(full_path):
      raise Exception('--remote must be a remote host and path, eg. user@0.0.0.0:/path')

    self.full_path = full_path

  def remote_path(self):
    return self.full_path


class RemoteGlowDestructured(RemoteGlow):
  def __init__(self, args):
    if not args.ip: raise AssertionError('--ip or --remote not provided')
    if not args.voice_name: raise AssertionError('--voice_name or --remote not provided')

    self.username = args.username or 'ubuntu'
    self.ip = args.ip
    self.voice_name = args.voice_name

  def remote_path(self):
    return '{}@{}:/home/{}/mount/checkpoints/{}/base'.format(
        self.username,
        self.ip,
        self.username,
        self.voice_name)


# =============
# Download Loop
# =============

def download(remote_path, local_path):
  #scp ubuntu@104.171.200.63:/home/ubuntu/code/glow-tts-samuel-l-jackson/logs/base/G_9450.pth .
  command = 'scp {} {}'.format(remote_path, local_path)
  print('Command:\n{}'.format(command))
  subprocess.call(command, shell=True)

def download_model_range(args):
  remote_glow = RemoteGlow.from_args(args)

  for model_number in range(args.start, args.end + 1, args.skip):
    model_name = 'G_{}.pth'.format(model_number)
    local_name = os.path.join(args.local, model_name)
    if not os.path.exists(local_name):
      remote_model_name = remote_glow.full_model_remote_path(model_number)
      download(remote_model_name, args.local)


# ===========
# Arg Parsing
# ===========

def parse_args():
  parser = argparse.ArgumentParser('Split audio into ingestible chunks')
  parser.add_argument('--remote', type=str, help='Full remote path, including user and hostname', required=False)
  parser.add_argument('--voice_name', type=str, required=False)
  parser.add_argument('--ip', type=str, required=False)
  parser.add_argument('--username', type=str, required=False)
  parser.add_argument('--local', type=str, required=True)
  parser.add_argument('--start', type=int, default=4000)
  parser.add_argument('--skip', type=int, default=500)
  parser.add_argument('--end', type=int, required=True)

  args = parser.parse_args()

  return args

args = parse_args()
download_model_range(args)

