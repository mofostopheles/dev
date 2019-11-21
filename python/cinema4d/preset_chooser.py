"""Name-US: Preset_Chooser v.1
Description-US: Tool for browsing and installing selected Presets. 
"""

#!/usr/bin/env python
# -*- coding: utf8 -*-

__author__ = "Arlo Emerson"
__version__ = "1"
__email__ = "arloemerson@gmail.com"
__date__= "10/15/2019"


'''
Script launces a GUI non-modal window. User can perform the following tasks:
	• Browse and select a preset (lights, cameras, etc.).
	• Selecting a preset will install the preset in the scene.
'''

PLUGIN_ID = 90899082

import c4d,os
from c4d import plugins, gui, bitmaps, utils
from c4d import documents as docs

PATH_TO_THUMBNAILS = "PATH HERE"
THUMBNAIL_SUFFIX = "asdf.jpg"
THUMBNAIL_WIDTH = 400
THUMBNAIL_HEIGHT = 300


# ===========================================================
# Main dialog class
# ===========================================================
class Preset_Chooser(c4d.gui.GeDialog):


	# ===========================================================
	# hook for building the UI
	# ===========================================================
	def CreateLayout(self):
		# NOTE: master_data is auto-generated, see code at bottom of this file
		self.master_data = {9999: {'prop1': 0.0, 'prop2': -0.32499999999999996, 'name': 'asdf', 'asdf': 2.375, 'path': 'some path', 'asdf': None}, 8888: {'prop1': 0.0, 'prop2': -0.32499999999999996, 'name': 'asdf', 'asdf': 2.375, 'path': 'some path', 'asdf': None}}
		self.SetTitle("Preset Chooser")
		self.ScrollGroupBegin(20, c4d.BFH_RIGHT, c4d.SCROLLGROUP_VERT, initw=200, inith=1000)
		self.GroupBegin(21, c4d.BFH_RIGHT, cols=1, rows=1, title="Content area", groupflags=0, initw=100, inith=100)		

		for key, items in self.master_data.items():
			self.GroupBegin(0, c4d.BFH_RIGHT | c4d.BFV_SCALEFIT, cols=2, rows=1, title="item", groupflags=0, initw=100, inith=100)
			self.GroupBorderSpace(10,10,10,10)
			tmp_name = items['name']

			self.AddStaticText(key, c4d.BFH_LEFT, name=tmp_name) 
			bc = c4d.BaseContainer()
			path = PATH_TO_THUMBNAILS + "\\" + tmp_name + THUMBNAIL_SUFFIX
			bc.SetFilename(key, path)
			bitmap_button=self.AddCustomGui( key, c4d.CUSTOMGUI_BITMAPBUTTON, \
				"bb", c4d.BFH_SCALEFIT | c4d.BFV_SCALEFIT, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT, bc)
			bitmap_button.SetImage(path, False)
			self.GroupEnd()
		self.GroupEnd()
		self.GroupEnd()
		return True

	# ===========================================================
	# capture the onclick events
	# ===========================================================
	def Command(self, pId, msg=None):
		if pId:
			# print "id: " + str(pId)
			self.install_Preset( pId )

		return True

	# ===========================================================
	# generate a new sky/environment object
	# ===========================================================
	def install_Preset(self, pId):
		sky = c4d.BaseObject(5105)
		doc = docs.GetActiveDocument()
		doc.InsertObject( sky )
		sky.SetName( self.master_data[pId]['name'] )
		sky[c4d.ID_BASEOBJECT_VISIBILITY_EDITOR] = 1

		# check if a lighting layer exists, if not, build it
		lighting_layer = self.get_layer( "Lighting" )
		if not lighting_layer:
			layer_color = c4d.Vector(0.909, 0.972, 0.019)
			lighting_layer = self.create_layer( "Lighting", layer_color )

		# add the sky to the layer
		sky[c4d.ID_LAYER_LINK] = lighting_layer
		
		# note: the following syntax will return the type number to create tags
		# print( doc.SearchObject("asdf").GetTags()[0].GetType() )

		# create the tag		
		env_tag = c4d.BaseTag(1029643)

		# acquire the data
		image_path = self.master_data[pId]['path']
		power = self.master_data[pId]['power']
		rotX = self.master_data[pId]['rotX']
		rotY = self.master_data[pId]['rotY']
		gamma = self.master_data[pId]['gamma']

		# ===========================================================
		# some examples of setting shaders
		# ===========================================================
		# example of how to add a basic bitmap shader (this is NOT an Octane IMAGETEXTURE)
		# shd = c4d.BaseList2D(c4d.Xbitmap)
		# shd[c4d.BITMAPSHADER_FILENAME] = image_path
		# env_tag[c4d.ENVIRONMENTTAG_TEXTURE] = shd
		# env_tag.InsertShader(shd)

		# here's how to add a base shader of type filter
		# shd = c4d.BaseList2D(c4d.Xbitmap)
		# img_shader = c4d.BaseShader(1011128)
		# env_tag[c4d.ENVIRONMENTTAG_TEXTURE] = img_shader
		# env_tag.InsertShader(img_shader)

		# create an Octane ImageTexture shader
		img_shader = c4d.BaseShader( 1029508 )
		env_tag[c4d.ENVIRONMENTTAG_TEXTURE] = img_shader
		env_tag.InsertShader(img_shader)

		# set the data
		env_tag[c4d.ENVIRONMENTTAG_POWER] = power
		env_tag[c4d.ENVIRONMENTTAG_ROTX] = rotX
		env_tag[c4d.ENVIRONMENTTAG_ROTY] = rotY
		# env_tag[c4d.IMAGETEXTURE_GAMMA] = gamma # TODO: determine if we need gamma
		env_tag[c4d.ENVIRONMENTTAG_TEXTURE][c4d.IMAGETEXTURE_FILE] = image_path

		sky.InsertTag(env_tag)
		c4d.EventAdd()

	# ===========================================================
	# use this to generate master array of data
	# this method must be explicitly called
	# ===========================================================
	def generate_Preset_data(self):

		doc = docs.GetActiveDocument()
		obj = doc.GetFirstObject()
		scene = ObjectIterator(obj)

		self.master_data = {}
		indexCount = 1111

		for obj in scene:
			if obj.GetTypeName() == "Sky":
				tag = obj.GetTags()[0]
				image_path = tag[c4d.ENVIRONMENTTAG_TEXTURE][c4d.IMAGETEXTURE_FILE]
				power = tag[c4d.ENVIRONMENTTAG_POWER]
				rotX = tag[c4d.ENVIRONMENTTAG_ROTX]
				rotY = tag[c4d.ENVIRONMENTTAG_ROTY]
				gamma = tag[c4d.IMAGETEXTURE_GAMMA]
				self.master_data[ indexCount ] = {'name':obj.GetName(), 'path':image_path, 'gamma':gamma, 'power':power, 'rotX':rotX, 'rotY':rotY }
				indexCount += 1
		print(self.master_data)

	def get_layer(self, pName):

		doc = docs.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_iterator = ObjectIterator(root)

		for layer in layer_iterator:
			if type(layer) == c4d.documents.LayerObject:
				name = layer.GetName()
				if (pName == name):
					return layer
		return None

	def get_layer_color(self):

		doc = docs.GetActiveDocument()
		root = doc.GetLayerObjectRoot()
		layers = root.GetChildren()
		layer_iterator = ObjectIterator(root)

		for layer in layer_iterator:
			if type(layer) == c4d.documents.LayerObject:
				name = layer.GetName()
				if ("Lighting" == name):
					print( layer[c4d.ID_LAYER_COLOR] )

	def create_layer(self, pName, pColor):
		
		doc = docs.GetActiveDocument()
		layer = c4d.documents.LayerObject()
		layer[c4d.ID_LAYER_COLOR] = pColor
		layer.SetName(pName)
		layerRoot = doc.GetLayerObjectRoot()
		layer.InsertUnder(layerRoot)
		c4d.EventAdd()
		return layer

	def identify_object_type(self):

		doc = docs.GetActiveDocument()
		obj = doc.GetFirstObject()
		scene = ObjectIterator(obj)
		
		for obj in scene:
			if obj.GetTypeName() == "Sky":
				# print( dir(obj) )
				# print( obj.GetType(), obj.GetTypeName() ) # (5105, 'Sky')
				print( obj.GetTags()[0].GetFirstShader()  ) # returns 1029508, this is an octane ImageTexture
				break



# ===========================================================
# iterator class 
# ===========================================================
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

# ===========================================================
# launcher class for plug-in hook 
# ===========================================================
class Preset_Chooser_Launcher(c4d.plugins.CommandData):
	dialog = None

	def Execute(self, doc):
		if self.dialog is None:
			self.dialog = Preset_Chooser()

		return self.dialog.Open(dlgtype=c4d.DLG_TYPE_ASYNC, pluginid=PLUGIN_ID, defaultw=400, defaulth=1000)

	def RestoreLayout(self, sec_ref):
		if self.dialog is None:
			self.dialog = Preset_Chooser()

		return self.dialog.Restore(pluginid=PLUGIN_ID, secret=sec_ref)



# ===========================================================
# use as a plug-in...
# uncomment this for production use as a plug-in
# ===========================================================
# if __name__ == "__main__":
#	 plugins.RegisterCommandPlugin(id=PLUGIN_ID, str="Preset Chooser",
#								  help="Tool to browse and install Presets environment presets.",
#								  info=0,
#								  dat=Preset_Chooser_Launcher(),
#								  icon=bitmaps.InitResourceBitmap(c4d.Oplatonic))


# ===========================================================
# use as a script...
# ===========================================================
if __name__=='__main__':
	dlg = Preset_Chooser()
	# dlg.identify_object_type()
	# dlg.get_layer_color()
	# dlg.generate_Preset_data() # toggle this to generate a list of Preset data
	dlg.Open(c4d.DLG_TYPE_ASYNC, xpos=2000, ypos=20, defaultw=400, defaulth=1000)