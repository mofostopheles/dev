#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

'''

Script performs the following tasks:
	• deletes all the instances
	• flatten the hierarchy
	• distribute each item on the X axis
	• recenter the enclosing null
	• print a list of each item text file (as a reference)
	• sort objects alphabetically along X axis
	• put an annotation tag on each item with the object name

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

class Tools:
	def centerAxis(self, obj):
		bBoxCenter = obj.GetMp() #Get the center of bounding box (local space)
		
		#Extract the original global matrix
		objMg = obj.GetMg()
		objPos = objMg.off
		objV1 = objMg.v1
		objV2 = objMg.v2
		objV3 = objMg.v3
		
		# Take rotation into consideration
		rot = obj.GetAbsRot()
		rotOrder = obj.GetRotationOrder()
		rotM = utils.HPBToMatrix(rot,rotOrder)
		
		newCenter = bBoxCenter * rotM + objPos #Bounding box center in Global space
		offsetV =  - bBoxCenter #This vector is used to offset all the points
		
		# Step 2 (It doesn’t matter which step goes first): offset all the points to the new center
		allPts = obj.GetAllPoints() #Local Space
		for i in xrange(len(allPts)):
			doc.AddUndo(c4d.UNDOTYPE_CHANGE,obj)
			obj.SetPoint(i,allPts[i] + offsetV)
			
		obj.Message(c4d.MSG_UPDATE)
		
		# Step 1: Set the obj's postion to Bounding box Center
		newMg = c4d.Matrix(newCenter,objV1,objV2,objV3)
		doc.AddUndo(c4d.UNDOTYPE_CHANGE,obj)
		obj.SetMg(newMg)

	def p(self, pString):
		print(pString)


def main():
	doc = docs.GetActiveDocument()
	obj = doc.GetFirstObject()
	scene = ObjectIterator(obj)
	tools = Tools()

	doc.StartUndo()

	# place an empty null at the top of the hierarchy
	topLevelNullName = "components"
	tmpNull = c4d.BaseObject(c4d.Onull)
	doc.InsertObject(tmpNull)
	doc.AddUndo(c4d.UNDOTYPE_NEW, tmpNull)
	tmpNull[c4d.ID_BASELIST_NAME] = topLevelNullName

	# delete all instance objects
	for obj in scene:
		if obj.GetTypeName() == "Instance":			
			doc.AddUndo(c4d.UNDOTYPE_DELETE, obj)
			obj.Remove()
		elif obj.GetTypeName() == "Polygon":
			if "asdf" in obj.GetName().lower() or "jhgk" in obj.GetName().lower() or "hjll" in obj.GetName().lower():
				doc.AddUndo(c4d.UNDOTYPE_DELETE, obj)
				obj.Remove()
			else:
				obj.InsertUnder(tmpNull)		

	# loop the scene and delete anything not inside the "asdf" null
	obj = doc.GetFirstObject()
	scene = ObjectIterator(obj)
	for obj in scene:
		if obj.GetUp():
			if not topLevelNullName in obj.GetUp().GetName():
				doc.AddUndo(c4d.UNDOTYPE_DELETE, obj)
				obj.Remove()
		elif not obj.GetUp() and obj.GetTypeName() == "Null" and not topLevelNullName in obj.GetName():	
			doc.AddUndo(c4d.UNDOTYPE_DELETE, obj)
			obj.Remove()

	# sort objects alphabetically
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


	# reposition everything along X axis
	obj = doc.GetFirstObject()
	scene = ObjectIterator(obj)
	offsetX = 0

	for obj in scene:
		obj.SetAbsPos( c4d.Vector(offsetX,0,0) )
		obj.SetAbsRot( c4d.Vector(0,0,0) )
		obj.Message(c4d.MSG_UPDATE)
		offsetX += 2

		# print a list of each item text file (as a reference)
		print( obj.GetName() )

		# put an annotation tag on each item with the object name
		if not obj.GetTypeName() == "Null":
			annotationTag = obj.MakeTag(c4d.Tannotation)
			annotationTag[c4d.ANNOTATIONTAG_TEXT] = obj.GetName()

	# repo the camera

	gui.MessageDialog("Operation completed")

	doc.EndUndo() 
	c4d.EventAdd()

if __name__=='__main__':
	main()		