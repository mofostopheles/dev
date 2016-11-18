from mcpi import minecraft
import math
import random

mc = minecraft.Minecraft.create()
mc.postToChat('mindcraft')


x, y, z = mc.player.getPos()


stone = 1
grass = 2
fence = 85
air = 0
glowstone = 89
netherack = 87
gridwidth = 15
newz=0
newx = 0


##make a road...
for x1 in range(0, 200):
        mc.setBlock(x+x1, y, z, stone)
        mc.setBlock(x+x1, y, z+1, stone)
        mc.setBlock(x+x1, y, z-1, stone)

        mc.setBlock(x+x1, y+1, z+1, fence)
        mc.setBlock(x+x1, y+1, z-1, fence)

##create little side gardens every 17th block
        if x1 % 17 == 0:
                mc.setBlock(x+x1, y, z+2, grass)
                mc.setBlock(x+x1+1, y, z+2, grass)
                mc.setBlock(x+x1+2, y, z+2, grass)
                mc.setBlock(x+x1+3, y, z+2, grass) 
                mc.setBlock(x+x1+4, y, z+2, grass)
                mc.setBlock(x+x1+2, y, z+3, grass)
                mc.setBlock(x+x1+3, y, z+3, grass)

##this will erase the fence at these spots
                mc.setBlock(x+x1, y+1, z+1, air)
                mc.setBlock(x+x1-1, y+1, z+1, air)
                mc.setBlock(x+x1-2, y+1, z+1, air)
                mc.setBlock(x+x1-3, y+1, z+1, air)
                

##add some grass...
                mc.setBlock(x+x1+2, y+1, z+3, grass) 
                mc.setBlock(x+x1+3, y+1, z+3, grass)

##make a column torch thing with some blocks
                for t1 in range(0, 4):
                        mc.setBlock(x+x1+2, y+t1, z+4, stone)
                        mc.setBlock(x+x1+3, y+t1, z+4, stone)
                        
##put something special on top
                mc.setBlock(x+x1+2, y+4, z+4, glowstone)
                mc.setBlock(x+x1+3, y+4, z+4, glowstone)
                
##add a torch or something every 11th block
        if x1 % 11 == 0:
                mc.setBlock(x+x1, y, z-2, stone)
                mc.setBlock(x+x1, y, z-3, stone)
                mc.setBlock(x+x1, y+1, z-3, stone)
                mc.setBlock(x+x1, y+2, z-3, stone)
                mc.setBlock(x+x1, y+3, z-3, glowstone)

                
