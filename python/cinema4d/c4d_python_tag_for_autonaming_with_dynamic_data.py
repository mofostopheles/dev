#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1"
__email__ = "arloemerson@gmail.com"

'''
    2/21/2020

    This script lives as a tag on a sweep object.
    Look at Laser Outro C4D file for working example.

    When the sweep hits 100%, append/rename the connections
    so they include the frame number. This frame number
    can be used in After Effects to set frame when flares appear.
'''

import c4d, math
animation_complete = False
animation_started = False
start_frame = 0
end_frame = 0

def main():
    global animation_complete, animation_started, start_frame, end_frame

    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    if frame == 178:
        animation_complete = False
        animation_started = False

    if ((op.GetObject()[c4d.SWEEPOBJECT_GROWTH] > 0.0) and (animation_started == False)):
        animation_started = True
        start_frame = frame
        #print('started')

    if ((op.GetObject()[c4d.SWEEPOBJECT_GROWTH] == 1.0) and (animation_complete == False)):
        animation_complete = True
        end_frame = frame
        #print('done')

        connection_B = op.GetObject().GetNext().GetDown()
        connection_A = op.GetObject().GetNext().GetDown().GetNext()

        if "connection_B" in connection_B.GetName():
            new_name = "connection_B: " + str(start_frame) + "-" + str(end_frame)
            connection_B.SetName( new_name )

            for t in connection_B.GetTags(): # loop the object's tags and find the external compositing tag
                if type(t).__name__ == 'BaseTag':
                    t[c4d.ID_BASELIST_NAME] = new_name

        if "connection_A" in connection_A.GetName():
            new_name = "connection_A: " + str(start_frame) + "-" + str(end_frame)
            connection_A.SetName( new_name )

            for t in connection_A.GetTags():
                if type(t).__name__ == 'BaseTag':
                    t[c4d.ID_BASELIST_NAME] = new_name





    c4d.EventAdd()
