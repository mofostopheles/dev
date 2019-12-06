#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

'''
	• An iterator that takes an object in the constructor, providing all the children of this object only.
	• Import as a module...

	# example usage:
	import branch_iterator as branch

	doc = docs.GetActiveDocument()
	first_item = doc.SearchObject("some_container")

	tree = branch.BranchIterator(first_item)

	for item in tree:
		if item.GetName() == "something_nested":
			print("hi")
		print(item)

'''

from c4d import documents as docs

class BranchIterator:
	def __init__(self, p_base_object):
		self.p_base_object = p_base_object
		self.current_object = p_base_object
		self.object_stack = []
		self.depth = 0
		self.next_depth = 0

	def __iter__(self):
		return self

	def next(self):
		if self.current_object == None or self.current_object == self.p_base_object.GetNext():
			raise StopIteration

		obj = self.current_object
		self.depth = self.next_depth

		child = self.current_object.GetDown()
		if child:
			self.next_depth = self.depth + 1
			self.object_stack.append(self.current_object.GetNext())
			self.current_object = child
		else :
			self.current_object = self.current_object.GetNext()
			while( self.current_object == None and len(self.object_stack) > 0 ) :
				self.current_object = self.object_stack.pop()
				self.next_depth = self.next_depth - 1
		return obj


# example usage:
# doc = docs.GetActiveDocument()
# first_item = doc.SearchObject("some_container")

# tree = BranchIterator(first_item)

# for item in tree:
# 	if item.GetName() == "something_nested":
# 		print("hi")
# 	print(item)