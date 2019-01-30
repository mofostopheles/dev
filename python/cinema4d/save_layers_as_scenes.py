import c4d
from c4d import gui
'''
__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__status__  = "production"
__version__ = "1.0"
__date__    = "13 July 2018"

WHAT IT IS
Automated layer toggle+file-save script for separating each identified layer into its own scene file...This is useful because Octane doesn't offer this feature, only a manual setting of layerID (one at a time), nice but tedious if you have lots of things needing to be rendered separately at various samples/depths. It is a little different than using the Octane Render layer functionality in that you won't get occlusion effects which is really what that feature is great for. However, you can save yourself a bit of time by placing objects to be occluded on their own layer e.g. "power_cord", then enabling Render Layer for just that one project file. 

This script does the following actions: 

    1: starts out by turning off visibility and render for all layers
    2: for each layer, turn on the vis/render and then...
    3: save a copy of the project, appending the layer name to whatever your base name is.
    IMPORTANT: basename should end in a dash. Change this in the code to suit your needs.

You will end up with several projects with the appropriate layers turned on and all others turned off. Any objects not on a layer will of course be visible/renderable by default.

USAGE
Under Render Settings, Save tab, Regular Image file name should be something terminating in a dash e.g. d:\path\to\project\BASENAME-

Run the script. A series of Save-as dialogs will appear, simply hit Save as these cycle through. The last layer's project file will be left open. 

Tested on r13. Please report bugs to the author.
'''

#--- LICENSE ------------------------------------------------------------------
# This code contained in save_layers_as_scenes.py and covered by the MIT License.

# MIT License

# Copyright (c) 2017, 2018 Arlo Emerson, arloemerson@gmail.com

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


def main():
    _root = doc.GetLayerObjectRoot()
    _layerList = _root.GetChildren()
    
    _renderData = doc.GetActiveRenderData()
    _pathName = _renderData[c4d.RDATA_PATH]
    
    #turn off visibility and render for all layers 
    for tmpLayer in _layerList:
        print( tmpLayer.GetName() )
        _layerData = tmpLayer.GetLayerData(doc)
        _layerData['render'] = False
        _layerData['view'] = False
        tmpLayer.SetLayerData(doc,_layerData)
        c4d.EventAdd()
    
    #loop each layer
    #toggle the layer's vis/render, then:
    #save a copy with [LAYER_NAME]
    #next, re-toggle the layer back to off/off
    #loop will repeat this process
    for tmpLayer in _layerList:
        _layerData = tmpLayer.GetLayerData(doc)
        #toggle the properties
        _layerData['render'] = not _layerData['render']
        _layerData['view'] = not _layerData['view']
        tmpLayer.SetLayerData(doc,_layerData)
        c4d.EventAdd()
        _pathName = _pathName[0:_pathName.rfind("-")+1]

        _projectFileName = _pathName +  tmpLayer.GetName()
        
        print("current path to output render: " + _projectFileName )
        
        _renderData[c4d.RDATA_PATH] = _projectFileName
        c4d.EventAdd()
        doc.SetDocumentName( _projectFileName )
        c4d.CallCommand(12218) # Save as...
        
        #toggle layer properties back to original state
        _layerData['render'] = not _layerData['render']
        _layerData['view'] = not _layerData['view']
        tmpLayer.SetLayerData(doc,_layerData)
        c4d.EventAdd()
               
if __name__=='__main__':
    main()
