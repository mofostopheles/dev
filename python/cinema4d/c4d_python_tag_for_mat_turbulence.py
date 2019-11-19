#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

import c4d, math

# modify the turbulence of the gradient
def main():
    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())
    step_amount = op[c4d.ID_USERDATA, 1] # 8 works good
    ceiling = op[c4d.ID_USERDATA, 2] # 32 works good

    # modifier based on sine
    sweeping_formula = (frame*step_amount)
    sin_mod = math.sin(  sweeping_formula  )
    turb_amount =  abs(sin_mod)/ceiling
   
    for t in op.GetObject().GetTags(): # loop the object's tags and find the texture
        if type(t).__name__ == 'TextureTag':
            t.GetMaterial()[c4d.OCT_MATERIAL_OPACITY_LINK][c4d.SLA_GRADIENT_TURBULENCE] = turb_amount