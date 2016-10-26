import c4d
from c4d import documents, plugins
from random import *
# auto-gen objects, create a post modern landscape
'''
references:
http://www.peranders.com/w/index.php?title=Creating_Objects_in_Python
http://www.maxonexchange.de/sdk/CINEMA4DPYTHONSDK/index.html

full python api documentation
http://www.thirdpartyplugins.com/python_r13/
'''

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
    
    #create a floor 
    theFloor = c4d.BaseObject(c4d.Ocube)   
    
    theFloor[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X] = 400
    theFloor[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Y] = 10
    theFloor[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z] = 600    
    
    theFloor[c4d.PRIM_CUBE_SUBX]=36
    theFloor[c4d.PRIM_CUBE_SUBY]=2
    theFloor[c4d.PRIM_CUBE_SUBZ]=36
    
    doc.InsertObject(theFloor) 
    doc.SetActiveObject(theFloor, c4d.SELECTION_NEW)    
    object()[c4d.ID_BASELIST_NAME]="new cube"    
    c4d.CallCommand(12236) # Make Editable
    
    #displacer1 = c4d.BaseObject(c4d.Displacer)
    
    #make some randomly arranged cubes
    for x in range(0, 20):
        aCube =  c4d.BaseObject(c4d.Ocube)
        aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X] = randrange(10,150)
        aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Y] = randrange(10,150)
        aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z] = randrange(10,150)
        aCube[c4d.PRIM_CUBE_SUBX]=64
        aCube[c4d.PRIM_CUBE_SUBY]=64
        aCube[c4d.PRIM_CUBE_SUBZ]=64
        aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = getRandPosition(500)
        aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = getRandPositionPos(500)#keep it above ground level
        aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = getRandPosition(500)
        
        #add a material to these objects
        mat = doc.SearchMaterial("windows")
        t = aCube.MakeTag(c4d.Ttexture)
        t[c4d.TEXTURETAG_PROJECTION] = 6
        t.SetMaterial(mat)

        doc.InsertObject(aCube) 
        
        #add a thin roof piece to each cube
        roof =  c4d.BaseObject(c4d.Ocube)
        roof[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X] = aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X] + 3
        roof[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Y] = 8
        roof[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z] = aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z] + 3
        roof[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X]
        roof[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] + (aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Y]/2)
        roof[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z]
        doc.InsertObject(roof)
        
        #add a thin roof piece to the roof
        roof2 =  c4d.BaseObject(c4d.Ocube)
        roof2[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X] = roof[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X] + 5
        roof2[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Y] = 2
        roof2[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z] = roof[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z] + 5
        roof2[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = roof[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X]
        roof2[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = roof[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] + (roof[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Y]/2)
        roof2[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = roof[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z]
        doc.InsertObject(roof2)
        
        #make some glass blocks - place them on the eastern edge
        for g in range(1, 10):
            glass =  c4d.BaseObject(c4d.Ocube)
            glass[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X] = aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X]-2
            glass[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Y] = 2
            glass[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z] = aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_Z]-2
            glass[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] - (aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X]/2)
            glass[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] - (aCube[c4d.PRIM_CUBE_LEN,c4d.VECTOR_X]/2) + (g*5)
            glass[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = aCube[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z]
        
            #add a material to these objects
            mat = doc.SearchMaterial("glass")
            t = glass.MakeTag(c4d.Ttexture)
            t[c4d.TEXTURETAG_PROJECTION] = 6
            t.SetMaterial(mat)
            
            doc.InsertObject(glass)
        
        
    #loop the list of cubes
    #connect each cube to its neighbor in the list
    
    
makeStuff()
