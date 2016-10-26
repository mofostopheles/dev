from mcpi import minecraft

mc = minecraft.Minecraft.create()
mc.postToChat('i build tunnels')
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
           
##add empty space for if we go through land masses    
    mc.setBlock(x+x1, y+1, z, air)
    mc.setBlock(x+x1, y+2, z, air)
    mc.setBlock(x+x1, y+3, z, air)
    mc.setBlock(x+x1, y+2, z-1, air)
    mc.setBlock(x+x1, y+2, z+1, air)
    mc.setBlock(x+x1, y+3, z-1, air)
    mc.setBlock(x+x1, y+3, z+1, air)
