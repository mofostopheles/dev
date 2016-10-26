import c4d
from c4d import documents, plugins
from random import *
from c4d import gui, utils
from math import *
import time

def getTool():
    return doc.GetActiveToolData()

def fireAction(pObj):
    tool = plugins.FindPlugin(doc.GetAction(), c4d.PLUGINTYPE_TOOL)
    if tool is not None:
        #gui.MessageDialog(tool)
        tool[c4d.MDATA_TRANSFER_OBJECT_LINK] = pObj
        c4d.CallButton(tool, c4d.MDATA_APPLY)
        c4d.EventAdd()
        
def main():    
    obj = insertObject(0,0,0,200,200,200,1)        

def insertObject(pX,pY,pZ,pWidth, pHeight, pDepth, pIndex):
    #INSERT A CUBE
    obj = c4d.BaseObject(c4d.Ocube)
    obj[c4d.PRIM_CUBE_SUBX]=2
    obj[c4d.PRIM_CUBE_SUBY]=2
    obj[c4d.PRIM_CUBE_SUBZ]=2

    obj[c4d.PRIM_CUBE_LEN] = c4d.Vector(pWidth,pHeight,pDepth)
    res = utils.SendModelingCommand(command = c4d.MCOMMAND_CURRENTSTATETOOBJECT,
                                    list = [obj],
                                    mode = c4d.MODELINGCOMMANDMODE_ALL,
                                    bc = c4d.BaseContainer(),
                                    doc = doc)[0] 
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = pX
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = pY
    res[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = pZ
    res[c4d.ID_BASELIST_NAME] = "cuby_" + str(pIndex)
                                                 
    doc.InsertObject(res)
    doc.SetActiveObject(res, c4d.SELECTION_NEW)
    c4d.EventAdd()
    
    #EXTRUDE THE SURFACES TO RANDOM LENGTHS
    sel = res.GetPolygonS()
    c4d.CallCommand(12187) # Polygons
    
    saveToPath = "D:\_projects\3d_sandbox\cubic_transformations\render\cuby_"
    outerCounter = 1
    innerCounter = 1
    
    #PASS 1 - CREATE A BASE SHAPE
    for growthCounter in range(0, 10):
        for f in range(0,23): 
            c4d.CallCommand(13324) # Deselect All
            sel.Select(f)
    
            c4d.CallCommand(1011183) # Extrude
            getTool()[c4d.MDATA_EXTRUDE_OFFSET] = randrange(10, 40) * 1.0
            fireAction(obj)
            
        #print(saveToPath + str(outerCounter) + "_" + str(innerCounter))
       
        #time.sleep(1)
        innerCounter = innerCounter + 1        
        outerCounter = outerCounter + 1
        
        '''
        doc[c4d.RDATA_PATH] = "D:\_projects\3d_sandbox\cubic_transformations\render\cuby_" + str(growthCounter) + str(f)
        c4d.CallCommand(465003525) # Add to Render Queue...
        c4d.CallCommand(465003513) # Start Rendering
        '''
    
    #PASS 2 - ADD EXTRUSIONS TO RANDOM FACES
    sel = res.GetPolygonS()
    c4d.CallCommand(12187) # Polygons
    
    for f in range(0, 1000):
        c4d.CallCommand(13324) # Deselect All
        sel.Select(f)
        
        #INNER EXTRUDE
        c4d.CallCommand(450000004) # Extrude Inner
        getTool()[c4d.MDATA_EXTRUDEINNER_OFFSET] = randrange(2, 30) * 1.0
        fireAction(obj)
        
        #OUTER
        c4d.CallCommand(1011183) # Extrude
        getTool()[c4d.MDATA_EXTRUDE_OFFSET] = randrange(9, 30) * -1.0
        fireAction(obj)
    
    #PASS 3 - ADD EXTRUSIONS TO RANDOM FACES
    sel = res.GetPolygonS()
    c4d.CallCommand(12187) # Polygons
    
    for f in range(0, 5000):
        c4d.CallCommand(13324) # Deselect All
        sel.Select(f)
        
        #INNER EXTRUDE
        c4d.CallCommand(450000004) # Extrude Inner
        getTool()[c4d.MDATA_EXTRUDEINNER_OFFSET] = randrange(2, 8) * 1.0
        fireAction(obj)
        
        #OUTER
        c4d.CallCommand(1011183) # Extrude
        getTool()[c4d.MDATA_EXTRUDE_OFFSET] = randrange(3, 20) * -1.0
        fireAction(obj)
    
    #PASS 4 - ADD EXTRUSIONS TO RANDOM FACES
    sel = res.GetPolygonS()
    c4d.CallCommand(12187) # Polygons
    
    for f in range(0, 10000):
        c4d.CallCommand(13324) # Deselect All
        sel.Select(f)
        
        #INNER EXTRUDE
        c4d.CallCommand(450000004) # Extrude Inner
        getTool()[c4d.MDATA_EXTRUDEINNER_OFFSET] = randrange(1, 6) * 1.0
        fireAction(obj)
        
        #OUTER
        c4d.CallCommand(1011183) # Extrude
        getTool()[c4d.MDATA_EXTRUDE_OFFSET] = randrange(1, 8) * -1.0
        fireAction(obj)
        
    #kick out a render
    doc[c4d.RDATA_PATH] = ""
    c4d.CallCommand(12098) # Save
    c4d.CallCommand(12099) # Render to Picture Viewer 
    
    return obj
    
    
    

if __name__=='__main__':
    main()


