import c4d, math
from random import randint

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"

# A simple script to automatically grow a sweep using:
#    - starting frame number
#    - amount to grow
# NOTE: this is a C4D tag

animating = False
end_counter = 0.0
increment_amount = op[c4d.ID_USERDATA, 2] # e.g. 0.03
frame_number_start = op[c4d.ID_USERDATA, 6] # e.g. 5
slaved_sweep = op[c4d.ID_USERDATA, 1] # another sweep that grows at the same rate
frame_zero = op[c4d.ID_USERDATA, 3] # used for resetting script, typically 0 but other numbers can be used

# reset
op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=0

def main():
    global animating, end_counter, slaved_sweep, frame_number_start, increment_amount, frame_zero

    # the frame number we are on
    frame=doc.GetTime().GetFrame(doc.GetFps())

    # reset
    if frame <= frame_zero:
        end_counter = 0.0
        animating = False
        op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=0
        slaved_sweep[c4d.SWEEPOBJECT_GROWTH]=0

    # trigger based on frame number
    if frame == frame_number_start:
        animating = True

    # animate
    if animating == True:
        op.GetObject()[c4d.SWEEPOBJECT_GROWTH]=end_counter
        slaved_sweep[c4d.SWEEPOBJECT_GROWTH]=end_counter
        end_counter += increment_amount

    c4d.EventAdd()