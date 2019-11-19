#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"

'''
Script launces a GUI non-modal window. User can perform the following tasks:
	• Select one or more materials and clones them and any dependent materials
	• Cloned materials are appended with user-defined string
'''

import c4d, math, pprint
from c4d import plugins, gui, utils
from c4d.gui import GeDialog as dialog
from random import *

LBL_INFO1 = 1000
LBL_INFO2 = 1001
LBL_INFO3 = 2000
TXT_APPEND = 2001
GROUP_OPTIONS = 1002
BTN_COPY_MATERIALS = 1003
BTN_CANCEL = 1004
DIALOG_WIDTH = 600
DIALOG_HEIGHT = 300

class OptionsDialog(gui.GeDialog):

	def CreateLayout(self):
		self.SetTitle('Octane Mix Material Copier')
		
		# -----------------------------------------------------------------------------

		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_LEFT, cols=4, rows=1)
		self.GroupBorderSpace(10,10,10,10)
		self.AddStaticText(LBL_INFO1, c4d.BFH_LEFT, name='Copy selected materials: ') 
		self.AddButton(BTN_COPY_MATERIALS, c4d.BFH_SCALE, name='Copy')
		self.AddStaticText(LBL_INFO3, c4d.BFH_LEFT, name='Prefix mats with:' ) 
		self.AddEditText(TXT_APPEND, c4d.BFH_LEFT, initw=300)
		self.SetString(TXT_APPEND, "__")
		self.GroupEnd()

		# -----------------------------------------------------------------------------
		
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 1, 1)
		self.AddMultiLineEditText(LBL_INFO2, c4d.BFH_SCALEFIT, initw=900, inith=200, style=c4d.DR_MULTILINE_WORDWRAP+c4d.DR_MULTILINE_READONLY ) 		
		self.GroupEnd()

		# -----------------------------------------------------------------------------

		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 1, 1)
		self.AddButton(BTN_CANCEL, c4d.BFH_SCALE, name='Close')
		self.GroupEnd()

		# -----------------------------------------------------------------------------

		self.doc = c4d.documents.GetActiveDocument()
		self.report_string = ""
		return True


	def introspect_object(self, pObject):
		print("introspection called for " + str(pObject))
		print( pObject.__class__ )
		print( dir(pObject ))
		print( id(pObject) )
		print( help(pObject) ) 
		# print( pObject.__dict__.keys() )
		# pprint({k:getattr(pObject,k) for k in dir( pObject )})
		# print( pObject.globals() )
		# print( pObject.locals() )
		# print( vars(pObject) ) 

	def copy_materials(self):		
		mat_list = self.doc.GetActiveMaterials()
		
		for m in mat_list:
			new_mat = m.GetClone()
			append_string = self.GetString(TXT_APPEND)
			new_mat.SetName( append_string + new_mat.GetName() )
			new_mat.InsertBefore(m)
			c4d.EventAdd()

			# switch focus to copied material
			self.doc.SetActiveMaterial(new_mat, c4d.SELECTION_NEW)

			# clone the two mix materials
			if None != new_mat[c4d.MIXMATERIAL_TEXTURE1]:
				new_mat[c4d.MIXMATERIAL_TEXTURE1] = self.clone_this_material(new_mat[c4d.MIXMATERIAL_TEXTURE1])
			else:
				self.report_string += "\n"
				self.report_string += new_mat.GetName() + " is missing it's first mix material."
			
			if None != new_mat[c4d.MIXMATERIAL_TEXTURE2]:
				new_mat[c4d.MIXMATERIAL_TEXTURE2] = self.clone_this_material(new_mat[c4d.MIXMATERIAL_TEXTURE2])
			else:
				self.report_string += "\n"
				self.report_string += new_mat.GetName() + " is missing it's second mix material."

		self.print_to_console(self.report_string)


	def clone_this_material(self, pMat):
		clone_mat = pMat.GetClone()
		append_string = self.GetString(TXT_APPEND)
		clone_mat.SetName( append_string + pMat.GetName() )
		clone_mat.InsertBefore(pMat)

		self.report_string += "\n"
		self.report_string += "cloned " + str(pMat)
		c4d.EventAdd()

		# handle the case when the clone is also a mix
		if "Octane Mix Material" in str(pMat):
			self.report_string += "\n"
			self.report_string += "clone is also a mix, will clone these too..." 

			if None != clone_mat[c4d.MIXMATERIAL_TEXTURE1]:
				clone_mat[c4d.MIXMATERIAL_TEXTURE1] = self.clone_this_material(clone_mat[c4d.MIXMATERIAL_TEXTURE1])
			else:
				self.report_string += "\n"
				self.report_string += clone_mat.GetName() + " is missing it's first mix material."
			
			if None != clone_mat[c4d.MIXMATERIAL_TEXTURE2]:
				clone_mat[c4d.MIXMATERIAL_TEXTURE2] = self.clone_this_material(clone_mat[c4d.MIXMATERIAL_TEXTURE2])
			else:
				self.report_string += "\n"
				self.report_string += clone_mat.GetName() + " is missing it's second mix material."

		return clone_mat	

	def print_to_console(self, pString):
		self.SetString(LBL_INFO2, str(pString))

	def Command(self, id, msg):
		if id==BTN_CANCEL:
			self.Close()
		elif id==BTN_COPY_MATERIALS:
			self.copy_materials()
		return True

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
		if child :
			self.next_depth = self.depth + 1
			self.object_stack.append(self.current_object.GetNext())
			self.current_object = child
		else :
			self.current_object = self.current_object.GetNext()
			while( self.current_object == None and len(self.object_stack) > 0 ) :
				self.current_object = self.object_stack.pop()
				self.next_depth = self.next_depth - 1
		return obj


def Main():

	# --------------------------------------------------------------------
	# general setup stuff
	doc = c4d.documents.GetActiveDocument()

	c4d.CallCommand(13957, 13957) # Clear Console
	doc.StartUndo()

	dlg = OptionsDialog()
	dlg.Open(c4d.DLG_TYPE_ASYNC,1234, defaultw=DIALOG_WIDTH, defaulth=DIALOG_HEIGHT)
	tmpDict = {"f": 0}
	try:
		dlg.Restore(1234, tmpDict)
	except SystemError as e:
		dlg.Restore(1234, tmpDict)

	if not dlg.ok:
		return

	# --------------------------------------------------------------------
	# the end
	doc.EndUndo()
	c4d.EventAdd()

if __name__=='__main__':
	Main()