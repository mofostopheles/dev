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
        #            gui.MessageDialog(tool)
        tool[c4d.MDATA_TRANSFER_OBJECT_LINK] = pObj
        c4d.CallButton(tool, c4d.MDATA_APPLY)
        c4d.EventAdd()

def main():
    
    #loop everything under "test_map" object
    
    #add an Extrude Nurbs object
    
    #move current spline under Nurb
    
    doc = c4d.documents.GetActiveDocument()

    if doc:
        # Iterate all objects in the document
        #recurse_hierarchy( doc.GetFirstObject() )
        #print( doc.GetFirstObject().GetDown() )
        loopAllItems(  doc.GetFirstObject().GetDown() )
    
def extrudeSpline(spline, pHeight):
    #print('extrude spline')
    extrude = c4d.BaseObject(c4d.Oextrude)
    extrude[c4d.ID_BASELIST_NAME] = str("nurb_") + spline.GetName()
    
    #TODO: add a depth the extrusion
    
    v = c4d.Vector(0,0,-pHeight)
    extrude[c4d.EXTRUDEOBJECT_MOVE] = v
    extrude.InsertAfter(spline)
    c4d.EventAdd()
    spline.Remove()
    spline.InsertUnder(extrude)
    c4d.EventAdd()
    return extrude

def getRoofMaterial():
    global _counter
    
    if _counter % 2 == 0:
        return "gravel"
    elif _counter % 3 ==0:
        return "stone1"
    else:
        return "concrete1"
    
def getMainBuildingMaterial():
    global _counter
    
    if _counter % 2 == 0:
        return "exterior2"
    elif _counter % 3 == 0:
        return "exterior3"
    elif _counter % 4 == 0:
        return "exterior4"
    elif _counter % 11 == 0:
        return "brick1"
    else:
        return "exterior1"
    
    
    
def loopAllItems( pObj ):
    global _counter
    _counter = _counter + 1
    
    if pObj:    
        #print(pObj)
        makeARoofThingy = False
        
        #put the spline into a NULL
        splineCopy = pObj
        tmpNull = c4d.BaseObject(c4d.Onull)
        tmpNull.InsertAfter(pObj)
        c4d.EventAdd()
        pObj.Remove()
        pObj.InsertUnder(tmpNull)
        
        #EXTRUDE the spline
        height = getRandomHeight()
        buildingExtrude = extrudeSpline(pObj, height)
        
        #CLONE spline here and modify it
        
        if _counter % 3 == 0:
            makeARoofThingy = True
            splineCopy = pObj.GetClone()
            splineCopy.InsertUnder(tmpNull)
        
        
        tex = buildingExtrude.MakeTag(c4d.Ttexture)
        tex[c4d.TEXTURETAG_MATERIAL] = doc.SearchMaterial(getMainBuildingMaterial())
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
        tmpRoof[c4d.ID_BASELIST_NAME] = "foofy"
        roofTex = tmpRoof.MakeTag(c4d.Ttexture)
        roofTex[c4d.TEXTURETAG_MATERIAL] = doc.SearchMaterial(getRoofMaterial())
        roofTex[c4d.TEXTURETAG_PROJECTION] = 6 #UVW
        
        #inner extrude the roof
        c4d.CallCommand(450000004) # Extrude Inner
        getActiveTool()[c4d.MDATA_EXTRUDEINNER_OFFSET] = 0.16
        #return_value = utils.SendModelingCommand( command=c4d.ID_MODELING_EXTRUDE_INNER_TOOL, list=[tmpRoof], mode=c4d.MODELINGCOMMANDMODE_POLYGONSELECTION, bc=c4d.BaseContainer(), doc=doc)
                                  
        #extrude the roof lip
        doc.SetActiveObject(tmpRoof, c4d.SELECTION_NEW)
        fireAction(tmpRoof)
                                    
        c4d.CallCommand(1011183) # Extrude
        getActiveTool()[c4d.MDATA_EXTRUDE_OFFSET] = -0.14
        fireAction(tmpRoof)

        if makeARoofThingy == True:
            #scale the spline down
            splineCopy[c4d.ID_BASEOBJECT_REL_SCALE,c4d.VECTOR_X] = .5
            splineCopy[c4d.ID_BASEOBJECT_REL_SCALE,c4d.VECTOR_Y] = .5
            splineCopy[c4d.ID_BASEOBJECT_REL_SCALE,c4d.VECTOR_Z] = .5
            
            #repo the new spline so it's sitting on top of the master
            splineCopy[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = -height
        
            #extrude the copy
            roofHeight = .3+ height/7
            newExtrude = extrudeSpline(splineCopy, roofHeight)
        
            #put a fillet cap on
            roofRadius = 0
            if _counter % 3 == 0:
                roofRadius = .03   
            newExtrude[c4d.CAP_END] = 3
            newExtrude[c4d.CAP_ENDRADIUS]=roofRadius
            newExtrude[c4d.CAP_ENDSTEPS]=1
            
            newExtrude[c4d.ID_BASELIST_NAME] = "hvac_housing"
            tmpTex = newExtrude.MakeTag(c4d.Ttexture)
            tmpTex[c4d.TEXTURETAG_MATERIAL] = doc.SearchMaterial("roof1")
            tmpTex[c4d.TEXTURETAG_PROJECTION] = 6 #UVW
        
        if makeARoofThingy == False:
            #put an HVAC unit on the roof
            #print( doc.SearchObject("HVAC_system_copy")  )
            obj_to_copy = doc.SearchObject("HVAC_system_copy")
            
            #selection = doc.GetActiveObjects(c4d.GETACTIVEOBJECTFLAGS_SELECTIONORDER)
            new_obj = obj_to_copy.GetClone()
            bbox = buildingExtrude.GetRad()
            new_obj[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_X] = 0# -bbox.x
            new_obj[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Y] = 0#-bbox.y
            new_obj[c4d.ID_BASEOBJECT_REL_POSITION,c4d.VECTOR_Z] = (-bbox.z * 2) - .3
            new_obj[c4d.ID_BASEOBJECT_REL_ROTATION,c4d.VECTOR_Y] = 1.6
            new_obj.InsertAfter(tmpRoof)

#START IT ALL OVER AGAIN
        #print( extrude.GetNext().GetName()  )
        if tmpNull.GetNext().GetName() != '':
            loopAllItems(tmpNull.GetNext())
    
        
def getRandomHeight():
    return randrange(3, 11)  
  
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


