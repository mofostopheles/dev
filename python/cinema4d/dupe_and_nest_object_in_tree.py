#!/usr/bin/env python
# -*- coding: utf8 -*-

raise Exception( 'DEPRECATED, please import the branch_iterator instead.' )

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

'''
Script performs the following tasks:
	• create a list of objects based on common name
	• drill into each of these objects until the desired node is found
	• grab a cloned object and place it under the desired node
'''

import c4d
from c4d import plugins, gui, utils
from c4d import documents as docs
from c4d.gui import GeDialog as dialog
from math import *
from random import *

class ObjectIterator :
	def __init__(self, baseObject):
		self.baseObject = baseObject
		self.currentObject = baseObject
		self.objectStack = []
		self.depth = 0
		self.nextDepth = 0

	def __iter__(self):
		return self

	def next(self):
		if self.currentObject == None :
			raise StopIteration

		obj = self.currentObject
		self.depth = self.nextDepth

		child = self.currentObject.GetDown()
		if child :
			self.nextDepth = self.depth + 1
			self.objectStack.append(self.currentObject.GetNext())
			self.currentObject = child
		else :
			self.currentObject = self.currentObject.GetNext()
			while( self.currentObject == None and len(self.objectStack) > 0 ) :
				self.currentObject = self.objectStack.pop()
				self.nextDepth = self.nextDepth - 1
		return obj


def main():

	doc = docs.GetActiveDocument()
	first_item = doc.SearchObject("name of repeating parent object")
	obj_to_clone = doc.SearchObject("object to clone")

	iterz = ObjectIterator(first_item)
	list_of_items = []

	for f in iterz:
		if f.GetName() == "name of repeating parent object":
			list_of_items.append(f)

	for j in range( 0, len(list_of_items) ):
		child_items = list_of_items[j].GetChildren()
		for c in child_items:
			if c.GetName() == "parent item in hierarchy":
				grandchild_items = c.GetChildren()
				for k in grandchild_items:
					if k.GetName() == "a nested item in hierarchy":
						g_grandchild_items = k.GetChildren()
						for ggc in g_grandchild_items:
							if ggc.GetName() == "yet another item in hierarchy":
								
								cloned_object = obj_to_clone.GetClone()
								cloned_object.InsertUnder(ggc)
								cloned_object[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = -300 # do other things here
								c4d.EventAdd()
								# return # uncomment to test the first instance found


	return

if __name__=='__main__':
	main()		