#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"
__date__ = "5/15/2019"

'''

Script performs the following tasks:
	• alpha sort objects in the tree

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
	obj = doc.GetFirstObject()
	scene = ObjectIterator(obj)

	doc.StartUndo()

	topLevelNullName = "topnull"

	# loop the scene and delete anything not inside the top null
	obj = doc.GetFirstObject()
	scene = ObjectIterator(obj)
	objList = []  # will function as a hashtable

	for obj in scene:
		# if we're not at the top null
		if not topLevelNullName in obj.GetName():
			objList.append([obj.GetName(), obj])

	# sortedList = sorted(objList, key=str.lower)
	sortedList = sorted(objList, key=lambda x: x[0].lower(), reverse=True)

	for i,o in enumerate(sortedList):
		doc.AddUndo(c4d.UNDOTYPE_CHANGE,o[1])
		o[1].Remove()
		doc.InsertObject(o[1],parent=doc.GetFirstObject())

	doc.EndUndo() 
	c4d.EventAdd()

if __name__=='__main__':
	main()		