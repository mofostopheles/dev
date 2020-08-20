# -*- coding: utf8 -*-
'''
	ABOUT
	Use this script when you want to construct the list of assets for the DMIX input sheet.
	You will make a new script for each video. For Sept 2020 Stadia, that was 4 video types.

	USAGE
	• Place this script with your project.
	• Dupe this file off for each of your video types, i.e. "06s_single"
	• The idea is all your assets for each video will have the same prefix, i.e. "stadia_092020_acq_06s_single_"
	• Enter those prefixes below.
	• The suffixes will map back to your hashtags in AE.
	• It is very important to update list_of_suffixes with the tags used on your layers.
	• After the strings are set up, run the script.
	• A file will be generated that can be used to copy/paste into the input sheet columns.
	• Use column select in Sublime (Shift CMD L), and go row by row.

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

class AssetListConstructor():

	def __init__(self):
		# this changes with each project, here is the Sept Stadia prefix
		# in this case we have acquire and retention videos
		video_template = "06s_single"
		prefix_ACQ = "stadia_092020_acq_06s_single_"
		prefix_RET = "stadia_092020_ret_06s_single_"

		# these need to be in order of appearance as in the spreadsheet
		list_of_suffixes = [
			"00090_seq_{}.png", \
			"00045_seq_{}.png", \
			"00000_seq.png", \
			"gameplay.mov", \
			"endframe.mov", \
			"text_{}.mov", \
			"single_VO.wav" \
		]

		# these should be double checked that the order hasn't changed
		list_of_ACQ_locales = [
			"enUS", \
			"esUS" \
		]

		# these should be double checked that the order hasn't changed
		list_of_RET_locales = [
			"en-us", \
			"es-us", \
			"en-ca", \
			"fr-ca", \
			"en-uk", \
			"de-de", \
			"es-es", \
			"fr-fr"
		]

		totalList = ""

		for locale in list_of_ACQ_locales:
			for suf in list_of_suffixes:
				tmpFileName = prefix_ACQ + suf
				tmpFileName = tmpFileName.format(locale)
				totalList += tmpFileName + "\t"
				# print(tmpFileName)
			totalList += tmpFileName + "\n"

		for locale in list_of_RET_locales:
			for suf in list_of_suffixes:
				tmpFileName = prefix_RET + suf
				tmpFileName = tmpFileName.format(locale)
				totalList += tmpFileName + "\t"
				# print(tmpFileName)
			totalList += tmpFileName + "\n"

		print(totalList)

		file = open(video_template + ".txt", 'w')
		file.write(totalList)
		file.close()

inst = AssetListConstructor()
