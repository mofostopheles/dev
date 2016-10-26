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


'''
for flerb in range(0, 10):         
        mc.setBlock(x+flerb, y-1, z+flerb, 1)
'''


foopattern = [
        1,1,1,1,1,1,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,
        3,1,1,3,1,3,3,2,2,3,3,1,1,3,1,1,1,3,1,1,1,
        3,3,1,3,1,3,1,3,2,3,2,3,1,3,1,1,3,1,1,1,1,
        3,1,3,3,1,3,3,3,2,3,2,3,2,3,1,1,3,3,3,1,1,
        3,1,1,3,1,3,1,3,2,3,3,2,1,3,1,3,1,1,1,3,1,
        3,1,1,3,3,2,1,3,2,3,2,3,1,3,1,3,1,1,1,3,1,
        1,1,1,1,1,1,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1
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

        if foocounter % 21 == 0:
                brickType = grass
                newz = newz - 1 
                newx = 0
                
        mc.setBlock(x+newx, y, z+newz, brickType)

        
'''
for foocounter in range(0, len(foopattern)):
        brickType = glowstone

        if (foopattern[foocounter] == 1):
                brickType = netherack
        elif (foopattern[foocounter] == 2):
                brickType = glowstone


        newz = newz + 1        


        if foocounter % 15==0:
                newz=z
                newx = newx + 1

        mc.setBlock(x+newx, y, z+newz, brickType)
'''




'''
loop thru foopattern

for each item, you will set a block

for foocounter in range(0, len(foopattern)):
        brickType = glowstone


        if (foopattern[foocounter] == 1):
                brickType = air
        elif (foopattern[foocounter] == 2):
                brickType = grass
                
        mc.setblock(x+foocounter, y, z, brickType)



'''

'''
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
                mc.setBlock(x+x1+2, y+1, z+3, 31) 
                mc.setBlock(x+x1+3, y+1, z+3, 31)

##make a column torch thing with some blocks
                for t1 in range(0, 4):
                        mc.setBlock(x+x1+2, y+t1, z+4, 155)
                        mc.setBlock(x+x1+3, y+t1, z+4, 155)
                        
##put something special on top
                mc.setBlock(x+x1+2, y+4, z+4, 10)
                mc.setBlock(x+x1+3, y+4, z+4, 10)
                
##add a torch or something every 11th block
        if x1 % 11 == 0:
                mc.setBlock(x+x1, y, z-2, stone)
                mc.setBlock(x+x1, y, z-3, stone)
                mc.setBlock(x+x1, y+1, z-3, stone)
                mc.setBlock(x+x1, y+2, z-3, stone)
                mc.setBlock(x+x1, y+3, z-3, netherack)
'''
                
