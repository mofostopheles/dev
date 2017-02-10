from splinter import Browser
import time

from blacklists import getBlacklistTerms, getBlacklistUsers


# script to automate liking on instagram
# arloemerson@gmail.com
# feb 4, 2017

class InstaLiker():

	def __init__(self):
		print("Running '" + self.__class__.__name__ + "'...")
		self.mUrl = "https://www.instagram.com/"
		self.cycles = 20
		self.browser = Browser()
		self.username = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\r'
		self.totalLikes = 0
		self.skipped = 0

		self.launchPage()
		self.printStats()
		print("all done liking....for now.")


	# scroll the page and
	# do the liking
	def launchPage(self):
		self.browser.visit(self.mUrl)
		self.login()

		self.scrollBy()
		time.sleep(2)
		self.browser.execute_script( "window.scrollTo(0,0);" )
		
		for i in range(0, self.cycles):
			print("        cycle: " + str(i+1) + " of " + str(self.cycles))
			self.printStats()	

			self.likePosts()
			self.scrollBy()
			time.sleep(2)			

		print("\nall done!")
		self.printStats()
		# self.browser.close()

	def login(self):
		print("login")
		print("logging in as " + self.username)
		self.browser.click_link_by_text('Log in')
		self.browser.fill('username', self.username)
		self.browser.fill('password', self.pw)
		
		form = self.browser.find_by_tag('form')
		inputs = form.find_by_tag('button')
		inputs[0].click()

		# need to sleep a few seconds here
		time.sleep(5)

	def likePosts(self):
		print("liking posts")
		likeList = self.browser.find_by_text("Like")
		
		if len(likeList)-self.skipped == 0:
			print("nothing left to like. attempt to scroll farther to load more posts.")
			self.scrollBy()
			time.sleep(3)
			likeList = self.browser.find_by_text("Like")
			print("likeList is now: " + str(len(likeList)-self.skipped))
		
		if (len(likeList) - self.skipped > 0):
			print("found " + str(len(likeList)-self.skipped) + " posts to like")
			
			newStart = self.skipped 
			#print("starting on " + str(newStart))

			for y in range( newStart, len(likeList)):

				foo = likeList[y]
				
				tmpParentNode = foo.find_by_xpath("ancestor::article/header")
				print(tmpParentNode["innerText"])							

				if self.checkBlackList(tmpParentNode["innerText"]) == 0:
					foo.click()
					print("   <3    ")
					self.totalLikes += 1
					self.printStats()
					time.sleep(1)
				else:
					self.skipped += 1

	def checkBlackList(self, pString):
		for foo in getBlacklistUsers():			
			if foo.lower() in pString.lower():
				print("found blacklisted user '" + foo + "'")
				self.scrollBy()
				return 1

		#doesn't hurt to check for terms too
		for foo in getBlacklistTerms():
			if foo.lower() in pString.lower():
				print("found blacklisted term '" + foo + "'")
				self.scrollBy()
				return 1
		return 0		

	def scrollBy(self):
		print("^^^^^^")
		self.browser.execute_script( "window.scrollBy(0,-1000);" )
		self.browser.execute_script( "window.scrollBy(0,29000);" )
		self.browser.execute_script( "window.scrollBy(0,20);" )
		time.sleep(1) 

	def printStats(self):
		print("\n")
		print("========= stats for '" + self.__class__.__name__ + "'' =========")		
		print("  total likes: " + str(self.totalLikes))
		print("total skipped: " + str(self.skipped))

	def boneyard(self):
		print('boneyard')


# kick off everything here
instaliker = InstaLiker()
instaliker.launchPage()
print("all done liking....for now.")
