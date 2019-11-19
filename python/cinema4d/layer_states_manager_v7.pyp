"""Name-US: Layer States Manager v.7
Description-US: Provides a UI to set and store layer states, similar to Photoshop's layer comp concept.
"""

#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "7.0.0"
__email__ = "arloemerson@gmail.com"


'''

Script launches a GUI non-modal window. User can perform the following tasks:
	• Create or open a text file database.
	• Save the state of layer visibility/render as a named set.
	• Remove databases from the databases dropdown menu
	• Remove layer sets from the layer sets dropdown menu
	• Isolate duplicate named layers.
	• Rename duplicate named layers by appending an alpha/number combination.
	• Toggle all layers on/off.
	• Locate a layer from a selected object in the hierarchy.
	• backwards compat with r13 - r21

'''

PLUGIN_ID = 8675308

import c4d, math, pprint, os
from c4d import bitmaps, plugins, gui, utils, documents
from c4d.gui import GeDialog as dialog
from random import *

LBL_INFO0 = 1000
LBL_INFO1 = 1001
LBL_INFO2 = 1002
LBL_INFO3 = 1003
LBL_INFO4 = 1004
LBL_INFO5 = 1005
LBL_INFO6 = 1006
LBL_INFO7 = 1007
LBL_INFO8 = 1008
TXT_LAYER_SEARCH_REQUEST = 1009
LBL_SEARCH_LAYER_RESULT = 10010
LBL_DB_NAME = 10011
LBL_FEEDBACK = 10012
ID_LAYER_SET_NAME = 10013
LBL_SEARCH_LAYER = 10014
GROUP_OPTIONS = 10015
BTN_SEARCH_LAYER = 10016
BTN_SAVE = 10017
BTN_OPEN_DB = 10018
BTN_CREATE_DB = 10019
BTN_CANCEL = 10020
BTN_ACTIVATE_LAYER_SET = 10021
BTN_REMOVE_LAYER_SET = 10022
BTN_FIND_DUPE_LAYER_NAMES = 10023
BTN_FIX_DUPE_LAYER_NAMES = 10024
BTN_ACTIVATE_ALL = 10025
BTN_ACTIVATE_NONE = 10026
BTN_FIND_LAYER = 10027
BTN_LOAD_DB = 10028
BTN_REMOVE_DB = 10029
CMBOBOX = 10030
CMBOBOX2 = 10031

DIALOG_WIDTH = 900
DB_DEFAULT_NONE = "no database"
DB_PATHS_FILE = "layer_db_paths.txt"

class LayerStateManager(gui.GeDialog):

	def CreateLayout(self):
		self.SetTitle('Layer State Manager')

		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_LEFT, cols=3, rows=1, title="DATABASE")
		self.GroupBorderSpace(10,10,10,10)
		# self.GroupBorder(c4d.BORDER_ROUND)
		self.AddStaticText(LBL_INFO0, c4d.BFH_LEFT, name='Open or create a database: ') 
		self.AddButton(BTN_OPEN_DB, c4d.BFH_LEFT, name='Open')
		self.AddButton(BTN_CREATE_DB, c4d.BFH_LEFT, name='Create')
		self.GroupEnd()
		# -----------------------------------------------------------------------------

		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_LEFT, cols=2, rows=1)
		self.GroupBorderSpace(10,0,10,0)
		self.AddStaticText(LBL_INFO3, c4d.BFH_LEFT, name='Current database: ')
		self.GADGET_OBJ_DB_NAME = self.AddStaticText(LBL_DB_NAME, c4d.BFH_LEFT, initw=DIALOG_WIDTH, name=DB_DEFAULT_NONE)
		self.GroupEnd()
		# -----------------------------------------------------------------------------

		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_LEFT, cols=4, rows=1)
		self.GroupBorderSpace(10,10,10,10)
		self.AddStaticText(LBL_INFO8, c4d.BFH_LEFT, name='Previous database files: ')
		self.combo2 = self.AddComboBox(CMBOBOX2, c4d.BFH_FIT, initw=300, inith=0, specialalign=False)
		self.AddButton(BTN_LOAD_DB, c4d.BFH_SCALE, name='Load')
		self.AddButton(BTN_REMOVE_DB, c4d.BFH_SCALE, name='Remove')
		self.GroupEnd()
		# -----------------------------------------------------------------------------
		
		self.AddSeparatorH(c4d.BFH_FIT)

		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_LEFT, cols=4, rows=1)
		self.GroupBorderSpace(10,10,10,10)
		self.AddStaticText(LBL_INFO1, c4d.BFH_LEFT, name='Save currently visible layers as: ') 
		self.GADGET_OBJ_SET_NAME = self.AddEditText(ID_LAYER_SET_NAME, c4d.BFH_LEFT, initw=300)
		self.SetString(ID_LAYER_SET_NAME, '')
		self.AddButton(BTN_SAVE, c4d.BFH_SCALE, name='Save')
		self.GADGET_OBJ_SAVE_DEBUG = self.AddStaticText(LBL_FEEDBACK, c4d.BFH_LEFT, initw=400, name='---') 
		self.GroupEnd()
		# -----------------------------------------------------------------------------
		
		self.AddSeparatorH(c4d.BFH_FIT)
		
		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_LEFT, 5, 1)
		self.GroupBorderSpace(10,10,10,10)
		self.AddStaticText(LBL_INFO4, c4d.BFH_LEFT, name='Choose a layer set: ') 
		self.combo = self.AddComboBox(CMBOBOX, c4d.BFH_FIT, initw=300, inith=0, specialalign=False)
		self.AddButton(BTN_ACTIVATE_LAYER_SET, c4d.BFH_SCALE, name='Activate Layer Set')
		self.AddButton(BTN_REMOVE_LAYER_SET, c4d.BFH_SCALE, name='Remove Layer Set')
		self.GroupEnd()
		# -----------------------------------------------------------------------------

		self.AddSeparatorH(c4d.BFH_FIT)

		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 2, 1)
		self.AddButton(BTN_FIND_DUPE_LAYER_NAMES, c4d.BFH_SCALE, name='Find Dupe Layer Names')
		self.AddButton(BTN_FIX_DUPE_LAYER_NAMES, c4d.BFH_SCALE, name='Fix Dupe Layer Names')
		self.GroupEnd()
		# -----------------------------------------------------------------------------
		
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 1, 1)
		self.AddMultiLineEditText(LBL_INFO5, c4d.BFH_SCALEFIT, initw=900, inith=100, style=c4d.DR_MULTILINE_WORDWRAP+c4d.DR_MULTILINE_READONLY ) 		
		self.GroupEnd()

		# -----------------------------------------------------------------------------

		self.AddSeparatorH(c4d.BFH_FIT)

		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 4, 1)
		self.AddStaticText(LBL_INFO4, c4d.BFH_LEFT, name='Misc utilities: ') 
		self.AddButton(BTN_ACTIVATE_ALL, c4d.BFH_SCALE, name='Turn all layers on')
		self.AddButton(BTN_ACTIVATE_NONE, c4d.BFH_SCALE, name='Turn all layers off')
		self.AddButton(BTN_FIND_LAYER, c4d.BFH_SCALE, name='Find layer from selected object')
		self.GroupEnd()

		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 3, 1)
		self.AddStaticText(LBL_SEARCH_LAYER, c4d.BFH_LEFT, name='Search for layer: ') 
		self.AddEditText(TXT_LAYER_SEARCH_REQUEST, c4d.BFH_LEFT, initw=300)
		self.AddButton(BTN_SEARCH_LAYER, c4d.BFH_SCALE, name='Search')
		self.GroupEnd()

		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 1, 1)
		self.AddStaticText(LBL_SEARCH_LAYER_RESULT, c4d.BFH_CENTER, name='', initw=600) 
		self.GroupEnd()

		# -----------------------------------------------------------------------------

		self.AddSeparatorH(c4d.BFH_FIT)

		# -----------------------------------------------------------------------------
		self.GroupBegin(GROUP_OPTIONS, c4d.BFH_CENTER, 1, 1)
		self.AddButton(BTN_CANCEL, c4d.BFH_SCALE, name='Close')
		self.GroupEnd()
		# -----------------------------------------------------------------------------

		self.ok = False
		self.database_file = None
		self.database_file_path = ""
		self.layer_set_name = ""
		self.list_of_visible_layers = []
		self.feedback_message = ""
		self.layer_sets_array = []
		self.previous_databases = []

		# call these now that everything is all set up
		self.report_dupe_layer_names()
		self.list_previously_loaded_databases()

		# -----------------------------------------------------------------------------
		return True

	def list_previously_loaded_databases(self):
		script_path = c4d.storage.GetUserSiteSpecificPath() # this path is typically something like C:\Users\<user name>\AppData\Roaming\MAXON\Cinema 4D R20_4FA5020E\library\python\packages\win64

		# note: to edit the list of databases, you can edit the layer_db_paths.txt file directly.
		# the list is simply an array of arrays. the child arrays have two members:
		# 0 == friendly name of the database
		# 1 == the path to the database file
		# there's also a function here that does all this

		txt_file = None

		try:
			txt_file = open(script_path + "\\" + DB_PATHS_FILE,'r+')
		except Exception as e:
			if type(e) == IOError:
				# need to create the DB storage file 
				txt_file = open(script_path + "\\" + DB_PATHS_FILE,'w+')
			raise e

		tmp_list = []
		with txt_file as f:
			f.seek(0)
			tmp_string = f.read()
			if tmp_string != "":
				tmp_list = eval(tmp_string)

		txt_file.close()

		self.previous_databases = tmp_list
		self.FreeChildren(CMBOBOX2)

		for i, item in enumerate( tmp_list ):
			self.AddChild( CMBOBOX2, i, item[0] )

	def get_short_name_from_path(self, pFilePath):
		short_name = ""
		if pFilePath != "":
			short_name = pFilePath[ pFilePath.rfind("\\")+1:len(pFilePath)-4 ]
		return short_name

	def update_previous_database_list(self, pFilePath):
		short_name = self.get_short_name_from_path(pFilePath)
		match_found = False
		for n in self.previous_databases:
			if pFilePath == n[1]:
				match_found = True
 
 		if match_found == False:

 			# add it
 			self.previous_databases.append( list([ short_name, pFilePath ]) )

 			# update the previous db file
 			self.save_previous_databases_file()

	def remove_database_from_list(self):
		database_file_index_selected = self.GetInt32(CMBOBOX2)
		if database_file_index_selected == -1:
			return
		else:
			db_to_remove = self.previous_databases[ database_file_index_selected ][1]

			index_of_found_item = -1
			for n in self.previous_databases:
				if db_to_remove == n[1]:
					index_of_found_item = self.previous_databases.index( n )
					break
 
 		if index_of_found_item > -1:
 			self.previous_databases.pop( index_of_found_item )

 			# update the previous db file
 			self.save_previous_databases_file()

		self.SetInt32(CMBOBOX2, 0)
 		c4d.EventAdd()

 	def save_previous_databases_file(self):
		# overwrite the previous database file list with this new list
		script_path = c4d.storage.GetUserSiteSpecificPath()

		txt_file = None

		try:
			txt_file = open(script_path + "\\" + DB_PATHS_FILE,'r+')
		except Exception as e:
			if type(e) == IOError:
				# need to create the DB storage file 
				txt_file = open(script_path + "\\" + DB_PATHS_FILE,'w+')
			raise e

		with txt_file as f: 
			f.seek(0)
			f.truncate()
			f.write( repr(self.previous_databases) )
		txt_file.close()

		# refresh the dropdown menu
		self.list_previously_loaded_databases()

	def load_database_from_selection(self):
		database_file_index_selected = self.GetInt32(CMBOBOX2)
		if database_file_index_selected == -1:
			return
		else:
			db_to_load = self.previous_databases[ database_file_index_selected ][1]

			try:
				txt_file = open( db_to_load ,'r+')
			except Exception as e:
				self.SetString(LBL_DB_NAME, str(e).replace("\\\\", "\\"))
				raise e
			else:
				self.database_file_path = db_to_load
				self.database_file = txt_file
				# display the short name of the database
				#self.SetString(LBL_DB_NAME, self.get_short_name_from_path(db_to_load))
				# display the full path to the database
				self.SetString(LBL_DB_NAME, db_to_load)
				self.FreeChildren(CMBOBOX)
				self.populate_layer_combobox()		
				self.SetInt32(CMBOBOX, 0)
				c4d.EventAdd()

	def populate_layer_combobox(self):
		if self.database_file.closed == True:
			self.database_file = open( self.database_file_path, 'r+')

		tmp_list = []
		with self.database_file as f:
			f.seek(0)
			tmp_string = f.read()
			if tmp_string != "":
				tmp_list = eval(tmp_string)

		self.FreeChildren(CMBOBOX)

		for i, item in enumerate( tmp_list ):
			self.AddChild( CMBOBOX, i, item[0] )

		self.layer_sets_array = tmp_list # this list is used as a snapshot of the DB

		# select the last item in the list
		self.SetInt32(CMBOBOX, (len(tmp_list)-1))
		c4d.EventAdd()

 	def update_ui_message(self):
 		self.SetString(LBL_FEEDBACK, self.feedback_message)
 		c4d.EventAdd()

	def Command(self, id, msg):
		if id==BTN_CANCEL:
			if not self.database_file == None:
				self.database_file.close()
			self.Close()

		elif id==BTN_SAVE:
			self.ok = True
			self.layer_set_name = self.GetString(ID_LAYER_SET_NAME)
			self.update_database()

			if not self.GetString(ID_LAYER_SET_NAME) == "" and self.GetString(LBL_DB_NAME) != DB_DEFAULT_NONE:
				self.update_ui_message()

			self.populate_layer_combobox()

		elif id==BTN_OPEN_DB:
			self.open_database()

		elif id==BTN_CREATE_DB:
			self.create_database()

		elif id==BTN_ACTIVATE_LAYER_SET:
			self.activate_layer_set()

		elif id==BTN_REMOVE_LAYER_SET:
			self.remove_layer_set()

		elif id==BTN_FIND_DUPE_LAYER_NAMES:
			self.report_dupe_layer_names()

		elif id==BTN_FIX_DUPE_LAYER_NAMES:
			self.fix_dupe_layer_names()

		elif id==BTN_ACTIVATE_NONE:
			self.activate_none_layers()
		
		elif id==BTN_ACTIVATE_ALL:
			self.activate_all_layers()			
		
		elif id==BTN_FIND_LAYER:
			self.find_layer_from_selected()
		
		elif id==BTN_SEARCH_LAYER:
			self.search_for_layer()

		elif id==BTN_LOAD_DB:
			self.load_database_from_selection()

		elif id==BTN_REMOVE_DB:
			self.remove_database_from_list()

		# reset ui feedback label
		try:
			self.IsActive(ID_LAYER_SET_NAME)
			# this blows up on pre r15
			pass
		except Exception as e:
			print("ignore this error")
			# raise e
		else:
			if self.IsActive(ID_LAYER_SET_NAME):
				self.SetString(LBL_FEEDBACK, '')
				self.list_of_visible_layers = [] # reset the list
			pass

		return True

	def search_for_layer(self):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		search_string = self.GetString(TXT_LAYER_SEARCH_REQUEST)
		print('searching for layer "' + search_string + '"')
		layer_list = list(ObjectIterator(root))

		self.unselect_all_layers()
		item_found = False

		if search_string != "":
			for layer in layer_list:
				if type(layer) == c4d.documents.LayerObject:
					if layer.GetName().lower() == search_string.lower():
						# self.introspect_object(layer)
						message = 'found layer named "' + search_string + '"' 
						print(message)						
						self.SetString(LBL_SEARCH_LAYER_RESULT, message)
						item_found = True
						doc.SetSelection(layer, mode=c4d.SELECTION_NEW)
						c4d.EventAdd()

		if not item_found:
			message = 'could not locate a layer named "' + search_string + '"'
			print(message)
			self.SetString(LBL_SEARCH_LAYER_RESULT, message)

	def find_layer_from_selected(self):
		doc = documents.GetActiveDocument()
		selected_object = doc.GetActiveObject()
		doc.SetSelection(selected_object.GetLayerObject(doc), mode=c4d.SELECTION_NEW)
		c4d.EventAdd()

	def introspect_object(self, pObject):
		print("introspection called for " + str(pObject))
		print( pObject.__class__ )
		# print( pObject.__dict__.keys() )
		# pprint({k:getattr(pObject,k) for k in dir( pObject )})
		print( dir(pObject ))
		print( id(pObject) )
		# print( pObject.globals() )
		# print( pObject.locals() )
		print( help(pObject) ) 
		# print( vars(pObject) ) 

	def unselect_all_layers(self):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layer_list = list(ObjectIterator(root))

		for layer in layer_list:
			if type(layer) == c4d.documents.LayerObject:
				doc.SetSelection(layer, mode=c4d.SELECTION_SUB)

	def activate_none_layers(self):
		tools = Tools()
		tools.hide_all_layers()

	def activate_all_layers(self):
		tools = Tools()
		tools.show_all_layers()

	def activate_layer_set(self):
		doc = documents.GetActiveDocument()
		layer_set_selected = 0
		try:
			layer_set_selected = self.GetInt32(CMBOBOX)
			pass
		except Exception as e:
			layer_set_selected = self.GetLong(CMBOBOX)
			pass

		# prevent user from turning off all the layers if no layer set exists at combo box id
		try:
			self.layer_sets_array[layer_set_selected]
		except IndexError as e:
			print( "no layer set exists at combo box id " + str(layer_set_selected) )
			return

		tools = Tools()
		tools.hide_all_layers()

		for item in self.layer_sets_array[layer_set_selected][1]:
			tmp_layer = tools.get_layer( item )
			if not tmp_layer == None:
				layer_data = tmp_layer.GetLayerData(doc)
				layer_data['view'] = True
				layer_data['render'] = True
				tmp_layer.SetLayerData(doc,layer_data)
				c4d.EventAdd()

	def remove_layer_set(self):
		layer_set_selected = -1
		try:
			layer_set_selected = self.GetInt32(CMBOBOX)
			pass
		except Exception as e:
			layer_set_selected = self.GetLong(CMBOBOX)
			pass

		if layer_set_selected > -1:
			self.layer_sets_array.pop( layer_set_selected )
			
			# update the db 
			self.database_file = open( self.database_file_path, 'r+')
					
			with self.database_file as f: 
				f.seek(0)
				f.truncate()
				f.write( repr(self.layer_sets_array) )

			# refresh the dropdown	
			self.populate_layer_combobox()
			self.SetInt32(CMBOBOX, 0)
			c4d.EventAdd()

	def fix_dupe_layer_names(self):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_list_1 = list(ObjectIterator(root))
		layer_list_2 = list(ObjectIterator(root))

		# tmp_list = []
		index = 0

		for layer in layer_list_1:
			for new_search_layer in layer_list_2:
				if type(layer) == c4d.documents.LayerObject and type(new_search_layer) == c4d.documents.LayerObject:
					if layer.GetName() == new_search_layer.GetName() and layer != new_search_layer:
						# if ( not layer.GetName() in tmp_list  ):
						# tmp_list.append( layer.GetName() )
						# layer_data = layer.GetLayerData(doc)
						layer.SetName( layer.GetName() + "_dupe_" + str(index)   )
						# tmp_layer.SetLayerData(doc,layer_data)
						index += 1
						c4d.EventAdd()

		# reset the report text field and run the report again
		self.SetString(LBL_INFO5, "")
		self.report_dupe_layer_names()

	def report_dupe_layer_names(self):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_list_1 = list(ObjectIterator(root))
		layer_list_2 = list(ObjectIterator(root))

		tmp_list = []

		for layer in layer_list_1:
			for new_search_layer in layer_list_2:
				if type(layer) == c4d.documents.LayerObject and type(new_search_layer) == c4d.documents.LayerObject:
					if layer.GetName() == new_search_layer.GetName() and layer != new_search_layer:
						if ( not layer.GetName() in tmp_list  ):
							tmp_list.append( layer.GetName() )

		# self.SetString(LBL_INFO5, "Duplicate named layers: " + ', '.join(map(str, tmp_list)))
		self.SetString(LBL_INFO5, "Found " + str(len(tmp_list)) + " duplicate named layers in this scene. \n" + str(tmp_list))
		# print("duplicate named layers: ")
		# print(tmp_list)

	def open_database(self):
		file_path = c4d.storage.LoadDialog(c4d.FILESELECTTYPE_ANYTHING, title="Open a database", force_suffix="txt")
		txt_file = open(file_path,'r+')
		self.database_file_path = file_path
		self.database_file = txt_file
		# display the short path
		#self.SetString(LBL_DB_NAME, self.get_short_name_from_path(file_path))
		# display the full path
		self.SetString(LBL_DB_NAME, file_path)
		self.populate_layer_combobox()
		self.update_previous_database_list(file_path)

	def create_database(self):
		file_path = c4d.storage.SaveDialog(c4d.FILESELECTTYPE_ANYTHING, title="Create a database (this is simply a text file)", force_suffix="txt")
		txt_file = open(file_path,'w+')
		self.database_file_path = file_path
		self.database_file = txt_file
		# display the short path
		#self.SetString(LBL_DB_NAME, self.get_short_name_from_path(file_path))
		# display the full path
		self.SetString(LBL_DB_NAME, file_path)
		self.update_previous_database_list(file_path)

	def refresh_list_of_visible_layers(self):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_iterator = ObjectIterator(root)

		self.list_of_visible_layers = []
		for layer in layer_iterator:
			if type(layer) == c4d.documents.LayerObject:
				layer_data = layer.GetLayerData(doc)
				if (layer_data["view"]):
					self.list_of_visible_layers.append( layer.GetName() )
		
	def read_database_into_array(self):
		self.database_file = open( self.database_file_path, 'r+')
		tmp_list = []
		with self.database_file as f:
			f.seek(0)
			tmp_string = f.read()
			if tmp_string != "":
				tmp_list = eval(tmp_string)

		return list(tmp_list)

	def update_database(self):
		self.refresh_list_of_visible_layers()
		tmp_list = self.read_database_into_array()

		if len(tmp_list) > 0: # if there is anything in the DB, loop it
			match_found = False
			for item in tmp_list:
				if item[0] == self.layer_set_name: # this updates if key is found
					self.feedback_message = 'Layer name already exists, will overwrite.'
					match_found = True
					item[1] = self.list_of_visible_layers
					
					self.database_file = open( self.database_file_path, 'r+')
					
					with self.database_file as f: 
						f.seek(0)
						f.truncate()
						f.write( repr(tmp_list) )
						# f.write( "['" + self.layer_set_name + "'," + repr(tmp_list)  + "],")

			if match_found == False:
				# append to our DB
				foo = [self.layer_set_name, self.list_of_visible_layers]
				tmp_list.append( foo )

				self.database_file = open( self.database_file_path, 'r+')
				with self.database_file as f: 
					f.seek(0)
					f.truncate()
					f.write( repr(tmp_list) )

				self.feedback_message = "Added a new entry."

		else: # just write out the existing list to the file
			self.write_new_layer_to_new_list()

	def write_new_layer_to_new_list(self):
		self.database_file = open( self.database_file_path, 'r+')
		with self.database_file as f: 
			f.seek(0)
			f.truncate()
			f.write( "['" + self.layer_set_name + "'," + repr(self.list_of_visible_layers)  + "],")
		self.feedback_message = "Database was empty, added first entry."

	def add_child_element(self, pComboBox, pItem):
		self.AddChild(pComboBox, pItem, pItem)

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

class Tools:

	def __init__(self):
		self.sizingList = "asdf" 

	def make_some_layers(self):
		for x in range(0, 100):
			for y in range(0,2):
				self.create_layer("foo"+str(x), c4d.Vector(123,145,0))

	def create_layer(self, pName, pColor):
		layer = c4d.documents.LayerObject()
		layer[c4d.ID_LAYER_COLOR] = pColor
		layer.SetName(pName)
		layerRoot = doc.GetLayerObjectRoot()
		layer.InsertUnder(layerRoot)
		c4d.EventAdd()

	def create_layer_from_dict(self, pName, pDict):
		layer = c4d.documents.LayerObject()
		layer.SetName(pName)
		layerRoot = doc.GetLayerObjectRoot()
		layer.InsertUnder(layerRoot)
		layer.SetLayerData(doc, pDict)
		c4d.EventAdd()

	def get_layer(self, pName):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_iterator = ObjectIterator(root)

		for layer in layer_iterator:
			if type(layer) == c4d.documents.LayerObject:
				name = layer.GetName()
				if (pName == name):
					return layer
		return None


	def hide_all_layers(self):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_iterator = ObjectIterator(root)

		for layer in layer_iterator:
			if type(layer) == c4d.documents.LayerObject:
				layer_data = layer.GetLayerData(doc)
				layer_data['view'] = False
				layer_data['render'] = False
				layer.SetLayerData(doc, layer_data)
				c4d.EventAdd()

		return None

	def show_all_layers(self):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_iterator = ObjectIterator(root)


		for layer in layer_iterator:
			if type(layer) == c4d.documents.LayerObject:
				layer_data = layer.GetLayerData(doc)
				layer_data['view'] = True
				layer_data['render'] = True
				layer.SetLayerData(doc, layer_data)
				c4d.EventAdd()

		return None

	def send_object_to_layer(self, pObj, pLayerName):
		pObj[c4d.ID_LAYER_LINK] = self.get_layer(pLayerName)
		c4d.EventAdd()
		return True


class LayerStateManagerLauncher(c4d.plugins.CommandData):
    dialog = None

    def Execute(self, doc):
        if self.dialog is None:
            self.dialog = LayerStateManager()

        return self.dialog.Open(dlgtype=c4d.DLG_TYPE_ASYNC, pluginid=PLUGIN_ID, defaultw=250, defaulth=500)

    def RestoreLayout(self, sec_ref):
        if self.dialog is None:
            self.dialog = LayerStateManager()

        return self.dialog.Restore(pluginid=PLUGIN_ID, secret=sec_ref)


# uncomment this for production use as a plug-in
if __name__ == "__main__":
	plugins.RegisterCommandPlugin(id=PLUGIN_ID, str="Layer State Manager",
								 help="Tool to create layer states that store the visibility/render of sets of layers.",
								 info=0,
								 dat=LayerStateManagerLauncher(),
								 icon=bitmaps.InitResourceBitmap(c4d.Oplatonic))


# uncomment everything below this line for testing as a standalone script
# ------------------------------------
# def Main():

# 	# --------------------------------------------------------------------
# 	# general setup stuff
# 	doc = c4d.documents.GetActiveDocument()
# 	# root = doc.GetLayerObjectRoot()
# 	# layers = root.GetChildren()
# 	# layer_iterator = ObjectIterator(root)
# 	# for item in layer_iterator:
# 	# 	print(item)
# 	t = Tools()
# 	# t.make_some_layers()

# 	c4d.CallCommand(13957, 13957) # Clear Console
# 	doc.StartUndo()

# 	dlg = LayerStateManager()
# 	# dlg.Open(c4d.DLG_TYPE_MODAL,1234, defaultw=DIALOG_WIDTH, defaulth=200)
# 	dlg.Open(c4d.DLG_TYPE_ASYNC,1234, defaultw=DIALOG_WIDTH, defaulth=50)
# 	tmpDict = {"f": 0}
# 	try:
# 		dlg.Restore(1234, tmpDict)
# 	except SystemError as e:
# 		dlg.Restore(1234, tmpDict)

# 	if not dlg.ok:
# 		return

# 	# --------------------------------------------------------------------
# 	# the end
# 	doc.EndUndo()
# 	c4d.EventAdd()

# if __name__=='__main__':
# 	Main()	