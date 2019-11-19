#!/usr/bin/env python
# -*- coding: utf8 -*-

# WARNING: THIS IS A TEST

import c4d, math
from c4d.modules import mograph as mo

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"


# -----------------------------------------------
'''
	About this script:
	• This will rename all the splines within SPLINE_1 and SPLINE_2 with a sequential ordinal.
	• The reason we need this is because the splines must have original names, as the cloners will be running off of these and using names to make comparisons.

'''
# -----------------------------------------------


# -----------------------------------------------
# object iterator, just pass in a root of any collection and iterate
# -----------------------------------------------
class ObjectIterator:
	def __init__(self, pBase_object):
		self.base_object = pBase_object
		self.current_object = pBase_object
		self.object_stack = []
		self.depth = 0
		self.next_depth = 0

	def __iter__(self):
		return self

	def next(self):
		if self.current_object == None :
			raise StopIteration

		obj = self.current_object
		self.depth = self.next_depth

		child = self.current_object.GetDown()
		if child:
			self.next_depth = self.depth + 1
			self.object_stack.append(self.current_object.GetNext())
			self.current_object = child
		else:
			self.current_object = self.current_object.GetNext()
			while( self.current_object == None and len(self.object_stack) > 0 ) :
				self.c3urrent_object = self.object_stack.pop()
				self.next_depth = self.next_depth - 1
		return obj


def rename_splines():
	global cloners_object
	# -----------------------------------------------
	# we only need hard code the names of the top level splines
	# -----------------------------------------------
	# list_of_top_level_splines = ["SPLINE_1"]
	list_of_top_level_splines = ["spline_1", "spline_2"]

	hit_count = 0
	# -----------------------------------------------
	for s in list_of_top_level_splines:

		level_1_spline = doc.SearchObject(s)

		if len( level_1_spline.GetChildren() ) >= 1:
			for j in range( 0, len(level_1_spline.GetChildren()) ):
				child_spline = level_1_spline.GetChildren()[j]
				child_spline.SetName(s + "_" + str(j))
				if len( child_spline.GetChildren() ) >= 1:
					for k in range( 0, len(child_spline.GetChildren()) ):
						grandchild_spline = child_spline.GetChildren()[k]
						grandchild_spline.SetName(s + "_" + str(j)+ "_" + str(k))


	c4d.EventAdd()

def main():
	rename_splines()

# workaround so we can edit in sublime but run in C4D's script manager
main()