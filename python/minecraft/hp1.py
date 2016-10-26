from mcpi import minecraft
import math
import random

mc = minecraft.Minecraft.create()
mc.postToChat('Hi Hans!!!')
x, y, z = mc.player.getPos()
##x = -63.6
##y = 3.0
##z = 1.9

air = 0
stone = 1
grass = 2
dirt = 3
wool = 35


for z1 in range(0, 10):
        for x1 in range (0, 10):
##                myRand = random.random()
##                myRand = math.floor( myRand * 10 )
##                mc.setBlock(x+x1, y, z+z1, x1, 1)
                
                for y1 in range (0, 10):
                        newRand = random.random()
                        newRand = math.floor( newRand * 2)
                        mc.setBlock(x+x1, y+y1, z+z1, x1, 1)
