#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"
__date__ = "9/29/2018"

"""
	clean up the directory after we make sprites
"""

import os, sys

arg = "cp *-layer0.jpg *-layer1.jpg ./processed/pixel3_launch_sprites/pixel3_brand_sprites -v -u"
os.system( arg )

arg = "cp sprite-pixel3*.png ./processed/pixel3_launch_sprites/pixel3_brand_sprites -v -u"
os.system( arg )

arg = "rm sprite-pixel3*.png"
os.system( arg )

arg = "rm pixel3-* -d -r"
os.system( arg )

arg = "rm *-layer0.jpg *-layer1.jpg"
os.system( arg )

arg = "rm *-layer0 -r"
os.system( arg )

arg = "rm *-layer1 -r"
os.system( arg )

arg = "cp sprite-pixel3*.jpg ./processed/pixel3_launch_sprites/pixel3_brand_sprites -v -u"
os.system( arg )

arg = "rm sprite-pixel3*.jpg"
os.system( arg )
