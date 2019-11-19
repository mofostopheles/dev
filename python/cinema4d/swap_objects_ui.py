#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"


'''

Script performs the following tasks:
	• Swap out objects containing specific string fragments with another precisely named object
	• Uses a UI popup to specify the targets

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

# Unique id numbers for each of the GUI elements
LBL_INFO1 = 1000
LBL_INFO2 = 1001
TXT_FIND = 10001
TXT_REPLACE = 10002
GROUP_OPTIONS = 20000
BTN_OK = 20001
BTN_CANCEL = 20002

class OptionsDialog(gui.GeDialog):
	def CreateLayout(self):
		self.SetTitle('Object Swapper')
		self.AddStaticText(LBL_INFO1, c4d.BFH_LEFT, name='Find:') 
		self.AddEditText(TXT_FIND, c4d.BFH_SCALEFIT)
		self.SetString(TXT_FIND, 'something')  # Default 'find' string.
		self.AddStaticText(LBL_INFO2, c4d.BFH_LEFT, name='Replace with:') 
		self.AddEditText(TXT_REPLACE, c4d.BFH_SCALEFIT)
		self.SetString(TXT_REPLACE, 'something_else')  # Default 'replace' string.
		# Buttons - an Ok and Cancel button:
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 2, 1)
		self.AddButton(BTN_OK, c4d.BFH_SCALE, name='OK')
		self.AddButton(BTN_CANCEL, c4d.BFH_SCALE, name='Cancel')
		self.GroupEnd()
		self.ok = False
		return True
 
  # React to user's input:
	def Command(self, id, msg):
		if id==BTN_CANCEL:
			self.Close()
		elif id==BTN_OK:
			self.ok = True
			self.option_find_string = self.GetString(TXT_FIND)
			self.option_replace_string = self.GetString(TXT_REPLACE)
			self.Close()
		return True


def main():
	doc = docs.GetActiveDocument()
	obj = doc.GetFirstObject()
	scene = ObjectIterator(obj)
	tools = Tools()

	doc.StartUndo()
	
	dlg = OptionsDialog()
	dlg.Open(c4d.DLG_TYPE_MODAL, defaultw=300, defaulth=50)

	if not dlg.ok:
		return

	_master_object = doc.SearchObject(dlg.option_replace_string)	
	replacementCounter = 0

	if _master_object:

		tmpNull = c4d.BaseObject(c4d.Onull)
		tmpNull.InsertAfter(obj)
		tmpNull[c4d.ID_BASELIST_NAME] = "new_components"
		doc.AddUndo(c4d.UNDOTYPE_NEW, tmpNull)

		for obj in scene:
			if (dlg.option_find_string in obj.GetName()):
				# print("\t swapping out " + obj.GetName())

				clone = _master_object.GetClone()					
				objMg = obj.GetMg() #global matrix
				bBoxCenter = obj.GetMp() #Get the center of bounding box (local space)
				clone.SetMg(objMg)

				# clone.SetModelingAxis( obj.GetModelingAxis(doc) )
				# print(objMg.off)
				# clone.InsertUnder(obj)
				# axi=obj.GetAbsPos()
				# clone.SetAbsPos(axi)
				# cen=obj.GetMp()
				# clone.SetMp(cen)
				# clone.SetRelPos( obj.GetRelPos() )
				# clone.SetAbsPos( obj.GetAbsPos() )
				# clone.SetAbsRot( obj.GetAbsRot() )
				# clone.SetAbsScale( obj.GetAbsScale() )

				# offsetV = 0 # - bBoxCenter #This vector is used to offset all the points
				# allPts = clone.GetAllPoints() #Local Space
				# for i in xrange(len(allPts)):
				# 	doc.AddUndo(c4d.UNDOTYPE_CHANGE, clone)
				# 	clone.SetPoint(i,allPts[i] + offsetV)

				# clone.InsertAfter(obj)

				clone.InsertUnder(tmpNull)
				clone.Message(c4d.MSG_UPDATE)
				doc.AddUndo(c4d.UNDOTYPE_NEW, clone)
				replacementCounter += 1

			# print(scene.depth, scene.depth*'	', obj.GetName())
		if replacementCounter > 1:
			gui.MessageDialog(str(replacementCounter) + " objects were swapped.")
		elif replacementCounter == 1:
			gui.MessageDialog("One object was swapped.")
	else:
		gui.MessageDialog("Could not locate an object with the name '" + dlg.option_replace_string + "'")

	doc.EndUndo() 
	c4d.EventAdd()

if __name__=='__main__':
	main()		