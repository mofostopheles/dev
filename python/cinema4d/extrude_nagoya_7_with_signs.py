import c4d
from c4d import documents, plugins, gui, utils
from random import *


#arlo emerson
#1/23/2015 through ____
_counter = 0

def getActiveTool():
    return doc.GetActiveToolData()

def fireAction(pObj):
    tool = plugins.FindPlugin(doc.GetAction(), c4d.PLUGINTYPE_TOOL)
    if tool is not None:
        #gui.MessageDialog(tool)
        tool[c4d.MDATA_TRANSFER_OBJECT_LINK] = pObj
        c4d.CallButton(tool, c4d.MDATA_APPLY)
        c4d.EventAdd()

#NOTE: if the spline normals are not aligned then all the extrude and other stuff will be totally screwed
# or in our case, they are screwed up so our initial extrudes have swapped y and z values
def main():
    
    doc = c4d.documents.GetActiveDocument()

    if doc:
        # Iterate all objects in the document
        #recurse_hierarchy( doc.GetFirstObject() )
        #print( doc.GetFirstObject().GetDown() )
        #this hits the 1024 recursion limit...
        #loopAllItems(  doc.GetFirstObject().GetDown() )
        #too close for missiles, switching to guns
        numberOfSplines = len(doc.GetFirstObject().GetChildren())
        
        for i in range(0, numberOfSplines):
            makeABuilding(  doc.GetFirstObject().GetChildren()[i] )
        
    
def extrudeSpline(spline, pHeight):
    #print('extrude spline')
    extrude = c4d.BaseObject(c4d.Oextrude)
    extrude[c4d.ID_BASELIST_NAME] = str("nurb_") + spline.GetName()
    
    #TODO: add a depth the extrusion
    
    v = c4d.Vector(0,-pHeight,0)
    extrude[c4d.EXTRUDEOBJECT_MOVE] = v
    extrude.InsertAfter(spline)
    c4d.EventAdd()
    spline.Remove()
    spline.InsertUnder(extrude)
    c4d.EventAdd()
    return extrude

def getRoofMaterial():
    global _counter
    
    return "white"
    
    if _counter % 2 == 0:
        return "gravel"
    elif _counter % 3 ==0:
        return "stone1"
    elif _counter % 13 ==0:
        return "rustroof"    
    else:
        return "concrete1"
    
def getMainBuildingMaterial():
    global _counter
    
    if _counter % 2 == 0:
        return "light_windows_1"
    elif _counter % 3 == 0:
        return "light_windows_2"
    elif _counter % 5 == 0:
        return "light_windows_3"
    elif _counter % 7 == 0:
        return "light_windows_4"
    else:
        return "light_windows_5"
    
def getHVACUnit():
    global _counter
    
    if _counter % 2 == 0:
        return "HVAC_system_1"
    elif _counter % 3 == 0:
        return "HVAC_system_2"
    else:
        return "HVAC_system_3"    
    
 
def exitAndReenterRecursion(pObj):
    loopAllItems(pObj)
       
def makeABuilding( pObj ):
    global _counter
    _counter = _counter + 1
    
    #return the tools to original
    #c4d.CallCommand(12298) # Model
    #c4d.CallCommand(200000088) # Move111
    
    if pObj:    
        #print(pObj)
        tallBuilding = False
        smallBuilding = False
        
        #optimize the spline first, else sometimes the extrude bombs out.
        doc.SetActiveObject(pObj, c4d.SELECTION_NEW)
        c4d.CallCommand(12139) # Points
        #set the tolerance to .5 centimeters
        c4d.CallCommand(14039) # Optimize...
        
        #put the spline into a NULL
        hvacStructureSpline = pObj
        tmpNull = c4d.BaseObject(c4d.Onull)
        tmpNull.InsertAfter(pObj)
        c4d.EventAdd()
        pObj.Remove()
        pObj.InsertUnder(tmpNull)
        tmpNull[c4d.ID_BASELIST_NAME] = pObj[c4d.ID_BASELIST_NAME]
        
        #EXTRUDE the spline
        #height = getRandomHeight()
        height = -pObj.GetRad().y * 2
        buildingExtrude = extrudeSpline(pObj, height)
        #print( height )
        
        
        #CLONE spline here and modify it
        
        if height < -60:
            #print(height)
            tallBuilding = True
            hvacStructureSpline = pObj.GetClone()
            hvacStructureSpline.InsertUnder(tmpNull)
        
        if height > -50:
            smallBuilding = True
        
        tex = buildingExtrude.MakeTag(c4d.Ttexture)
        tex[c4d.TEXTURETAG_MATERIAL] = doc.SearchMaterial(getMainBuildingMaterial())
            
        if smallBuilding == True:
            tex[c4d.TEXTURETAG_MATERIAL] = doc.SearchMaterial("light_windows_6")
            
        tex[c4d.TEXTURETAG_PROJECTION] = 6 #UVW
        
        #fillet cap the building
        buildingExtrude[c4d.CAP_END] = 3
        buildingExtrude[c4d.CAP_ENDRADIUS]=0.1
        buildingExtrude[c4d.CAP_ENDSTEPS]=2
        buildingExtrude[c4d.ID_BASELIST_NAME] = "buildingExtrude"
        
        #convert the building to editable
        doc.SetActiveObject(buildingExtrude, c4d.SELECTION_NEW)
        c4d.CallCommand(12236) # Make Editable
        c4d.CallCommand(12187) # Polygons
        #texturize the roof
        #first select it...
        tmpRoof = buildingExtrude.GetDown().GetNext().GetDown()
        tmpRoof[c4d.ID_BASELIST_NAME] = "roof"
        roofTex = tmpRoof.MakeTag(c4d.Ttexture)
        roofTex[c4d.TEXTURETAG_MATERIAL] = doc.SearchMaterial("white")
        roofTex[c4d.TEXTURETAG_PROJECTION] = 6 #UVW
        
        #inner extrude the roof
        c4d.CallCommand(450000004) # Extrude Inner
        getActiveTool()[c4d.MDATA_EXTRUDEINNER_OFFSET] = 1.5
        #return_value = utils.SendModelingCommand( command=c4d.ID_MODELING_EXTRUDE_INNER_TOOL, list=[tmpRoof], mode=c4d.MODELINGCOMMANDMODE_POLYGONSELECTION, bc=c4d.BaseContainer(), doc=doc)
                                  
        #extrude the roof lip
        doc.SetActiveObject(tmpRoof, c4d.SELECTION_NEW)
        fireAction(tmpRoof)
                                    
        c4d.CallCommand(1011183) # Extrude
        getActiveTool()[c4d.MDATA_EXTRUDE_OFFSET] = -2.0
        fireAction(tmpRoof)
        
        bbox = buildingExtrude.GetRad()

        if tallBuilding == True:
            #scale the spline down
            hvacStructureSpline[c4d.ID_BASEOBJECT_REL_SCALE,c4d.VECTOR_X] = .5
            hvacStructureSpline[c4d.ID_BASEOBJECT_REL_SCALE,c4d.VECTOR_Y] = .5
            hvacStructureSpline[c4d.ID_BASEOBJECT_REL_SCALE,c4d.VECTOR_Z] = .5
            
            #repo the new spline so it's sitting on top of the master
            hvacStructureSpline[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = -height
        
            #extrude the copy
            roofHeight = height/7
            newExtrude = extrudeSpline(hvacStructureSpline, roofHeight)
        
            #put a fillet cap on
            roofRadius = .2
            if _counter % 3 == 0:
                roofRadius = .8   
            newExtrude[c4d.CAP_END] = 3
            newExtrude[c4d.CAP_ENDRADIUS]=roofRadius
            newExtrude[c4d.CAP_ENDSTEPS]=1
            
            newExtrude[c4d.ID_BASELIST_NAME] = "hvac_housing"
            tmpTex = newExtrude.MakeTag(c4d.Ttexture)
            tmpTex[c4d.TEXTURETAG_MATERIAL] = doc.SearchMaterial("white")
            tmpTex[c4d.TEXTURETAG_PROJECTION] = 6 #UVW
            
            #put a red light on top of this
            red_light = doc.SearchObject("red_light")
            tmpRedLight = red_light.GetClone()
            tmpRedLight[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = 0
            tmpRedLight[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = 0
            tmpRedLight[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = roofHeight + height - 2
            tmpRedLight.InsertAfter(tmpRoof)                    
        
        
        if tallBuilding == False:
            
            #put an HVAC unit on the roof
            obj_to_copy = doc.SearchObject(getHVACUnit())
            
            #selection = doc.GetActiveObjects(c4d.GETACTIVEOBJECTFLAGS_SELECTIONORDER)
            #reposition the HVAC system on the roof
            new_obj = obj_to_copy.GetClone()
            new_obj[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = 0# -bbox.x
            new_obj[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = 0
            new_obj[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = (-bbox.z * 2) - 1
            new_obj[c4d.ID_BASEOBJECT_REL_ROTATION,c4d.VECTOR_Y] = 1.6
            new_obj.InsertAfter(tmpRoof)
        
        #if tallBuilding == True:
        #place a streetlight at the base of the building, on the lee side of the camera
        streetlight = doc.SearchObject("streetlight")            
        tmpStreetlight = streetlight.GetClone()
        tmpStreetlight[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = bbox.x/2
        tmpStreetlight[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = bbox.y
        tmpStreetlight[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = -1
        tmpStreetlight[c4d.ID_BASEOBJECT_REL_ROTATION,c4d.VECTOR_Y] =  1.58 #randrange(0, 360)
        #tmpStreetlight[c4d.ID_BASEOBJECT_REL_ROTATION,c4d.VECTOR_Z] = 90
        tmpStreetlight.InsertUnder(tmpRoof)
        
        #if ((height > -75) and (height < -30)):
        #let's hang some signs            
        sign = doc.SearchObject("sign1")
        
        if _counter % 3 == 0:
            sign = doc.SearchObject("sign2")   
        elif _counter % 5 == 0:
            sign = doc.SearchObject("sign3") 
        elif _counter % 7 == 0:
            sign = doc.SearchObject("sign4")     
        elif _counter % 11 == 0:
            sign = doc.SearchObject("sign5")  
        elif _counter % 13 == 0:
            sign = doc.SearchObject("sign6") 
        elif _counter % 17 == 0:
            sign = doc.SearchObject("sign7")
        elif _counter % 23 == 0:
            sign = doc.SearchObject("sign8")  
        elif _counter % 29 == 0:
            sign = doc.SearchObject("sign9")                    
                                    
        tmpSign = sign.GetClone()
        tmpSign[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = bbox.x/2
        tmpSign[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = bbox.y   
        tmpSign[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = -15
        tmpSign[c4d.ID_BASEOBJECT_REL_ROTATION,c4d.VECTOR_Y] =  1.58
        tmpSign.InsertUnder(tmpRoof)
        
        #random signmaker script...
        randSignToClone = doc.SearchObject("blank_sign")
        tmpSign2 = randSignToClone.GetClone()
        tmpSign2[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = bbox.x
        tmpSign2[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = bbox.y/2           
        tmpSign2[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = -12
        tmpSign2[c4d.ID_BASEOBJECT_REL_ROTATION,c4d.VECTOR_Y] =  1.58
        tmpSign2.InsertUnder(tmpRoof)
        
        tmpSign2[c4d.ID_BASELIST_NAME] = "randSign"+str(_counter)
        
        matToCopy = doc.SearchMaterial("color_sign")
        matClone = matToCopy.GetClone()
        matClone.SetName("NewMat"+str(_counter))
        doc.InsertMaterial(matClone)
        tmpRandTex = tmpSign2.MakeTag(c4d.Ttexture)
        tmpRandTex[c4d.TEXTURETAG_MATERIAL] = matClone
        tmpRandTex[c4d.TEXTURETAG_PROJECTION] = 6 #UVW
        tmpRandTex[c4d.SLA_TILES_GLOBAL_SCALE] = randrange(20, 500)
        tmpRandTex[c4d.TEXTURETAG_MATERIAL].GetFirstShader()[c4d.SLA_TILES_SEED] = randrange(333,1000)
        tmpColorVector1 = c4d.Vector(randrange(1,100)*.01, randrange(1,100)*.01, randrange(1,100)*.01 )
        tmpColorVector2 = c4d.Vector(randrange(1,100)*.01, randrange(1,100)*.01, randrange(1,100)*.01 )
        tmpColorVector3 = c4d.Vector(randrange(1,100)*.01, randrange(1,100)*.01, randrange(1,100)*.01 )    
        tmpRandTex[c4d.TEXTURETAG_MATERIAL].GetFirstShader()[c4d.SLA_TILES_TILE_COLOR_1] = tmpColorVector1
        tmpRandTex[c4d.TEXTURETAG_MATERIAL].GetFirstShader()[c4d.SLA_TILES_TILE_COLOR_2] = tmpColorVector2
        tmpRandTex[c4d.TEXTURETAG_MATERIAL].GetFirstShader()[c4d.SLA_TILES_TILE_COLOR_3] = tmpColorVector3
        tmpRandTex[c4d.TEXTURETAG_MATERIAL].GetFirstShader()[c4d.SLA_TILES_PATTERN] = randrange(2000,2027)
        tmpRandTex[c4d.TEXTURETAG_MATERIAL].GetFirstShader()[c4d.SLA_TILES_U_SCALE] = randrange(3,20)*.1
        tmpRandTex[c4d.TEXTURETAG_MATERIAL].GetFirstShader()[c4d.SLA_TILES_V_SCALE] = randrange(3,20)*.1
     
                    
            
def getRandomHeight():
    return randrange(30, 150)  
  
def recurse_hierarchy(op):
    while op:
        print( op.GetName() )
        
        extrudeSpline(op)
        
        exNurb = c4d.BaseObject(c4d.Oextrude)
        
        
        doc.InsertObject( exNurb )
        
        recurse_hierarchy( op.Next() )
        op = op.GetNext()
            

if __name__=='__main__':    
    main()


