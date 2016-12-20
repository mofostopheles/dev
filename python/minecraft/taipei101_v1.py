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
                    #print(blockIndex)
                    w.blocks[Vector(ix1+x, iy1+y, z)] = Block(blockIndex, 0)
                
    def buildGenericFloor(self, pIndex, pX, pY, pZ):
        x = w.player.pos.x
        y = w.player.pos.y
        z = w.player.pos.z

        newX = pX
        newY = pY
        newZ = pZ

        floorWidth = 4
        blockType = block.IRON_BLOCK.id
        offset = 1
        
        for iy1 in range(0, 2):        
            if iy1 == 1:
                offset=0
                floorWidth = 6
            
            for ix1 in range(0, floorWidth):
                for iz1 in range(0, floorWidth):
                    
                    if floorWidth == 4:
                        if ((iz1 == 0 or iz1 == 3) and (ix1 == 1 or ix1 == 2)):
                            blockType = block.GLASS_PANE.id
                        elif ((ix1 == 0 or ix1 == 3) and (iz1 == 1 or iz1 == 2)):
                            blockType = block.GLASS_PANE.id
                        else:
                            blockType = block.DIAMOND_BLOCK.id

                    if floorWidth == 6:
                        if ((iz1 == 0 or iz1 == 5) and (ix1 == 2 or ix1 == 3)):
                            blockType = block.STONE_SLAB.id
                        elif ((ix1 == 0 or ix1 == 5) and (iz1 == 2 or iz1 == 3)):
                            blockType = block.STONE_SLAB.id
                        else:
                            blockType = block.DIAMOND_BLOCK.id
                            
                    '''
                    if floorWidth == 6:
                        if ((iz1 == 0 or iz1 == 5) and (ix1 > 0 and ix1 < 5)):
                            blockType = block.STONE_SLAB.id
                        elif ((ix1 == 0 or ix1 == 5) and (iz1 > 0 and iz1 < 5)):
                            blockType = block.STONE_SLAB.id
                        else:
                            blockType = block.LAPIS_LAZULI_BLOCK.id                    
                    '''
                    
                    w.blocks[Vector(newX + ix1 + offset, newY+iy1, newZ + iz1 + offset)] = Block(blockType, 0)        

    def annihilateEverything(self):
        x = w.player.pos.x
        y = w.player.pos.y -1
        z = w.player.pos.z
        repoX = 0
        repoY = 0
        repoZ = 0
        fieldWidth = 14 #must be an even number

        #repo to ground level -1
        w.player.pos = Vector(x, 0, z)
        time.sleep(1)
        
        for iy1 in range(0, fieldWidth/2):
            for ix1 in range(0, fieldWidth):
                for iz1 in range(0, fieldWidth):
                    if iz1 == fieldWidth/2 and ix1 == fieldWidth/2 and iy1 == 0:
                        #at the midpoint
                        repoX = x+ix1
                        repoY = 0
                        repoZ = z+iz1
                    w.blocks[Vector(x+ix1, y+iy1, z+iz1)] = Block(block.AIR.id, 0)

        #repo to center of the field we just cleared
        w.player.pos = Vector(repoX, repoY-1, repoZ)

        
            
    def makeFoundation(self):
        basicBlockType = block.DIAMOND_BLOCK.id
  
        #print('make foundation')
        #print( w.player.pos )
        x = w.player.pos.x
        y = w.player.pos.y
        z = w.player.pos.z

        #this loops y, then x, then z
        #builds a foundation out of stone that is 9x9 by 3 high
        #TODO - hollow it out
        newY = y #we need to track how high we are
        newX = x #these will be used to step inwards
        newZ = z

        #### foundation part I ####
        for iy1 in range(0, 3):
            newY += 1 #increment by 1 to go up that many levels
               
            for ix1 in range(0, 8):
                for iz1 in range(0, 8):
                    if ((ix1 > 2 and ix1 < 5) and (iz1 == 0 or iz1 == 7)) or \
                        ((iz1 > 2 and iz1 < 5) and (ix1 == 0 or ix1 == 7)):
                        w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(block.STONE_SLAB.id, 0)
                    else:
                        w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(basicBlockType, 0)

        #### foundation part II ####                
        #reset and shift x/z by 1 so the next level is concentric
        newX = x + 1
        newZ = z + 1

        for iy1 in range(0, 3):
            newY += 1 #increment by 1 to go up that many levels
            
            for ix1 in range(0, 6):                
                for iz1 in range(0, 6):
                    if ((ix1 > 1 and ix1 < 4) and (iz1 == 0 or iz1 == 5)) or \
                        ((iz1 > 1 and iz1 < 4) and (ix1 == 0 or ix1 == 5)):
                        w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(block.STONE_SLAB.id, 0)
                    else:
                        w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(basicBlockType, 0)

        #### foundation part III ####        
        #reset and shift x/z by 1 so the next level is concentric
        #keep in mind that x and z don't change, user didn't move
        #so setting these back to x,z resets to the origin of where we're building
        newX = x + 2
        newZ = z + 2

        #newY is the one variable that can keep increasing w/o concern to reset
        
        for iy1 in range(0, 3):
            newY += 1 #increment by 1 to go up that many levels
        
            for ix1 in range(0, 4):
                for iz1 in range(0, 4):                
                    if ((ix1 > 0 and ix1 < 3) and (iz1 == 0 or iz1 == 3)) or \
                        ((iz1 > 0 and iz1 < 3) and (ix1 == 0 or ix1 == 3)):
                        w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(block.STONE_SLAB.id, 0)
                    else:
                        w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(basicBlockType, 0)

        #### build 1 floors of stone ####
        newX = x + 2
        newZ = z + 2
        newY += 1
        blockType = block.STONE.id
        
        for ix1 in range(0, 4):
            for iz1 in range(0, 4):
                
                if ((iz1 == 1 or iz1 == 2) and (ix1 == 1 or ix1 == 2)):                    
                    blockType = block.STONE.id
                else:
                    blockType = block.DIAMOND_ORE.id

                w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(blockType, 0)

        #### build round looking feature on all four sides
        
        newX = x + 1
        newZ = z + 1


        for ix1 in range(0, 6):                
            for iz1 in range(0, 6):
                if ((ix1 > 1 and ix1 < 4) and (iz1 == 0 or iz1 == 5)) or \
                    ((iz1 > 1 and iz1 < 4) and (ix1 == 0 or ix1 == 5)):
                    w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(block.DIAMOND_ORE.id, 0)
                #else:
                    #w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(block.AIR.id, 0)
                
        
        #### build the main floors ####
                    
        #reset and shift to where we want to start building floors
        newY += 1
        newX = x + 1
        newZ = z + 1    
        
        #build the floors of the building
        #pass in starting coords
        for i in range(0, 16, 2):
            self.buildGenericFloor(i, newX, newY+i, newZ)

        #top of building stuff
        newY += 15 #this ought to put us on the roof
        newX = x + 3
        newZ = z + 3
        blockType = basicBlockType

        #put four diamond ore blocks at the corners of the antenna mast
        w.blocks[Vector(newX-1, newY+1, newZ-1)] = Block(block.DIAMOND_ORE.id, 0)
        w.blocks[Vector(newX+2, newY+1, newZ-1)] = Block(block.DIAMOND_ORE.id, 0)
        w.blocks[Vector(newX+2, newY+1, newZ+2)] = Block(block.DIAMOND_ORE.id, 0)
        w.blocks[Vector(newX-1, newY+1, newZ+2)] = Block(block.DIAMOND_ORE.id, 0)

        #put torches on top of these corner blocks
        w.blocks[Vector(newX-1, newY+2, newZ-1)] = Block(block.TORCH.id, 0)
        w.blocks[Vector(newX+2, newY+2, newZ-1)] = Block(block.TORCH.id, 0)
        w.blocks[Vector(newX+2, newY+2, newZ+2)] = Block(block.TORCH.id, 0)
        w.blocks[Vector(newX-1, newY+2, newZ+2)] = Block(block.TORCH.id, 0)
        
        #antenna mast
        for iy1 in range(0, 9):
            newY += 1 #increment by 1 to go up that many levels

            if iy1 > 4:
                blockType = block.GLASS_PANE.id
            elif iy1 == 4:
                blockType = block.GLOWSTONE_BLOCK.id                
            else:
                blockType = block.DIAMOND_ORE.id                
            
            for ix1 in range(0, 2):
                for iz1 in range(0, 2):                
                    w.blocks[Vector(newX + ix1, newY, newZ + iz1)] = Block(blockType, 0)
            
        #repo to outside the building
        w.player.pos = Vector(newX + 5, 10, newZ - 3)
        print("all done!")

w = World()
tb = TaipeiBuilding()
tb.annihilateEverything()
time.sleep(1) #sleep else this thing crashes
tb.makeFoundation()


