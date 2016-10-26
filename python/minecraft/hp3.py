from mcpi import minecraft
import math
import random

mc = minecraft.Minecraft.create()
mc.postToChat('life is good')

##mc.player.setPos(-63.6, 3.0, 1.9)

x, y, z = mc.player.getPos()

y = 0

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
cactus = 81
mushroom = 39
flower_yellow = 37
tall_grass= 31
glowing_obsidian = 246
sand = 12
bedrock = 7
brick = 45

finalX = 0
finalZ = 0
for z1 in range(0, 10):
        newRand = random.random()
        newRand = math.floor( newRand * 40)
        for x1 in range (0, int(10+newRand)):
                newRand2 = random.random()
                newRand2 = math.floor( newRand2 * 3)
                tmpLimit = int(newRand+newRand2 * 5)
                for y1 in range (0, tmpLimit):
                        if y1 < 3:
                                mc.setBlock(x+x1, y+y1, z+z1, stone)
                        elif y1 == 3:
                                mc.setBlock(x+x1, y+y1, z+z1, sand)
                        elif y1 > 3 and y1 < 6:
                                mc.setBlock(x+x1, y+y1, z+z1, 44)
                        else:
                                mc.setBlock(x+x1, y+y1, z+z1, snow)
                        
                        
                        if y1 % 2 == 0:
                                mc.setBlock(x+x1+math.floor( newRand2 * 1.3), y+y1, z+z1+1, lava)
                                mc.setBlock(x+x1+math.floor( newRand2 * 1.4), y+y1+1, z+z1+1, stone)
                                mc.setBlock(x+x1+math.floor( newRand2 * 1.5), y+y1-3, z+z1+1, bedrock)
                        
                        if y1 == tmpLimit-1:
                                mc.setBlock(x+x1, y+y1+1, z+z1, 56, 1)                                
                                mc.setBlock(x+x1, y+y1+2, z+z1, cactus, 1)
                                if y1 % 2 == 0:
                                        mc.setBlock(x+x1, y+y1+3, z+z1, mushroom)
                                elif y1 % 3 == 0:
                                        mc.setBlock(x+x1, y+y1+3, z+z1, river)
                                else:
                                        mc.setBlock(x+x1, y+y1+3, z+z1, flower_yellow)                        
                if x1 == int(10+newRand):
                        finalX = x1        
        if z1 == 10:
                print('ok')
                for h1 in range(0, 20):
                        mc.setBlock(finalX+5, z+z1 + h1, y+5, brick)
