#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.2"
__date__ = "2/15/2018"

"""
	SCRIPT: 
	make_sprites_from_sequences.py

	SYNOPSIS:
	This script makes a 1 row horizontal sprite from PNGs that are already organized into directories. Typically these would have been exported from After Effects using the built-in PNG Sequence render output module.

	USAGE:
	• Place this script and the lib folder at the sibling level of the PNG folders you want to convert e.g. in your render/output folder.
	• Nothing to set, you just run the script. If there are directories containing PNGs, a sprite will be constructed for each unique set.
	• Directories with names like "misc" or "processed" or "boneyard", etc, will be ignored. All other directories are globbed for *.png files.
"""

import os, sys, glob, subprocess, argparse, textwrap
import lib.png_sprite_maker as _spriteMaker
import lib.strings_EN as strings_en
from datetime import datetime as dt
from PIL import Image

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class boom():

	def __init__(self):
		# print("Running '" + self.__class__.__name__ + "'...")
		print(bcolors.WARNING + "Warning: No active frommets remain. Continue?" + bcolors.ENDC)
		print(bcolors.UNDERLINE + "Warning: No active frommets remain. Continue?" + bcolors.ENDC)

f = boom()





	  
