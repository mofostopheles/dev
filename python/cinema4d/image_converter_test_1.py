import c4d
from c4d import gui, plugins
from random import *
import sys
import Image


def main():
    print( sys.path )
    #D:\\_projects\\iot\\wristwatch_concepting\\art\\brazil.png
    im = Image.open("D:\\_projects\\iot\\wristwatch_concepting\\art\\brazil.png")
    im = im.convert()
    seq = im.getdata()
    print( im )

if __name__=='__main__':
    main()
