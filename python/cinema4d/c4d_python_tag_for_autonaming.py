#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

'''
	Script references a userdata string that can be appended. 
	Use this script on nulls or anything you want to be auto-named according to some larger hierarchical structure.
	Modify to taste.
'''

import c4d, math
from random import randint

custom_name = op[c4d.ID_USERDATA, 1]

def main():

    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    if frame == 0:
        parent_name = op.GetObject().GetUp().GetUp().GetName()
        op.GetObject().SetName( parent_name + "_CON_" + custom_name  )

    c4d.EventAdd()