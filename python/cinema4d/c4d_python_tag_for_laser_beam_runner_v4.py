#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "4.0.0"
__email__ = "arloemerson@gmail.com"

'''
    This script lives as a tag on a sweep object.
    The sweep uses a tracer with two nulls.
    The script has user data containing:
    sweep_increment_amount (float)
    random_bias (int)
    ping_pong (bool)
    frame_number_start (int)
    persist_beam (float)
    length (float)
    There is also some legacy gradient reference where the knot color is used to alter the object's material diffuse channel
'''

import c4d, math
from random import randint

frame_counter = 0

# SWEEP STUFF
animating = False
end_counter = 0.0
start_counter = 0.0
increment_amount = op[c4d.ID_USERDATA, 2]
random_bias = op[c4d.ID_USERDATA, 4]
ping_pong = op[c4d.ID_USERDATA, 5]
frame_number_start = op[c4d.ID_USERDATA, 6]
persist_beam = op[c4d.ID_USERDATA, 7]
length = op[c4d.ID_USERDATA, 8]
run_reverse = False
last_run = "forward" # or backward

# RESET
op.GetObject()[c4d.SWEEPOBJECT_STARTGROWTH]=0
op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=0


# COLOR STUFF
knot_index = 0
current_knot_color = op[c4d.ID_USERDATA, 3].GetKnot( 0 )['col']

# frame-number driven color driver
def main():
    global frame_counter, knot_index, current_knot_color, animating, end_counter, start_counter, run_reverse, ping_pong, last_run

    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    # increment the frame counter
    frame_counter += 1

    knot_count = op[c4d.ID_USERDATA, 3].GetKnotCount()
    ping_pong = op[c4d.ID_USERDATA, 5]

    # SWEEP ANIMATION
    if frame == 0:
        end_counter = 0.0
        start_counter = 0.0
        animating = False

    if frame == frame_number_start:
        animating = True
    
    if frame % getRandNum() == 0 and animating == False:
        animating = True

        # set color
        tmpNum = randint(0, knot_count-1)
        randKnotIndex = randint(0, tmpNum)
        current_knot_color = op[c4d.ID_USERDATA, 3].GetKnot( randKnotIndex  )['col']
        op[c4d.ID_USERDATA, 1] = current_knot_color

        for t in op.GetObject().GetTags(): # loop the object's tags and find the texture
            if type(t).__name__ == 'TextureTag':
                t.GetMaterial()[c4d.OCT_MATERIAL_DIFFUSE_COLOR] = current_knot_color

        if ping_pong:
            if last_run == "forward":
                end_counter = 1.0
                start_counter = 1.0
            elif  last_run == "backward":
                end_counter = 0.0
                start_counter = 0.0
    

    if animating == True:

        if persist_beam == False:
            op.GetObject()[c4d.SWEEPOBJECT_STARTGROWTH]=start_counter

        op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=end_counter

        if run_reverse == False:

            end_counter += increment_amount

            if end_counter >= length:
                start_counter += increment_amount

            if start_counter >= (1.0 + increment_amount):
                end_counter = 0.0
                start_counter = 0.0
                animating = False
                run_reverse = True
                last_run = "forward"

        elif run_reverse == True:

            end_counter -= increment_amount

            if end_counter <= (1.0-length):
                start_counter -= increment_amount

            if start_counter <= (0.0 - increment_amount):
                end_counter = 0.0
                start_counter = 0.0
                animating = False
                run_reverse = False
                last_run = "backward"

    c4d.EventAdd()

def getRandNum():
    tmpNum = randint(1, int( random_bias ))
    return tmpNum