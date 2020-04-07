# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

'''
	• Search and replace names of layers.
	• Default is ALL layers will be searched.
	• Use flag in method call to restrict to selected layers only.
'''

import c4d, math, pprint, os
from c4d import bitmaps, plugins, gui, utils, documents

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

class SearchAndReplace():

    def search_for_layer(self, string_find, string_replace ):
		doc = documents.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layer_list = list(ObjectIterator(root))
		items_touched = 0
		for layer in layer_list:
			if type(layer) == c4d.documents.LayerObject:
				if string_find in layer.GetName():
					layer.SetName( layer.GetName().replace(string_find, string_replace) )
					c4d.EventAdd()
					items_touched += 1

		print("Total items touched: " + str(items_touched))

c = SearchAndReplace()
c.search_for_layer( "old-string", "new-string")
