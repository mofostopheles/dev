#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

import c4d, math

def main():    
    target_angle = op[c4d.ID_USERDATA, 1]
    step_amount = op[c4d.ID_USERDATA, 2]

    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())
    sin_mod = math.sin( frame  ) * pow( math.pi, 2)
    
    new_angle = sin_mod + target_angle
    new_vector = c4d.Vector(0, 0, new_angle)
    
    op[c4d.ID_USERDATA, 3] = new_vector

    for t in op.GetObject().GetTags(): # loop the object's tags 
        if t.GetName() == 'Vibrate':
            print(new_vector)
            t[c4d.VIBRATEEXPRESSION_ROT_AMPLITUDE] = new_vector
            