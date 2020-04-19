
# -*- coding: utf8 -*-
'''
	ABOUT
	Creates very rough mix tracks of WAV files. This is designed to be used with the 
	authors Zoom 8 track recorder. 

	USAGE
	• Place this script at the root of all recorded audio directories.
	• Run the script, no args needed.

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
__version__ = "1"
__date__ = "4/19/2020"

import sys
import os
import glob
import subprocess

class AutoMixer():	
	""" Automatically mixes WAV files into one track. This is for files from the Zoom 8."""
	def __init__(self):
		self.file_type = "WAV"
		self.working_dir = ""
		self.total_transcoded = 0

	def main(self):		
		'''Loop the file types and inner-loop the output types.'''

		for subdir, dirs, files in os.walk('./'):
			
			# very crude but works well!
			if 'AUDIO' in subdir:
				print("you are in " + subdir)
				clean_file_list = files #remove('PRJINFO.TXT')
				for name in clean_file_list:
					if name == 'PRJINFO.TXT':
						del clean_file_list[clean_file_list.index(name)]
					if name == '.DS_Store':
						del clean_file_list[clean_file_list.index(name)]

				print('Will make a mixdown of these files:')

				# normalize all AUDIO
				string_of_input_files = ''
				string_of_output_files = ''
				string_of_normalized_files = '' # this is for the mixdown args
				number_of_normalized_files = 0

				for audio in clean_file_list:
					string_of_input_files += subdir + '/' + audio + ' '
					if '_NORM' not in audio:
						string_of_output_files += subdir + '/' + audio.replace('.WAV', '_NORM.WAV') + ' '
						string_of_normalized_files += '-i ' + subdir + '/' + audio.replace('.WAV', '_NORM.WAV') + ' '
						number_of_normalized_files += 1
				
				# comment out this call if you want to re-use existing normalized files
				arg = 'ffmpeg-normalize ' + string_of_input_files + ' -o ' + string_of_output_files
				os.system( arg )

				# everything was normalized, let's mix it down
				mixdown_file_name = subdir.replace('.', '')
				mixdown_file_name = mixdown_file_name.replace('/', '_')
				mixdown_file_name = mixdown_file_name.replace('_AUDIO', '_fastmix')
				mixdown_file_ext = '.mp3'

				arg = 'ffmpeg ' + string_of_normalized_files + ' -filter_complex amix=inputs=' + str(number_of_normalized_files) + ':duration=longest ' + (mixdown_file_name + mixdown_file_ext)
				print( arg )
				os.system( arg )

# Instantiate and run the class.
AutoMixer().main()
