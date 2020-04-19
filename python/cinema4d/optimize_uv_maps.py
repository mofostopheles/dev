# -*- coding: utf8 -*-

'''
	• Optimizes UVs of selected meshes
	• reference: http://www.plugincafe.com/forum/forum_posts.asp?TID=13406
'''

import c4d, math
from c4d import utils, documents
from c4d.modules import bodypaint

class UVOptimizer():

	def __init__(self):
		print('hello')

	def applyRealign(self, doc, obj):

 		doc.SetActiveObject(obj)
		c4d.EventAdd()

		# Retrieves active UVSet
		handle = bodypaint.GetActiveUVSet(doc, c4d.GETACTIVEUVSET_ALL)
		if not handle:
				print "No active UVSet!"
				return

		settings = c4d.BaseContainer()
		settings[c4d.OPTIMALMAPPING_PRESERVEORIENTATION] = False
		settings[c4d.OPTIMALMAPPING_STRETCHTOFIT] = False
		settings[c4d.OPTIMALMAPPING_EQUALIZEAREA] = True
		settings[c4d.OPTIMALMAPPING_SPACING] = 0.02

		# Retrieves UVW list
		uvw = handle.GetUVW()
		if uvw is None:
				return

		# Calls UVCOMMAND_TRANSFORM to change UVW list
		ret = bodypaint.CallUVCommand(handle.GetPoints(), handle.GetPointCount(), handle.GetPolys(), handle.GetPolyCount(), uvw,
																	handle.GetPolySel(), handle.GetUVPointSel(), obj, handle.GetMode(), c4d.UVCOMMAND_OPTIMALCUBICMAPPING, settings)
		if not ret:
				print "CallUVCommand() failed!"
				return

		print "CallUVCommand() successfully called"

		# Sets the transformedUVW from Texture View
		if handle.SetUVWFromTextureView(uvw, True, True, True):
				print "UVW from Texture View successfully set"
		else:
				print "UVW from Texture View failed to be set!"

		# Releases active UVSet
		bodypaint.FreeActiveUVSet(handle)

	def run(self):
		selection = doc.GetActiveObjects(c4d.GETACTIVEOBJECTFLAGS_CHILDREN)

		if len(selection) <= 0:
				print('Please select objects.')
				return

		for obj in selection:
			self.applyRealign(doc, obj)

WORKER = UVOptimizer()
WORKER.run()
