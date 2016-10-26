import c4d
from c4d import documents, plugins
from random import *
from c4d import gui, utils


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
        '''
        res = utils.SendModelingCommand(command = c4d.ID_MODELING_BRIDGE_TOOL,
                                        list = [op],
                                        mode = c4d.MODELINGCOMMANDMODE_POLYGONSELECTION,
                                        bc = settings,
                                        doc = doc)
        '''                                
        #c4d.CallCommand(450000008) # Bridge

        
makeStuff()
