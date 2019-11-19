#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

import c4d, math

frame_counter = 0
knot_index = 0

# frame-number driven color driver
def main():
    global frame_counter, knot_index

    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    # increment the frame counter
    frame_counter += 1

    # number of frames to spend on a chip
    frames_per_color = op[c4d.ID_USERDATA, 6]

    knot_count = op[c4d.ID_USERDATA, 3].GetKnotCount()

    # set up the variable for the color
    current_knot_color = c4d.Vector(0)

    if frame_counter >= frames_per_color:
        frame_counter = 0

        if knot_index < knot_count-1:
            knot_index += 1
        else:
            knot_index = 0
        current_knot_color = op[c4d.ID_USERDATA, 3].GetKnot(knot_index)['col']
        op[c4d.ID_USERDATA, 1] = current_knot_color
        

    for t in op.GetObject().GetTags(): # loop the object's tags and find the texture
        if type(t).__name__ == 'TextureTag':
            t.GetMaterial()[c4d.OCT_MATERIAL_EMISSION][c4d.BBEMISSION_EFFIC_OR_TEX][c4d.RGBSPECTRUMSHADER_COLOR] = current_knot_color
