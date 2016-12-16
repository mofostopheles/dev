import time
import RPi.GPIO as GPIO

from picraft import World, Vector, Block
from picraft import block

'''
    arlo emerson, december 2016
    script builds the Taipei 101 skyscraper at current player's location
        
    uses the picraft lib, see picraft.readthedocs.io/en/release-0.6/conversion.html
    
'''
class TaipeiBuilding():

    def __init__(self):
        print('constructor')

    def makeBrickSampler(self):
        x = w.player.pos.x
        y = w.player.pos.y
        z = w.player.pos.z
        blockIndex = 0
        
        for iy1 in range(0, 20):            
            for ix1 in range(0, 20):
                blockIndex += 1

                #filter out water, lava and sands
                if blockIndex >= 8 and blockIndex <= 12:
                    w.blocks[Vector(ix1+x, iy1+y, z)] = Block(1, 0)
                else:
                    print(blockIndex)
                    w.blocks[Vector(ix1+x, iy1+y, z)] = Block(blockIndex, 0)
                



    def makeFoundation(self):
        #print('make foundation')
        #print( w.player.pos )
        x = w.player.pos.x
        y = w.player.pos.y
        z = w.player.pos.z

        #this loops y, then x, then z
        #builds a foundation out of stone that is 9x9 by 3 high
        #TODO - hollow it out
        newY = y #we need to track how high we are
        newX = 0 #these will be used to step inwards
        newZ = 0

        for iy1 in range(0, 3):
            newY = newY+1 #increment by 1 to go up that many levels
            print(newY)                  
            for ix1 in range(0, 8):
                for iz1 in range(0, 8):
                    newX = x+ix1
                    newZ = z+iz1
                    w.blocks[Vector(newX, newY, newZ)] = Block(block.DIRT.id, 0)

        #shift x/z by 1 so the next level is concentric
        newX = x + 1
        newZ = z + 1

        for iy1 in range(0, 3):
            newY = newY+1 #increment by 1 to go up that many levels
            
            for ix1 in range(0, 6):
                for iz1 in range(0, 6):                
                    w.blocks[Vector(newX+ix1, newY, newZ+iz1)] = Block(1, 0)


        #shift x/z by 1 so the next level is concentric
        newX = x + 1
        newZ = z + 1

        for iy1 in range(0, 3):
            newY = newY+1 #increment by 1 to go up that many levels
        
        for ix1 in range(0, 4):
            for iz1 in range(0, 4):                
                w.blocks[Vector(newX+ix1, newY, newZ+iz1)] = Block(1, 0)

        
        

w = World()
tb = TaipeiBuilding()
#tb.makeFoundation()
tb.makeBrickSampler()
