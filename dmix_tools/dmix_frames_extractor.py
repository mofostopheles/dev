# -*- coding: utf8 -*-
'''
	ABOUT
	This is a script to be run after rendering all layers from a DMIX project.
	Because of Google's requirement that headlines be in PNG format (they could
	just as easily live on the header-footer layer as a MOV), it is most efficient to render
	those text layers as PNG sequences. 

	Store your ad types and frame numbers of the frame you want to extract (typically the first), 
	you do this in a CSV file. See "frames_dmix_project_name_here.csv" for an example.

	This is yet another script that will shave minutes off each cycle and buy more time
	for your personal use. Enjoy!

	USAGE
	• Place this script the level above your __render folder.
	• Set the frames to extract in the mappings below. This will be a per project script.
	• Run from command line.
	• Will add args as needed.

	LICENSE
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Lesser General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
'''

__author__ = "Arlo Emerson <arloemerson@gmail.com>"
__version__ = "1.0"
__date__ = "8/19/2020"

import sys
import os
import glob
import csv
import sqlite3
import subprocess

# we are using SQL as a replacement for dictionary-based data storage
class TempDBMaker():

	def __init__(self):
		self.db = sqlite3.connect(':memory:')
		self.cur = None
		self.rows = None

		def init_db(cur):
		    self.cur.execute('''CREATE TABLE HeadlineFrames (
		        ADTYPE TEXT,
		        F1 TEXT,
		        F2 TEXT,
		        F3 TEXT,
		        F4 TEXT)''')

		def populate_db(cur, csv_fp):
		    rdr = csv.reader(csv_fp)
		    self.cur.executemany('''
		        INSERT INTO HeadlineFrames (ADTYPE, F1, F2, F3, F4)
		        VALUES (?,?,?,?,?)''', rdr)

		self.cur = self.db.cursor()
		init_db(self.cur)
		# todo...make this arg driven...
		# but, then again...what's the difference?
		populate_db(self.cur, open('frames_dmix_project_name_here.csv'))
		self.db.commit()
		self.cur.execute("SELECT * FROM HeadlineFrames")
		self.rows = self.cur.fetchall()

	def getTableRows(self):
		for row in self.rows:
		    print(row[0] , row[1], row[2], row[3], row[4])
		return self.rows


class Extractor():	
	""" Instantiate a mysql3 database that loads our file name patterns. Extract matches to temp folder. """
	def __init__(self):

		self.tableRows = TempDBMaker().getTableRows()
		self.file_type = ".png"

	def main(self):		
		""" Loop the files and copy matching files to a temp folder. """
		# make a directory to hold our extracted PNGs
		arg = "mkdir ./__render/tmpFrames"
		os.system( arg )

		for file_name in sorted(glob.glob("./__render/*"+self.file_type)):
			file_name = file_name.replace(" ", "\ ") # escape spaces in file_name 
			
			for row in self.tableRows:

				fileFound = False

				if file_name.find( str(row[0]) ) > -1:
					if file_name.find( row[1] ) > -1:
						fileFound = True
						print(file_name)
					if file_name.find( row[2] ) > -1:
						fileFound = True
						print(file_name)
					if file_name.find( row[3] ) > -1:
						fileFound = True
						print(file_name)
					if file_name.find( row[4] ) > -1:
						fileFound = True
						print(file_name)

					if fileFound:
						arg = "cp " + file_name + " ./__render/tmpFrames"
						os.system( arg )

# Instantiate and run the class.
Extractor().main()



