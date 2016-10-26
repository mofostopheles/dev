#arlo emerson
#1/22/2015

import c4d
from c4d import documents, plugins
from random import *
from c4d import gui, utils
from math import *

c4d.CallCommand(12187) # Polygons
cubeList = []

def makeStuff():
    
    def object():
        return doc.GetActiveObject()

    def tag():
        return doc.GetActiveTag()
    
    def renderdata():
        return doc.GetActiveRenderData()
    
    def prefs(id):
        return plugins.FindPlugin(id, c4d.PLUGINTYPE_PREFS)
    
    def getPosOrNeg():
        tmpNumber = randrange(1, 20)

        if (tmpNumber % 2==0):
            return 1
        else:
            return -1
    def getRandPosition(pArg):
        return randrange(1, pArg)*getPosOrNeg()
    
    def getRandPositionPos(pArg):
        return randrange(1, pArg)
    
    
    
def isPrime(pInt):
    weArePrime = False
    numberIsDirty = False

    for i in range(2, pInt):
        remainder = pInt%i
        if remainder==0:
            numberIsDirty = true

    if numberIsDirty != True:
        weArePrime = True

    return weArePrime



def testNumber(pInt,pX,pY):
    #persian rug
    if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
        return True

    #r=sqrt(pow(pX,2)+pow(pY,2))
    #print r

    #newRand = randrange(3,9)
    #print newRand

    #if round(  pInt * r  )%newRand==0:
    #    return True
    return False


def getNumberSelfAffinity(pInt):
    # 2-layer z-zone
    #return sin(  pInt * pInt/ pInt )

    #pyramid
    #return (sqrt(pInt)/pi)*2

    #TALLER PYRAMIDS
    return (sqrt(pInt)*5)/pi

def insertObject(pX,pY,pZ,pHeight, pIndex):
    obj = c4d.BaseObject(c4d.Ocube)        

    obj[c4d.PRIM_CUBE_LEN] = c4d.Vector(5,5,pHeight)
    res = utils.SendModelingCommand(command = c4d.MCOMMAND_CURRENTSTATETOOBJECT,
                                    list = [obj],
                                    mode = c4d.MODELINGCOMMANDMODE_ALL,
                                    bc = c4d.BaseContainer(),
                                    doc = doc)[0] 
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = pX
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = pY
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = pZ
    res[c4d.ID_BASELIST_NAME] = "tile_" + str(pIndex)
                                                 
    doc.InsertObject(res)
    doc.SetActiveObject(res, c4d.SELECTION_NEW)
    c4d.EventAdd()
    #sel = res.GetPolygonS()
    #sel.Select(2)
    
    cubeList.append(res) 
    
_lastTileLength = 0;
_posZ = 0
_posX = 0
_posY = 0
    
def buildSomething():
    global _posZ, _posY, _lastTileLength
    _spacerX = 0
    _spacerY = 2
    
    for y in range(0, 100):
        
        _posY = _posY + 5 + _spacerY
        
        for z in range(0,30):        
            thisTileLength = randrange(4,80)
                    
            if z != 0:
                _spacerX = 2
            
            _posZ = _posZ + (thisTileLength/2) + (_lastTileLength/2) + _spacerX
            
            insertObject( _posX, _posY, _posZ, thisTileLength, z)
            
            _lastTileLength = thisTileLength

        #reset to next line
        _posZ = 0
                        
    print("done")
    
#fire it up
buildSomething()
