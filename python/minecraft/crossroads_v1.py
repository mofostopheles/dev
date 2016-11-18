from mcpi import minecraft
import mcpi.block as block

##block id reference here:
##http://www.raspberrypi-spy.co.uk/2014/09/raspberry-pi-minecraft-block-id-number-reference/

class Crossroads():

    def __init__(self, mc=None):
        print("init\n")
        print(mc)

        self.mc = mc
        self.pos = mc.player.getPos()
        self.x = self.pos.x
        self.y = self.pos.y
        self.z = self.pos.z
        
        self.air = 0
        self.stone = 1
        self.fence = 85
        self.glowstone = 89
        self.brick = 45
        self.redstone = 73
        self.tnt = 46

    def cutTunnel(self):
        tmpx = self.pos.x
        tmpy = self.pos.y
        tmpz = self.pos.z
        
        for x1 in range(0, 400):
            ##make the street
            self.mc.setBlock(self.x+x1, self.y, self.z, self.stone)
            self.mc.setBlock(tmpx+x1, tmpy, tmpz-1, self.stone)
            self.mc.setBlock(tmpx+x1, tmpy, tmpz+1, self.stone)
                   
            ##add empty space for if we go through land masses    
            self.mc.setBlock(tmpx+x1, self.y+1, self.z, self.air)
            self.mc.setBlock(tmpx+x1, self.y+2, self.z, self.air)
            self.mc.setBlock(tmpx+x1, self.y+3, self.z, self.air)
            self.mc.setBlock(tmpx+x1, self.y+2, self.z-1, self.air)
            self.mc.setBlock(tmpx+x1, self.y+2, self.z+1, self.air)
            self.mc.setBlock(tmpx+x1, self.y+3, self.z-1, self.air)
            self.mc.setBlock(tmpx+x1, self.y+3, self.z+1, self.air)


tmpMc = minecraft.Minecraft.create()
crossroads = Crossroads(mc=tmpMc)
crossroads.cutTunnel()

'''
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
'''     
