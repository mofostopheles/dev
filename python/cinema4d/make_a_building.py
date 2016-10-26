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

#
#color the dot
#
def setColor(pDot, pColor):
    pDot.color = color.red

def getNumberSelfAffinity(pInt):
    # 2-layer z-zone
    #return sin(  pInt * pInt/ pInt )

    #pyramid
    #return (sqrt(pInt)/pi)*2

    #TALLER PYRAMIDS
    return (sqrt(pInt)*5)/pi

def insertObject(pX,pY,pZ,pHeight):
    obj = c4d.BaseObject(c4d.Ocube)        
    #obj[c4d.PRIM_CUBE_LEN] = c4d.Vector(randrange(10,150),randrange(10,150),randrange(10,150))
    obj[c4d.PRIM_CUBE_LEN] = c4d.Vector(5,5,pHeight)
    res = utils.SendModelingCommand(command = c4d.MCOMMAND_CURRENTSTATETOOBJECT,
                                    list = [obj],
                                    mode = c4d.MODELINGCOMMANDMODE_ALL,
                                    bc = c4d.BaseContainer(),
                                    doc = doc)[0] 
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = pX
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = pY
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = pZ 
                                                 
    doc.InsertObject(res)
    doc.SetActiveObject(res, c4d.SELECTION_NEW)
    c4d.EventAdd()
    sel = res.GetPolygonS()
    sel.Select(2)
    
    cubeList.append(res) 
    
    #if (x > 0):#connect this with the last cube
    #    doc.SetActiveObject(cubeList[x-1], c4d.SELECTION_ADD)                    
    
    
    #send a modeling command here
    settings = c4d.BaseContainer()                 # Settings
    settings[c4d.MDATA_EXTRUDE_OFFSET] = 50.0      # Length of the extrusion

    res = utils.SendModelingCommand(command = c4d.ID_MODELING_BRIDGE_TOOL,
                                    list = [op],
                                    mode = c4d.MODELINGCOMMANDMODE_POLYGONSELECTION,
                                    bc = settings,
                                    doc = doc)
    
    
#
#main spiral function
#
def initSpiral():

    #posX = 0
    #posY = 0
    #ordinalDirectionIndex = 0
    numberCounter = 1
    #_primeColor = color.red
    _order = ["r","u","l","d"]
    _spacer = 5

    zDepth = 0
    #establish the first dot
    #ball = sphere (color = color.red, radius = _ballRadius)
    #ball.pos = vector(0,0,-10)
    
    insertObject(0,0,0, 1)

    for z in range(1,2):
        
        ordinalDirectionIndex = 0
        posX = 0
        posY = 0

        for i in range(1,60):
            if _order[ordinalDirectionIndex] == "r":
                #move an odd number based on i
                tmpRange = (2*i)-1
    
                for k in range(tmpRange):
                    numberCounter=numberCounter+1
                    posX = posX + _spacer
                    if testNumber(numberCounter,posX,posY)==True:
                        insertObject( posX,posY,zDepth, getNumberSelfAffinity(numberCounter))
                    #else:
                    #    insertObject(posX,posY,-getNumberSelfAffinity(numberCounter))
    
                ordinalDirectionIndex=ordinalDirectionIndex+1
    
            if _order[ordinalDirectionIndex] == "u":
                tmpRange = (2*i)-1
                #print str(tmpRange)
                for k in range(tmpRange):
                    numberCounter=numberCounter+1
                    posY = posY - _spacer
                    if testNumber(numberCounter,posX,posY)==True:
                        insertObject(posX,posY,zDepth, getNumberSelfAffinity(numberCounter))
                    #else:
                    #    insertObject(posX,posY,-getNumberSelfAffinity(numberCounter))
    
                ordinalDirectionIndex=ordinalDirectionIndex+1
    
            if _order[ordinalDirectionIndex] == "l":
                #move an even number based on i
                #(2*i)
                tmpRange = 2*i
                for k in range(tmpRange):
                    numberCounter=numberCounter+1
                    posX = posX - _spacer
                    if testNumber(numberCounter,posX,posY)==True:
                        insertObject(posX,posY,zDepth, getNumberSelfAffinity(numberCounter))
                    #else:
                    #    insertObject(posX,posY,-getNumberSelfAffinity(numberCounter))
    
                ordinalDirectionIndex=ordinalDirectionIndex+1
    
            if _order[ordinalDirectionIndex] == "d":
                #(2*i)
                tmpRange = 2*i
                for k in range(tmpRange):
                    numberCounter=numberCounter+1
                    posY = posY + _spacer
                    if testNumber(numberCounter,posX,posY)==True:
                        insertObject(posX,posY,zDepth, getNumberSelfAffinity(numberCounter))
                    #else:
                    #    insertObject(posX,posY,-getNumberSelfAffinity(numberCounter))
    
                #reset ordinalDirectionIndex
                ordinalDirectionIndex=0
                
        zDepth += 20
    
    print("done")
    
#fire it up
initSpiral()
    

'''

c4d.CallCommand(12187) # Polygons
cubeList = []

for x in range(0, 4):
    obj = c4d.BaseObject(c4d.Ocube)        
    obj[c4d.PRIM_CUBE_LEN] = c4d.Vector(randrange(10,150),randrange(10,150),randrange(10,150))
    res = utils.SendModelingCommand(command = c4d.MCOMMAND_CURRENTSTATETOOBJECT,
                                    list = [obj],
                                    mode = c4d.MODELINGCOMMANDMODE_ALL,
                                    bc = c4d.BaseContainer(),
                                    doc = doc)[0] 
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = getRandPosition(200)
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = getRandPositionPos(200)#keep it above ground level
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = getRandPosition(200) 
                                                 
    doc.InsertObject(res)
    doc.SetActiveObject(res, c4d.SELECTION_NEW)
    c4d.EventAdd()
    sel = res.GetPolygonS()
    sel.Select(2)
    
    cubeList.append(res) 
    
    if (x > 0):#connect this with the last cube
        doc.SetActiveObject(cubeList[x-1], c4d.SELECTION_ADD)                    
    
    
    #send a modeling command here
    settings = c4d.BaseContainer()                 # Settings
    settings[c4d.MDATA_EXTRUDE_OFFSET] = 50.0      # Length of the extrusion

    res = utils.SendModelingCommand(command = c4d.ID_MODELING_BRIDGE_TOOL,
                                    list = [op],
                                    mode = c4d.MODELINGCOMMANDMODE_POLYGONSELECTION,
                                    bc = settings,
                                    doc = doc)
                            
    #c4d.CallCommand(450000008) # Bridge
'''