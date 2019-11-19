#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

import c4d, math


def valmap(value, istart, istop, ostart, ostop):
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))

def main():
    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    # modifier based on sine
    step_amount = 24
    sweeping_formula = (frame*math.pi)/step_amount
    sin_mod = math.cos(  sweeping_formula  )
    remapped = valmap( sin_mod, 0, 1, 0, 0.15  ) 

    for t in op.GetObject().GetTags(): # loop the object's tags and find the vibrate
        if t.GetName() == 'Vibrate':
            t[c4d.VIBRATEEXPRESSION_ROT_AMPLITUDE] = c4d.Vector(0,0,remapped)