#!/usr/bin/env python3

import sys
import os

script_dir = os.path.dirname(os.path.realpath(__file__))
real_script = os.path.join(script_dir, '..', 'includes', 'lines.py')

with open(real_script) as f:
    exec(compile(f.read(), real_script, 'exec'))