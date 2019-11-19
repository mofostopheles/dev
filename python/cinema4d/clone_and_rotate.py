import c4d
from c4d import plugins
from c4d import gui, utils
from c4d import documents as docs
from math import *
from random import *

__author__ = "Arlo Emerson"
__version__ = "1.0.0"
__email__ = "arloemerson@gmail.com"

# clone and rotate an object
# use a list of rotations to iterate through

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

class Worker:
	def centerAxis(self, obj):
		bBoxCenter = obj.GetMp() #Get the center of bounding box (local space)
		
		#Extract the original global matrix
		objMg = obj.GetMg()
		objPos = objMg.off
		objV1 = objMg.v1
		objV2 = objMg.v2
		objV3 = objMg.v3
		
		#Take rotation into consideration
		rot = obj.GetAbsRot()
		rotOrder = obj.GetRotationOrder()
		rotM = utils.HPBToMatrix(rot,rotOrder)
		
		newCenter = bBoxCenter * rotM + objPos #Bounding box center in Global space
		offsetV =  - bBoxCenter #This vector is used to offset all the points
		
		#Step2(It doesn’t matter which step goes first): offset all the points to the new center
		allPts = obj.GetAllPoints() #Local Space
		for i in xrange(len(allPts)):
			doc.AddUndo(c4d.UNDOTYPE_CHANGE,obj)
			obj.SetPoint(i,allPts[i] + offsetV)
			
		obj.Message(c4d.MSG_UPDATE)
		
		#Step1:Set the obj's postion to Bounding box Center
		newMg = c4d.Matrix(newCenter,objV1,objV2,objV3)
		doc.AddUndo(c4d.UNDOTYPE_CHANGE,obj)
		obj.SetMg(newMg)

	def p(self, pString):
		print(pString)

		doc = docs.GetActiveDocument()
		obj = doc.GetFirstObject()
		scene = ObjectIterator(obj)
		tools = Tools()

		doc.StartUndo()

		tmpNull = c4d.BaseObject(c4d.Onull)
		tmpNull.InsertAfter(obj)
		tmpNull[c4d.ID_BASELIST_NAME] = "_null_name"
		doc.AddUndo(c4d.UNDOTYPE_NEW, tmpNull)

		_object_name = doc.SearchObject("_object_name")


		for obj in scene:
			if ("cap_X" in obj.GetName()):
				# print("\t swapping out " + obj.GetName())

				clone = _object_name.GetClone()						
				objMg = obj.GetMg() #global matrix
				bBoxCenter = obj.GetMp() #Get the center of bounding box (local space)
				clone.SetMg(objMg)

				# clone.SetModelingAxis( obj.GetModelingAxis(doc) )
				# print(objMg.off)
				# clone.InsertUnder(obj)
				# axi=obj.GetAbsPos()
				# clone.SetAbsPos(axi)
				# cen=obj.GetMp()
				# clone.SetMp(cen)
				# clone.SetRelPos( obj.GetRelPos() )
				# clone.SetAbsPos( obj.GetAbsPos() )
				# clone.SetAbsRot( obj.GetAbsRot() )
				# clone.SetAbsScale( obj.GetAbsScale() )

				# offsetV = 0 # - bBoxCenter #This vector is used to offset all the points
				# allPts = clone.GetAllPoints() #Local Space
				# for i in xrange(len(allPts)):
				# 	doc.AddUndo(c4d.UNDOTYPE_CHANGE, clone)
				# 	clone.SetPoint(i,allPts[i] + offsetV)

				# clone.InsertAfter(obj)

				clone.InsertUnder(tmpNull)
				clone.Message(c4d.MSG_UPDATE)
				doc.AddUndo(c4d.UNDOTYPE_NEW, clone)
			
			# print(scene.depth, scene.depth*'	', obj.GetName())

	def work(self):

		master_obj = doc.SearchObject("NAME_OF_RIG")
		list_of_angles = [11.25, 22.5, 33.75, 45.0, 56.25, 67.5, 78.75, 90.0, 101.25, 112.5, 123.75, 135.0, 146.25, 157.5, 168.75, 180.0, 191.25, 202.5, 213.75, 225.0, 236.25, 247.5, 258.75, 270.0, 281.25, 292.5, 303.75, 315.0, 326.25, 337.5, 348.75, 360.0]
		counter = 1

		for angle in list_of_angles:
			clone = master_obj.GetClone()	
			clone[c4d.ID_BASEOBJECT_REL_ROTATION, c4d.VECTOR_Y] = c4d.utils.Rad(angle)		
			clone.InsertAfter( master_obj )
			clone.SetName( "NAME_OF_RIG-" + str(counter)) 
			counter += 1

		c4d.EventAdd() 

	def construct_angles(self):
		starting_value = 0
		list_string = "["

		for i in range (0, 32):
			starting_value += 11.25
			print(starting_value)
			list_string += str(starting_value) + ", "

		list_string += "]"
		print(list_string)

w = Worker()
w.work()
# w.construct_angles()