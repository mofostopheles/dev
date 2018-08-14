#!/usr/bin/env python
# -*- coding: utf8 -*-

from BeautifulSoup import BeautifulSoup
import urllib, urllib2, argparse, textwrap
import lib.TextColors as TextColors

__author__ = "Arlo Emerson <arlo.emerson@essenceglobal.com>"
__version__ = "1.0"
__date__ = "8/8/2018"

"""
	SCRIPT: 
	"download_links.py"

	SYNOPSIS:
	This is an http workaround for sometimes slow FTP transfers of rendered files (if an alternative web/http link is provided). Basically we're just getting a list of images on a page and downloading them one by one.

	USAGE:
	• Place this script and the lib folder in your render/output folder.
	• run python download_links.py -h for documentation and usage.       
"""

class Downloader():

	def __init__(self):
		print("Running " + TextColors.HEADERLEFT3 + TextColors.INVERTED + self.__class__.__name__ + " " + TextColors.ENDC)
		
		self._url = ""
		self._listIndex = 1 # set to 1 to start at the 2nd link, this avoids trying to download the up dir link

		helpMessage = 'This script will attempt to download all links on a given page.'

		parser = argparse.ArgumentParser(description=helpMessage, 
			epilog=textwrap.dedent('''Pass in a url containing a list of links to download. e.g. python download_links.py -url "url-in-quotes" -i 2'''), formatter_class=argparse.RawTextHelpFormatter)
		parser.add_argument('-u', '--url', dest='url', action="store", required=True, help="The url containing the list of links.")
		parser.add_argument('-i', '--index', dest='index', action="store", required=False, help="The index of the list to start downloading at.")

		args = parser.parse_args()
		
		if args.url:
			self._url = args.url
			print("URL is " + args.url)
		else:
			print("You must pass in a URL.")

		if args.index:
			self._listIndex = int(args.index)

	def run(self):	
		req = urllib2.Request(self._url)

		response = urllib2.urlopen(req)
		responseHTML = response.read()

		# print(responseHTML)
		soup = BeautifulSoup(responseHTML)

		links = []
		counter = 0 # 0 will be the up link
		for link in soup.findAll('a'):
			if counter >= self._listIndex:
			    for foo in link:
			    	links.append(foo)
			counter += 1

		for link in links:
			truncatedLink = link[ link.rfind("/")+1: ]
			print( truncatedLink )
			f = urllib.urlretrieve( self._url + link, truncatedLink )

d = Downloader()
d.run()