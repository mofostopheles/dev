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
         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,9,1,1,1,9,1,9,1,9,1,9,1,9,1,9,1,9,1,9,1,1,1,
         1,9,1,9,1,9,1,9,1,9,1,9,1,9,1,9,1,9,1,9,1,1,1,
         1,9,1,9,1,9,1,9,9,9,1,9,9,1,1,9,1,9,9,9,1,1,1,
         1,9,9,1,9,9,1,9,1,9,1,9,1,9,1,9,1,9,1,9,1,1,1,
         1,9,1,1,1,9,1,1,9,1,1,9,9,9,1,9,1,1,9,1,1,1,1,
         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
         ]
foopattern2 = [
         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,9,1,9,9,9,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,9,1,1,1,1,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,9,1,1,9,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,9,1,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,9,1,9,9,9,9,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
         ]
foopattern3 = [
         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
         1,1,9,9,9,1,1,9,1,9,1,9,9,9,1,9,1,9,1,1,9,1,1,
         1,9,1,1,1,9,1,9,1,9,1,9,1,1,1,9,1,9,1,1,9,1,1,
         1,9,1,1,9,9,1,9,9,1,1,9,9,9,1,9,9,9,1,1,9,1,1,
         1,9,1,1,1,1,1,9,1,9,1,9,1,1,1,9,1,9,1,1,9,1,1,
         1,1,9,9,9,1,1,9,9,9,1,9,9,9,1,1,9,1,1,9,9,9,1,
         1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
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

for foocounter in range(0, len(foopattern2)):
        brickType = glowstone
        if (foopattern2[foocounter] == 1):
                brickType = netherack
        elif (foopattern2[foocounter] == 2):
                brickType = glowstone
        elif (foopattern2[foocounter] == 3):
                brickType = 22

        newx = newx + 1      

        if foocounter % 23 == 0:
                brickType = grass
                newz = newz - 1 
                newx = 0
                
        mc.setBlock(x+newx, y+1, z+newz, brickType)
        
for foocounter in range(0, len(foopattern3)):
        brickType = glowstone
        if (foopattern3[foocounter] == 1):
                brickType = netherack
        elif (foopattern3[foocounter] == 2):
                brickType = glowstone
        elif (foopattern3[foocounter] == 3):
                brickType = 22

        newx = newx + 1      

        if foocounter % 23 == 0:
                brickType = grass
                newz = newz - 1 
                newx = 0
                
        mc.setBlock(x+newx, y+2, z+newz, brickType)       

