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
       
mc.postToChat('hello Mr.Ito .')

xLimit = 80
zLimit = xLimit
newX = x
newZ = z
for y1 in range(0, xLimit+1):
    xLimit = xLimit - 24
    zLimit = zLimit - 24
    newX = newX + 1
    newZ = newZ + 1
    for x1 in range(1, xLimit):
        for z1 in range(1, zLimit):

            if z1 > 1 and z1 < zLimit-1 and x1 > 1 and x1 < xLimit-1:                
                ##hollow out the middle
                mc.setBlock(newX+x1, y+y1, newZ+z1, air)
            else:
                if y1 % 2 == 0:
                    mc.setBlock(newX+x1, y+y1, newZ+z1, 21)
                else:
                    mc.setBlock(newX+x1, y+y1, newZ+z1, 21)

