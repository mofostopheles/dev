#!/usr/bin/env python
# -*- coding: utf8 -*-

import c4d, math

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

# -----------------------------------------------
'''
	About this script:
	• Loops ALL splines within a top level spline (nest them under "SPLINE_1" and/or "SPLINE_2").
	• Will build a hierarchy of splines based on 1st vertex proximity to any other spline's vertex
'''
# -----------------------------------------------


# -----------------------------------------------
# globals
# -----------------------------------------------
proximity_threshold = 50.0 # adjust to taste, this number will vary depending on things like project scale

# -----------------------------------------------
# object iterator, just pass in a root of any collection and iterate
# -----------------------------------------------
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
		if child:
			self.next_depth = self.depth + 1
			self.object_stack.append(self.current_object.GetNext())
			self.current_object = child
		else:
			self.current_object = self.current_object.GetNext()
			while( self.current_object == None and len(self.object_stack) > 0 ) :
				self.current_object = self.object_stack.pop()
				self.next_depth = self.next_depth - 1
		return obj


def nest_splines():
	# -----------------------------------------------
	# we only need hard code the names of the top level splines
	# the names of child splines are not important, but you need to enter the two top-level splines here
	# -----------------------------------------------
	list_of_top_level_splines = ["SPLINE_1"]
	# list_of_top_level_splines = ["spline_1", "spline_2"]

	hit_count = 0
	# -----------------------------------------------
	for s in list_of_top_level_splines:

		level_1_spline = doc.SearchObject(s)

		if len( level_1_spline.GetChildren() ) >= 1:
			master_list_of_children = level_1_spline.GetChildren()
			for j in range( 0, len(master_list_of_children) ):
				# we can't just loop the top level spline's children directly, because down below we'll be changing that hierarchy, moving things around

				child_spline = master_list_of_children[j]

				# get location of 1st vertex only
				collision_point = child_spline.GetPoint( 0 )
				child_vector = c4d.Vector( collision_point.x, collision_point.y, collision_point.z ) * child_spline.GetMg()
				child_matrix = c4d.Matrix( child_vector, c4d.Vector(1, 0, 0), c4d.Vector(0, 1, 0), c4d.Vector(0, 0, 1)  )
				
				# ---------------------------------------------------------
				# this little section we don't need to perform, keeping it in case we refactor
				# loop top level spline vertices first
				# for v in range (0, len( level_1_spline.GetAllPoints() )-1 ):

				# 	spline_point = level_1_spline.GetPoint(v)
				# 	spline_vector = c4d.Vector( spline_point.x, spline_point.y, spline_point.z ) * level_1_spline.GetMg()
				# 	spline_matrix = c4d.Matrix( spline_vector, c4d.Vector(1, 0, 0), c4d.Vector(0, 1, 0), c4d.Vector(0, 0, 1)  )

				# 	proximity_x = abs( spline_matrix.off.x - child_matrix.off.x )
				# 	proximity_y = abs( spline_matrix.off.y - child_matrix.off.y )
				# 	proximity_z = abs( spline_matrix.off.z - child_matrix.off.z )

				# 	if test_proximity(proximity_x, proximity_y, proximity_z) == True:
				# 		hit_count += 1
				# 		child_spline.InsertUnder(level_1_spline) # it already is a child in this design
				# 		c4d.EventAdd()
				# 		break
				# ---------------------------------------------------------

				# loop all other splines, other than the child we are on
				for c in range( 0, len(master_list_of_children) ):
					other_child_spline = master_list_of_children[c]
					
					if child_spline != other_child_spline:

						# loop the points in the other child spline
						for cp in range (0, len( other_child_spline.GetAllPoints() )-1 ):

							other_collision_point = other_child_spline.GetPoint( cp )
							other_child_vector = c4d.Vector( other_collision_point.x, other_collision_point.y, other_collision_point.z ) * other_child_spline.GetMg()
							other_child_matrix = c4d.Matrix( other_child_vector, c4d.Vector(1, 0, 0), c4d.Vector(0, 1, 0), c4d.Vector(0, 0, 1)  )

							proximity_x = abs( other_child_matrix.off.x - child_matrix.off.x )
							proximity_y = abs( other_child_matrix.off.y - child_matrix.off.y )
							proximity_z = abs( other_child_matrix.off.z - child_matrix.off.z )

							if test_proximity(proximity_x, proximity_y, proximity_z) == True:
								hit_count += 1
								child_spline.InsertUnder(other_child_spline)
								c4d.EventAdd()
								break


	print("found a home for " + str(hit_count) + " splines.")

# collision box hit test
# returns true if proximity args are within the threshold
def test_proximity(p_proximity_x, p_proximity_y, p_proximity_z):
    global proximity_threshold

    # print(p_proximity_x, p_proximity_y, p_proximity_z)

    if p_proximity_x <= proximity_threshold and \
    p_proximity_y <= proximity_threshold and \
    p_proximity_z <= proximity_threshold:
        return True
    else:
        return False

def main():
	nest_splines()

# workaround so we can edit in sublime but run in C4D's script manager
main()