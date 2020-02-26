#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"
__date__ = "2/26/2020"

# -----------------------------------------------------------------------------
# Builds lists of x,y,z data for an object.
# These lists can be used in matplotlib for plotting the same object.
#
# Example matplotlib script:
#
# from mpl_toolkits.mplot3d import Axes3D
# import matplotlib.pyplot as plt
#
# fig = plt.figure()
# ax = fig.add_subplot(111, projection='3d')
#
# x = [-100.0, -100.0, 100.0, 100.0, 100.0, 100.0, -100.0, -100.0]
# y = [-100.0, 100.0, -100.0, 100.0, -100.0, 100.0, -100.0, 100.0]
# z = [-100.0, -100.0, -100.0, -100.0, 100.0, 100.0, 100.0, 100.0]
#
# ax.scatter(x, y, z, c='r', marker='o')
#
# ax.set_xlabel('X Label')
# ax.set_ylabel('Y Label')
# ax.set_zlabel('Z Label')
#
# plt.show()
#
# -----------------------------------------------------------------------------

import c4d

def main():
		# This code goes on a Python tag set on an object

    obj = op.GetObject()
    pp = obj.GetAllPoints()

    x_list = []
    y_list = []
    z_list =[]

    for p in pp:
        x_list.append( p.x )
        y_list.append( p.y )
        z_list.append( p.z )

    print_lists(x_list, y_list, z_list)

def print_lists(x_list, y_list, z_list):

	print( 'x = ' + str(x_list) )
	print( 'y = ' + str(y_list) )
	print( 'z = ' + str(z_list) )
