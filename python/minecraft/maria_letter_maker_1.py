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


foopattern = [
         1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,
         1,3,1,1,1,3,1,3,3,2,2,3,3,1,1,3,1,1,1,3,1,1,1,
         1,3,3,1,3,3,1,3,1,3,2,3,2,3,1,3,1,1,3,1,3,1,1,
         1,3,1,3,1,3,1,3,3,3,2,3,3,3,2,3,1,1,3,3,3,1,1,
         1,3,1,1,1,3,1,3,1,3,2,3,3,2,1,3,1,3,1,1,1,3,1,
         1,3,1,1,1,3,3,2,1,3,2,3,2,3,1,3,1,3,1,1,1,3,1,
         1,1,1,1,1,1,1,1,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1
         ]


for foocounter in range(0, len(foopattern)):
        brickType = glowstone
        if (foopattern[foocounter] == 1):
                brickType = netherack
        elif (foopattern[foocounter] == 2):
                brickType = glowstone
        elif (foopattern[foocounter] == 3):
                brickType = 22

        newx = newx + 1      

        if foocounter % 23 == 0:
                brickType = grass
                newz = newz - 1 
                newx = 0
                
        mc.setBlock(x+newx, y, z+newz, brickType)

           
