import c4d
from c4d import gui, plugins
from random import *

def getTool():
    return doc.GetActiveToolData()

def main():
    
    
    '''
    c4d.CallCommand(5159) # Cube
    c4d.CallCommand(200000089) # Scale
    c4d.CallCommand(200000088) # Move
    c4d.CallCommand(200000089) # Scale
    c4d.CallCommand(200000088) # Move
    c4d.CallCommand(12236) # Make Editable
    c4d.CallCommand(1021387) # Scale
    
    c4d.CallCommand(450000004) # Extrude Inner
    getTool()[c4d.MDATA_EXTRUDEINNER_OFFSET]=3.3
    #c4d.CallButton( c4d.BaseList2D.GetData(tool()) ,c4d.MDATA_APPLY)
    
    tool = plugins.FindPlugin(doc.GetAction(), c4d.PLUGINTYPE_TOOL)
    if tool is not None:
        tool[c4d.MDATA_TRANSFER_OBJECT_LINK] = doc.GetFirstObject()
        c4d.CallButton(tool, c4d.MDATA_APPLY)
        c4d.EventAdd()
    
    
    someSpline = doc.GetFirstObject().GetChildren()[1]
    c4d.CallCommand(12102) # Enable Axis
    [c4d.ID_BASEOBJECT_REL_ROTATION,c4d.VECTOR_Y]
    '''
    
        
    matToCopy = doc.SearchMaterial("color_sign")
    matClone = matToCopy.GetClone()
    matClone.SetName("NewMat")
    doc.InsertMaterial(matClone)
    
    sign9 = doc.SearchObject("blank_sign")
    tmpRandTex = sign9.MakeTag(c4d.Ttexture)
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

    #the most useful little method for seeing what's inside an object
    #for v in dir(tmpRandTex):
    #    print( v)
    #print()
    
        
        
        
        
    

if __name__=='__main__':
    main()


