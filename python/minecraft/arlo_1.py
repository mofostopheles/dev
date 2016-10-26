from mcpi import minecraft

##block id reference here:
##http://www.raspberrypi-spy.co.uk/2014/09/raspberry-pi-minecraft-block-id-number-reference/

mc = minecraft.Minecraft.create()
mc.postToChat('iot design lab')
x,y,z = mc.player.getPos()

air = 0
stone = 1
fence = 85
glowstone = 89
brick = 45
redstone = 73
tnt = 46

for x1 in range(0, 400):
##make the street
    mc.setBlock(x+x1, y, z, stone)
    mc.setBlock(x+x1, y, z-1, stone)
    mc.setBlock(x+x1, y, z+1, stone)

##add column support
    for colCount in range(0, int(y)):
        mc.setBlock(x+x1, colCount, z, redstone)
##insert a random TNT block
        if x1 % 17 == 0:
            if colCount % 7 == 0:
                  mc.setBlock(x+x1, colCount, z, tnt)  
            

##place arches in the wall
    if x1 % 9 == 0:
        for colCount in range(0, int(y-1)):
            mc.setBlock(x+x1, colCount, z, air)
            mc.setBlock(x+x1-1, colCount, z, air)
            mc.setBlock(x+x1-2, colCount, z, air)
            mc.setBlock(x+x1-3, colCount, z, air)
##this makes the arch look like an arch            
        mc.setBlock(x+x1, y-2, z, redstone)             
        mc.setBlock(x+x1-3, y-2, z, redstone) 
        

##add the guardrails
    mc.setBlock(x+x1, y+1, z-1, fence)
    mc.setBlock(x+x1, y+1, z+1, fence)

##add empty space for if we go through land masses    
    mc.setBlock(x+x1, y+1, z, air)
    mc.setBlock(x+x1, y+2, z, air)
    mc.setBlock(x+x1, y+3, z, air)
    mc.setBlock(x+x1, y+2, z-1, air)
    mc.setBlock(x+x1, y+2, z+1, air)
    mc.setBlock(x+x1, y+3, z-1, air)
    mc.setBlock(x+x1, y+3, z+1, air)

##every 21st block add a set of lights
    if x1 % 13 == 0:
        mc.setBlock(x+x1, y, z+2, stone)
        mc.setBlock(x+x1, y+1, z+2, brick)
        mc.setBlock(x+x1, y+2, z+2, brick)
        mc.setBlock(x+x1, y+3, z+2, brick)
        mc.setBlock(x+x1, y+4, z+2, air)
        mc.setBlock(x+x1, y+3, z+2, glowstone)

        mc.setBlock(x+x1, y, z-2, stone)
        mc.setBlock(x+x1, y+1, z-2, brick)
        mc.setBlock(x+x1, y+2, z-2, brick)
        mc.setBlock(x+x1, y+3, z-2, brick)
        mc.setBlock(x+x1, y+4, z-2, air)
        mc.setBlock(x+x1, y+3, z-2, glowstone)        
        
