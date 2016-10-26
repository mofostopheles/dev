from mcpi import minecraft
import math
import random

mc = minecraft.Minecraft.create()
mc.postToChat('Hi Hans!!!')

##mc.player.setPos(-63.6, 3.0, 1.9)

x, y, z = mc.player.getPos()

##x = -63.6
##y = 3.0
##z = 1.9

air = 0
stone = 1
grass = 2
dirt = 3
wool = 35
tnt = 46
lava = 10 
water = 8
river = 9
reactor = 247
ice = 79
snowblock = 80
snow = 78
gold = 41
glass = 20

for z1 in range(0, 20):
        newRand = random.random()
        newRand = math.floor( newRand * 2)
        for x1 in range (0, int(10+newRand)):
                newRand2 = random.random()
                newRand2 = math.floor( newRand2 * 2)
                for y1 in range (0, int(3+newRand2)):
                        if x1 % 2 == 0:                        
                                mc.setBlock(x+x1, y+y1, z+z1, ice, 1)
                        else:
                                mc.setBlock(x+x1, y+y1, z+z1, stone, 1)
                        if x1 % 3 == 0:
                                mc.setBlock(x+x1, y+y1, z+z1, snow, 1)
                        if y1 % 5 == 0:
                                mc.setBlock(x+x1, y+y1, z+z1, water, 1)
                        if y1 % 3 == 0:
                                mc.setBlock(x+x1, y+y1, z+z1, 37, 1)                        
