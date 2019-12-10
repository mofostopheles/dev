#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

'''
	• Replace multiple instances of items within a particular branch of the tree.
	• Deletes the replacee
'''

import c4d
from c4d import documents as docs
import branch_iterator as branch

doc = docs.GetActiveDocument()
first_item = doc.SearchObject("some_container")
new_replacement = doc.SearchObject("asdf")
tree = branch.BranchIterator(first_item)
items_to_remove = []

def insert_clones():
	for item in tree:
		if item.GetName() == "something_to_replace":
			new_replacement.GetClone().InsertAfter( item )
			yield item

do_work = insert_clones()

for remove_this in do_work:
	remove_this.Remove()

c4d.EventAdd()