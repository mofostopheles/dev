#!/usr/bin/env python
# -*- coding: utf8 -*-

import c4d, math
from c4d.modules import mograph as mo

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"


# -----------------------------------------------
'''
	About this script:
	• loop the children of an object
	• change the name of each child
'''
# -----------------------------------------------


def rename_items():

	parent_item_name = "some name"
	parent_item = doc.SearchObject(parent_item_name)
	name_prefix = "some prefix"

	# -----------------------------------------------
	for j in range( 0, len(parent_item.GetChildren()) ):
		child_item = parent_item.GetChildren()[j]
		child_item.SetName(name_prefix + "_" + str(j))

	c4d.EventAdd()

def main():
	rename_items()

# workaround so we can edit in sublime but run in C4D's script manager
main()