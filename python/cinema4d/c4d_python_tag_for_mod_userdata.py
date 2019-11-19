#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

import c4d, math

# frame-number driven color driver
def main():

    # this is the base color we will manipulate
    base_color_vector = op[c4d.ID_USERDATA, 1]

    # collect the checkbox states
    # if any of them are checked we need need to use the sine mod in that part of the vector
    affect_R = op[c4d.ID_USERDATA, 3]
    affect_G = op[c4d.ID_USERDATA, 4]
    affect_B = op[c4d.ID_USERDATA, 5]
    step_amount = op[c4d.ID_USERDATA, 6]

    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    # modifier based on sine
    sweeping_formula = (frame*math.pi)/step_amount
    sin_mod = math.sin(  sweeping_formula  )
    #print(sin_mod)

    # set the intial values
    red_value = base_color_vector[0]
    green_value = base_color_vector[1]
    blue_value = base_color_vector[2]

    if affect_R:
        red_value = abs(sin_mod)
    if affect_G:
        green_value = abs(sin_mod)
    if affect_B:
        blue_value = abs(sin_mod)

    # set the new color
    new_vector = c4d.Vector( red_value, green_value, blue_value )

    # update the user data
    op[c4d.ID_USERDATA,2] = new_vector

    for t in op.GetObject().GetTags(): # loop the object's tags and find the texture
        if type(t).__name__ == 'TextureTag':
            t.GetMaterial()[c4d.OCT_MATERIAL_EMISSION][c4d.BBEMISSION_EFFIC_OR_TEX][c4d.RGBSPECTRUMSHADER_COLOR] = new_vector