#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

import c4d, math

frame_counter = 0
array_index = 0

# frame-number driven color driver
def main():
    global array_index, frame_counter
    
    color_chip_1 = op[c4d.ID_USERDATA, 11]
    color_chip_2 = op[c4d.ID_USERDATA, 10]
    color_chip_3 = op[c4d.ID_USERDATA, 9]
    color_chip_4 = op[c4d.ID_USERDATA, 8]
    color_chip_5 = op[c4d.ID_USERDATA, 7]
    color_array = [color_chip_1, color_chip_2, color_chip_3, color_chip_4, color_chip_5]
    
    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())
    
    # increment the frame counter
    frame_counter += 1

    # number of frames to spend on a chip
    frames_per_color = op[c4d.ID_USERDATA, 6]
    
    if frame_counter >= frames_per_color:
        frame_counter = 0
        if array_index < len(color_array):
            array_index += 1
        else:
            array_index = 0
        
        op[c4d.ID_USERDATA, 1] = color_array[array_index]

    for t in op.GetObject().GetTags(): # loop the object's tags and find the texture
        if type(t).__name__ == 'TextureTag':
            t.GetMaterial()[c4d.OCT_MATERIAL_EMISSION][c4d.BBEMISSION_EFFIC_OR_TEX][c4d.RGBSPECTRUMSHADER_COLOR] = color_array[array_index]