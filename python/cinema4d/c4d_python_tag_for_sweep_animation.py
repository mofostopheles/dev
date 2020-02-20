#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "5"
__email__ = "arloemerson@gmail.com"

'''
    2/19/2020

    This script lives as a tag on a sweep object.
    Look at Laser Outro C4D file for working example.
    Variations are also found in sweep_speed_control_test.c4d

    The sweep uses a tracer with two nulls.
    The script has user data containing:
    sweep_increment_amount (float)
    animation_start (int)
    persist_beam (float)
    length (float)

    Note: if you want to reverse the direction of the beam,
    go to the tracer and click "Reverse Sequence"
'''

import c4d, math
frame_counter = 0

# SWEEP STUFF
animating = False
end_counter = 0.0
start_counter = 0.0

# RESET
op.GetObject()[c4d.SWEEPOBJECT_STARTGROWTH]=0
op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=0

def main():
    global frame_counter, animating, end_counter, start_counter
    persist_beam = bool( op[c4d.ID_USERDATA, 4] )
    animation_start = op[c4d.ID_USERDATA, 2]
    increment_amount = op[c4d.ID_USERDATA, 1]
    timeline_start  = op[c4d.ID_USERDATA, 3]
    length = op[c4d.ID_USERDATA, 5]

    print(increment_amount)
    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    # increment the frame counter
    frame_counter += 1

    # SWEEP ANIMATION
    if frame < timeline_start:
        end_counter = 0.0
        start_counter = 0.0
        animating = False
        op.GetObject()[c4d.SWEEPOBJECT_STARTGROWTH]=start_counter
        op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=end_counter

    if frame == animation_start:
        animating = True

    if animating == True:

        if persist_beam == False:
            op.GetObject()[c4d.SWEEPOBJECT_STARTGROWTH]=start_counter

        op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=end_counter

        end_counter += increment_amount

        if end_counter >= length:
            start_counter += increment_amount

        if start_counter >= (1.0 + increment_amount):
            end_counter = 0.0
            start_counter = 0.0
            animating = False

    c4d.EventAdd()
