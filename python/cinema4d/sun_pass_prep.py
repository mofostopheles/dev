import c4d
from c4d import gui
from c4d import documents as docs

# this particular script designed for wifi_v26.py

'''
__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__status__  = "production"
__version__ = "1.0"
__date__    = "17 July 2018"

'''
# using some stuff from
# http://cgrebel.com/2015/03/c4d-python-scene-iterator/

class ObjectIterator :
    def __init__(self, baseObject):
        self.baseObject = baseObject
        self.currentObject = baseObject
        self.objectStack = []
        self.depth = 0
        self.nextDepth = 0

    def __iter__(self):
        return self

    def next(self):
        if self.currentObject == None :
            raise StopIteration

        obj = self.currentObject
        self.depth = self.nextDepth

        child = self.currentObject.GetDown()
        if child :
            self.nextDepth = self.depth + 1
            self.objectStack.append(self.currentObject.GetNext())
            self.currentObject = child
        else :
            self.currentObject = self.currentObject.GetNext()
            while( self.currentObject == None and len(self.objectStack) > 0 ) :
                self.currentObject = self.objectStack.pop()
                self.nextDepth = self.nextDepth - 1
        return obj

class TagIterator:

    def __init__(self, obj):
        currentTag = None
        if obj :
            self.currentTag = obj.GetFirstTag()

    def __iter__(self):
        return self

    def next(self):
        tag = self.currentTag
        if tag == None :
            raise StopIteration

        self.currentTag = tag.GetNext()
        return tag

class MaterialIterator:
    def __init__(self, doc):
        self.doc = doc
        self.currentMaterial = None
        if doc == None : return
        self.currentMaterial = doc.GetFirstMaterial()

    def __iter__(self):
        return self

    def next(self):
        if self.currentMaterial == None :
            raise StopIteration

        mat = self.currentMaterial
        self.currentMaterial = self.currentMaterial.GetNext()
        return mat


def main():
    _root = doc.GetLayerObjectRoot()
    _layerList = _root.GetChildren()
    
    _renderData = doc.GetActiveRenderData()
    _pathName = _renderData[c4d.RDATA_PATH]
    
    #turn ON visibility and render for all layers 
    for tmpLayer in _layerList:
        # print( tmpLayer.GetName() )
        _layerData = tmpLayer.GetLayerData(doc)
        _layerData['render'] = True
        _layerData['view'] = True
        tmpLayer.SetLayerData(doc,_layerData)
        c4d.EventAdd()
    
    # sky-flat ON
    # sky-detail OFF
    # table ON, put matte texture on outer, or remove neutral
    
    # doc = docs.GetActiveDocument()
    obj = doc.GetFirstObject()
    scene = ObjectIterator(obj)

    for obj in scene:
        # turn off camera visibility, turn on shadow
        if obj.GetName().lower() == "cord":
            #print("turn off camera vis, leave shadow on")
            tags = TagIterator(obj)
            for tag in tags:
                # print(tag.GetTypeName())
                if "Octane" in tag.GetTypeName():
                    tag[c4d.OBJECTTAG_CAM_VISIBILITY] = False
                    tag[c4d.OBJECTTAG_SHADOW_VISIBILITY] = True
        
        # anything with product in name is toggled vis off, shadow on
        if "product" in obj.GetName():
            #print("turn off camera vis, leave shadow on")

            tags = TagIterator(obj)
            for tag in tags:
                # print(tag.GetTypeName())
                if "Octane" in tag.GetTypeName():
                    tag[c4d.OBJECTTAG_CAM_VISIBILITY] = False
                    tag[c4d.OBJECTTAG_SHADOW_VISIBILITY] = True

                    for track in tag.GetCTracks():
                        trackName=track.GetName()
                        # print(trackName)
                        if "Camera visibility" in trackName:
                            track.Remove()

        # turn off all lights
        if "light-" in obj.GetName().lower():
            #print("turning off lights")
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 1
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 1
            obj[c4d.ID_BASEOBJECT_GENERATOR_FLAG] = False
            c4d.EventAdd()

        # make sure sun is turned on
        if obj.GetName() == "OctaneDayLight":
            #print("found the sun")
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 0
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 0
            obj[c4d.ID_BASEOBJECT_GENERATOR_FLAG] = True

        # make sure table is turned on
        if obj.GetName().lower() == "table":
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 0
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 0

            # loop the tags and delete the neutral texture
            # but make sure there is a matte texture
            tags = TagIterator(obj)
            for tag in tags:
                # print( str( tag[c4d.TEXTURETAG_MATERIAL] )) 
                if "neutral" in str( tag[c4d.TEXTURETAG_MATERIAL] ):
                    # print("delete the neutral texture")
                    tag.Remove()
                    c4d.EventAdd()

        # sky-flat is on
        if "sky-flat" in obj.GetName().lower():
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 0
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 0

        if "sky-detail" in obj.GetName().lower():
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 1
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 1

        # print( scene.depth, scene.depth*'    ', obj.GetName() )


if __name__=='__main__':
    main()
