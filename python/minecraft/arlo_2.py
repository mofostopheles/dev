from mcpi import minecraft

mc = minecraft.Minecraft.create()
mc.postToChat('pyramid builder')
x,y,z = mc.player.getPos()

air = 0
stone = 1
fence = 85
glowstone = 89
brick = 45
redstone = 73
tnt = 46
sandstone = 24

##for x1 in range(0, 50):
##    for z1 in range(0, 50):
##        mc.setBlock(x+x1, y, z, sandstone)
##        mc.setBlock(x+2, y+1, z,tnt) 
##        mc.setBlock(x+3, y+2, z,glowstone)
##        mc.setBlock(x+4, y+3, z,redstone)
##        mc.setBlock(x+5, y+4, z,112)
        
mc.postToChat('wow, man!')
xLimit = 41
newX = x
newZ = z
for y1 in range(0, 40):
    xLimit = xLimit - 2
    newX = newX + 1
    newZ = newZ + 1
    for x1 in range(1, xLimit):
        for z1 in range(1, xLimit):
            if y1 % 2 == 0:
                mc.setBlock(newX+x1, y+y1, newZ+z1, glowstone)
            else:
                mc.setBlock(newX+x1, y+y1, newZ+z1, 80)


