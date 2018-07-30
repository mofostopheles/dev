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

def main():
    _root = doc.GetLayerObjectRoot()
    _layerList = _root.GetChildren()
    
    _renderData = doc.GetActiveRenderData()
    _pathName = _renderData[c4d.RDATA_PATH]
    
    # doc = docs.GetActiveDocument()
    obj = doc.GetFirstObject()
    scene = ObjectIterator(obj)

    for obj in scene:
        # turn off all lights
        if "light-" in obj.GetName().lower():
            #print("turning off lights")
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 1
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 1
            obj[c4d.ID_BASEOBJECT_GENERATOR_FLAG] = False
            c4d.EventAdd()

        # make sure table light is turned on
        if obj.GetName() == "OctaneDayLight":
            #print("found the sun")
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 1
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 1
            obj[c4d.ID_BASEOBJECT_GENERATOR_FLAG] = 0

        # make sure table is turned on
        if "light-table" in obj.GetName().lower():
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 0
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 0
            obj[c4d.ID_BASEOBJECT_GENERATOR_FLAG] = 1

        # sky-flat is off, detail is on
        if "sky-flat" in obj.GetName().lower():
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 1
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 1

        if "sky-detail" in obj.GetName().lower():
            obj[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 0
            obj[c4d.ID_BASEOBJECT_VISIBILITY_RENDER] = 0

        # print( scene.depth, scene.depth*'    ', obj.GetName() )


if __name__=='__main__':
    main()
