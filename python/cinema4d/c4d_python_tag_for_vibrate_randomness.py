#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

import c4d

def main():
    
    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    for t in op.GetObject().GetTags(): # loop the object's tags 
        if t.GetName() == 'Vibrate':
            #t.GetMaterial()[c4d.OCT_MATERIAL_EMISSION][c4d.BBEMISSION_EFFIC_OR_TEX][c4d.RGBSPECTRUMSHADER_COLOR] = new_vector 
            if frame % 7 == 0:          
                t[c4d.VIBRATEEXPRESSION_REGULAR] = True
            else:
                t[c4d.VIBRATEEXPRESSION_REGULAR] = False