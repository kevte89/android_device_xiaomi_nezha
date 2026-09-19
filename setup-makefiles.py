#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Validate staged Nezha stock identities and regenerate draft vendor makefiles."""
from pathlib import Path
import runpy
import sys
sys.dont_write_bytecode = True
script = Path(__file__).resolve().with_name('extract-files.py')
sys.argv = [str(script), '--regenerate_makefiles']
runpy.run_path(str(script), run_name='__main__')
