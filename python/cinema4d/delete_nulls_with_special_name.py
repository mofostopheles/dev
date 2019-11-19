#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"


'''
Script performs the following tasks:
	deletes stuff as you like
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

	doc.StartUndo()

	obj = doc.GetFirstObject()
	scene = ObjectIterator(obj)
	objList = []  # will function as a hashtable

	for obj in scene:
		if "NAME_OF_OBJECT" in obj.GetName():
			objList.append(obj)

	for item in objList:
		item.Remove()

	print("done")

	doc.EndUndo() 
	c4d.EventAdd()

if __name__=='__main__':
	main()		