# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = 1
__date__ = "06/04/2020"

# ------------------------------------------------------------------------------
# About this script:
# IsolateRendersFromFrames is used to create a project for each keyframe of
# your model. The example scenario is: you have 8 camera angles you have set up,
# each is keyframed, you have one HDRI with keyframes, lights with keyframes.
# So, you want to create a project for each of those shots, and also delete all
# the keyframes so they don't cause the next person any problems. Essentially,
# you are taking a workflow e.g. using animated cameras and lights, and reducing
# each shot to a file. This is helpful if you like working in one file to rule
# all your renders, but are required to hand off dedicated/fixed camera and
# lights in the final project.
#
# This script will:
# 	• Loop all the frames with keyframes e.g. 0 - 8
# 	• Save as a new project with the view number appended (frame number)
# 	• Update each output module render name with the view number (frame number)
#
# For example, if you have a 9 frame project with all these different camera
# angles and whatnot, you will end up with 9 additional projects, each one
# containing the camera (and other objects), with all keyframes blown away.
# It is basically a locked-down scene, one for each keyframe.
# ------------------------------------------------------------------------------

import c4d, math
import branch_iterator as branch

class IsolateRendersFromFrames:

	def __init__(self):
		print('Running ' + self.__class__.__name__)

		self.current_frame_number = 0
		self.project_name = doc.GetDocumentName()
		self.project_name = self.project_name.replace(".c4d", "")
		self.total_keyed_frames = 0
		self.list_of_output_file_names = []
		c4d.CallCommand(12501) # Go to Start

	def cycle_keyed_frames(self):
		self.current_frame_number = doc.GetTime().GetFrame(doc.GetFps())
		c4d.CallCommand(465001541, 465001541) # Timeline (Dope Sheet)...
		# self.current_frame_number += 1
		if self.current_frame_number >= self.total_keyed_frames:
			self.total_keyed_frames += 1

			self.get_render_output_names()
			self.isolate_render_from_frame()
			self.set_up_view_render()

			c4d.CallCommand(465001024) # Go to Next Key
			self.cycle_keyed_frames()

		print("Total number of keyed frames: " + str(self.total_keyed_frames))

	def get_render_output_names(self):
		rd = doc.GetActiveRenderData()
		tree = branch.BranchIterator(rd.GetListHead())
		base_time = c4d.BaseTime(0) # this is used to set the start/end frames to 0

		for item in tree:
			# filter on the RenderData only, we don't want the GetListHead
			if type(item).__name__ == 'RenderData':
				orn = item.GetFirstVideoPost() # this is probably the octane renderer node
				render_file_name = orn[c4d.SET_PASSES_SAVEPATH]
				self.list_of_output_file_names.append(render_file_name)

	# ----------------------------------------------------------------------------
	# main worker
	# ----------------------------------------------------------------------------
	def isolate_render_from_frame(self):
		c4d.CallCommand(465001541, 465001541) # Timeline (Dope Sheet)...
		c4d.CallCommand(465001012) # Select All
		c4d.CallCommand(465001006) # Delete
		doc.SetDocumentName( self.project_name + '_VIEW-' + str(self.current_frame_number) + '.c4d'  )
		c4d.CallCommand(12218) # Save as...
		c4d.CallCommand(12105) # Undo, this will bring back the keyframes

	def set_up_view_render(self):
		rd = doc.GetActiveRenderData()
		tree = branch.BranchIterator(rd.GetListHead())
		base_time = c4d.BaseTime(0) # this is used to set the start/end frames to 0
		index = 0

		for item in tree:
			# filter on the RenderData only, we don't want the GetListHead
			if type(item).__name__ == 'RenderData':
				item[c4d.RDATA_FRAMEFROM] = base_time
				item[c4d.RDATA_FRAMETO] = base_time
				orn = item.GetFirstVideoPost() # this is probably the octane renderer node
				orn[c4d.SET_PASSES_SAVEPATH] = self.list_of_output_file_names[ index ] + '-' + str(self.current_frame_number)
				index += 1
				c4d.EventAdd()

def main():
	worker = IsolateRendersFromFrames()
	worker.cycle_keyed_frames()

# workaround so we can edit in sublime but run in C4D's script manager
main()
