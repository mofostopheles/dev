"""
	1/30/2017 
	@author Arlo Emerson
	arloemerson@gmail.com

	gui wrapper of a thumbnail and contact sheet generator.
	stores the last locations of dest/source folders so user doesn't mess with command line or source code editing.

	utilizes work by Carl Bednorz and Hugo
	see http://code.activestate.com/recipes/578267-use-pil-to-make-a-contact-sheet-montage-of-images/

	TODOs:
	lots. needs exception handling and instrumentation to name a few.
	
	Features:
	- form validation and feedback
	- strings localization
	- status box messages
"""

__author__ = "Arlo Emerson"
__version__ = "1.0"
__email__ = "arloemerson@gmail.com"
__license__ = "GPL 3.0"

from Tkinter import *
import ttk
import json
from pprint import pprint
from tkFileDialog import askopenfilename, askdirectory
from thumbs_gen_v2 import ThumbnailMaker
import contact_sheet_v1 as cs
import glob
from datetime import datetime as dt
import strings_EN as strings_en
import subprocess
import sys


class ThumbnailGUI():

	def __init__(self):
		self.root = Tk()
		self.root.title("Make Thumbnail Grid")

		self.mainframe = ttk.Frame(self.root, padding="3 3 12 12")
		self.mainframe.grid(column=0, row=0, sticky=('N', 'W', 'E', 'S'))
		self.mainframe.columnconfigure(0, weight=1)
		self.mainframe.rowconfigure(0, weight=1)

		self.sourceDir = StringVar()
		self.destDir = StringVar()
		self.thumbnailSize = StringVar()
		self.gridWidth = StringVar()
		self.gridHeight = StringVar()
		self.gutter = StringVar()
		self.margins = StringVar()

		self.statusMessage = StringVar()

		#read from a local file to see if we have a source/dest directory path stored
		with open('make_thumbs.json', 'r+') as data_file:    
			self.data = json.load(data_file)

		data_file.close()

		self.sourceDir = self.data["sourceDirectory"]
		self.destDir = self.data["destinationDirectory"]
		self.thumbnailSize.set( self.data["thumbnailSize"] )
		self.gridWidth.set( self.data["gridWidth"] )
		self.gridHeight.set( self.data["gridHeight"] )
		self.gutter.set( self.data["gutter"] )
		self.margins.set( self.data["margins"] )

		self.source_label = ttk.Label(self.mainframe, text=strings_en.LABEL_SOURCE)
		self.source_label.grid(column=1, row=1, sticky=E)
		self.source_button = ttk.Button(self.mainframe, text=self.sourceDir, command=self.chooseSourceDir)
		self.source_button.grid(column=2, row=1, sticky=W)

		self.dest_label = ttk.Label(self.mainframe, text=strings_en.LABEL_destination)
		self.dest_label.grid(column=1, row=2, sticky=E)
		self.dest_button = ttk.Button(self.mainframe, text=self.destDir, command=self.chooseDestDir)
		self.dest_button.grid(column=2, row=2, sticky=W)

		self.thumbnail_size_label = ttk.Label(self.mainframe, text=strings_en.LABEL_thumbnail_size)
		self.thumbnail_size_label.grid(column=1, row=3, sticky=E)
		self.thumbnail_size_text = ttk.Entry(self.mainframe, width=4, textvariable=self.thumbnailSize)
		self.thumbnail_size_text.grid(column=2, row=3, sticky=W)

		self.grid_width_label = ttk.Label(self.mainframe, text=strings_en.LABEL_grid_width)
		self.grid_width_label.grid(column=1, row=4, sticky=E)
		self.grid_width_text = ttk.Entry(self.mainframe, width=4, textvariable=self.gridWidth)
		self.grid_width_text.grid(column=2, row=4, sticky=W)
		
		self.grid_height_label = ttk.Label(self.mainframe, text=strings_en.LABEL_grid_height)
		self.grid_height_label.grid(column=1, row=5, sticky=E)
		self.grid_height_text = ttk.Entry(self.mainframe, width=4, textvariable=self.gridHeight)
		self.grid_height_text.grid(column=2, row=5, sticky=W)

		self.gutter_label = ttk.Label(self.mainframe, text=strings_en.LABEL_gutter)
		self.gutter_label.grid(column=1, row=6, sticky=E)

		self.gutter_text = ttk.Entry(self.mainframe, width=4, textvariable=self.gutter)
		self.gutter_text.grid(column=2, row=6, sticky=W)

		self.margin_label = ttk.Label(self.mainframe, text=strings_en.LABEL_margin)
		self.margin_label.grid(column=1, row=7, sticky=E)
		self.margin_text = ttk.Entry(self.mainframe, width=4, textvariable=self.margins)
		self.margin_text.grid(column=2, row=7, sticky=W)

		self.messages_label = ttk.Label(self.mainframe, text=strings_en.LABEL_messages)
		self.messages_label.grid(column=1, row=8, sticky=(N,E))

		self.status_label = ttk.Label(self.mainframe, text=strings_en.LABEL_status)
		#self.status_label.configure(foreground="white", background="black")
		self.status_label.configure(width="50", wraplength=300)
		self.status_label.grid(column=2, row=8, sticky=(W, E))
		
		self.makegrid_button = ttk.Button(self.mainframe, text=strings_en.LABEL_makegrid, command=self.makeGrid)
		self.makegrid_button.grid(column=2, row=9, sticky=(E))

		for child in self.mainframe.winfo_children(): child.grid_configure(padx=5, pady=5)

		# self.root.bind('<Return>', self.makeGrid)
		self.root.mainloop()

	def saveData(self):
		"""
			example....

			{"thumbnailSize": "60",
			"destinationDirectory": "D:/_projects/Essence/round2/art/thumbs2/",
			"sourceDirectory": "D:/_projects/Essence/round2/art/source_images/",
			"gridWidth": "5",
			"gridHeight": "2",
			"margins": 10}
		"""
		d = {"sourceDirectory":self.sourceDir, \
			"destinationDirectory":self.destDir, \
			"thumbnailSize":self.thumbnailSize.get(), \
			"gridWidth":self.gridWidth.get(), \
			"gridHeight":self.gridHeight.get(), \
			"gutter":self.gutter.get(), \
			"margins":self.margins.get()
			}
		json.dump(d, open('make_thumbs.json', 'w'))

	def makeGrid(self):
		self.clearValidation()
		if self.formValidation() == True:

			#update the local db
			self.saveData()

			#try:
			tmpSize = int(self.thumbnailSize.get())
			tm = ThumbnailMaker(self.sourceDir, self.destDir, int(self.thumbnailSize.get()), self )
			tm.runProcess()

			# generate contact sheet 
			ncols,nrows = int(self.gridWidth.get()),int(self.gridHeight.get())

			files = glob.glob( str( self.destDir )  + '*.png')

			# Don't bother reading in files we aren't going to use
			if len(files) > ncols*nrows: files = files[:ncols*nrows]

			# These are all in terms of pixels:
			photow,photoh = int(self.thumbnailSize.get()),int(self.thumbnailSize.get())
			photo = (photow,photoh)
			margin =  int(self.margins.get())

			# TODO make individual GUI fields for margin, not sure the value of this feature at this point
			margins = [margin,margin,margin,margin]
			padding = int(self.gutter.get())

			inew = cs.make_contact_sheet(files,(ncols,nrows),photo,margins,padding)

			strDirectory = str(self.destDir)
			strFileName = strings_en.GRID_FILE_NAME + \
							str(dt.now().month) + "-" + \
							str(dt.now().day) + "_" + \
							str(dt.now().hour) + "-" + \
							str(dt.now().minute) + "-" + \
							str(dt.now().second) + \
							".png"

			inew.save(strDirectory + strFileName)

			self.status_label["text"] = strings_en.FILE_HAS_BEEN_CREATED + "\n" + strDirectory + strFileName
			print("file '" + strDirectory + strFileName + "' has been created.")
			#askopenfilename(initialdir=strDirectory, initialfile=strFileName)
			#self.openFolder(strDirectory)
			# except Exception as e:
			# 	print(e)
			# else: 
			# 	pass

	def openFolder(self, pDirectory):
		if sys.platform == 'darwin':
			subprocess.Popen(['open', '--', pDirectory])
		elif sys.platform == 'linux2':
			subprocess.Popen(['xdg-open', '--', pDirectory])
		elif sys.platform == 'win32':
			subprocess.Popen(['explorer', pDirectory])

	def formValidation(self):
		noflags = True
		if self.source_button["text"] == "":
			self.source_label.configure(foreground="red")
			noflags = False
		if self.dest_button["text"] == "":
			self.dest_label.configure(foreground="red")
			noflags = False
		if self.thumbnailSize.get() == "" or \
			self.thumbnailSize.get() == "0":
			self.thumbnail_size_label.configure(foreground="red")
			noflags = False
		if self.gridWidth.get() == "" or \
			self.gridWidth.get() == "0":
			self.grid_width_label.configure(foreground="red")
			noflags = False
		if self.gridHeight.get() == "" or \
			self.gridHeight.get() == "0":
			self.grid_height_label.configure(foreground="red")
			noflags = False												
		if self.gutter_text.get() == "":
			self.gutter_label.configure(foreground="red")
			noflags = False
		if self.margins.get() == "":
			self.margin_label.configure(foreground="red")
			noflags = False			
		return noflags

	def clearValidation(self):
		self.source_label.configure(foreground="black")
		self.dest_label.configure(foreground="black")
		self.thumbnail_size_label.configure(foreground="black")
		self.grid_width_label.configure(foreground="black")
		self.grid_height_label.configure(foreground="black")
		self.gutter_label.configure(foreground="black")
		self.margin_label.configure(foreground="black")

	def chooseSourceDir(self):
		dirName = askdirectory()
		if dirName != "":
			self.sourceDir = dirName + "/"
			self.updateSourceDirButtonText()

	def chooseDestDir(self):
		dirName = askdirectory()
		if dirName != "":
			self.destDir = dirName + "/"
			self.updateDestDirButtonText()

	def updateSourceDirButtonText(self):
		self.source_button["text"] = self.sourceDir

	def updateDestDirButtonText(self):
		self.dest_button["text"] = self.destDir

	def updateStatusLabel(self, pString):
		self.status_label["text"] = pString

# kick off the app here...
tg = ThumbnailGUI()
    

