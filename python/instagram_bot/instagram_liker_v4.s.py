from splinter import Browser
import time

from blacklists import getBlacklistTerms, getBlacklistUsers


# script to automate liking on instagram
# arloemerson@gmail.com
# jan 4, 2017

class InstaLiker():

	def __init__(self):
		self.mUrl = "https://www.instagram.com/"
		self.cycles = 20
		self.browser = Browser()
		self.username = "xxxxxxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxxxxxxxx\r'
		self.totalLikes = 0

	# scroll the page and
	# do the liking
	def launchPage(self):
		self.browser.visit(self.mUrl)
		self.login()

		
		for i in range(0, self.cycles):
			self.scrollBy()
			time.sleep(2)
			self.scrollBy()
			time.sleep(2)
			self.scrollBy()
			time.sleep(2)
			self.browser.execute_script( "window.scrollTo(0,0);" )
			self.likePosts()
			time.sleep(2)
			

		print("just liked " + str(self.totalLikes) + " pix...Yay!")		

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
		
		if len(likeList) == 0:
			print("nothing left to like. attempt to scroll farther to load more posts.")
			self.scrollBy()
			time.sleep(3)
			likeList = self.browser.find_by_text("Like")
			print("likeList is now: " + str(len(likeList)))

		if (len(likeList) > 0):
			print("found " + str(len(likeList)) + " posts to like")
			
			for foo in likeList:
				#if parent inner text contains something off the black list, avoid
				#tmpParentNode = foo.find_by_xpath("parent::node()/parent::text()")
				tmpParentNode = foo.find_by_xpath("ancestor::article/header")
				print(tmpParentNode["innerText"])
				if self.checkBlackList(tmpParentNode["innerText"]) == 0:
					foo.click()
					print("   <3    ")
					self.totalLikes += 1
					print("\n*** total likes is " + str(self.totalLikes) + " ***\n")
					time.sleep(1)

	def checkBlackList(self, pString):
		for foo in getBlacklistUsers():			
			if foo.lower() in pString.lower():
				print("found blacklisted user '" + foo + "'")
				self.scrollBy()
				return 1

		#doesn't hurt to check for terms too
		for foo in getBlacklistTerms():
			if foo.lower() in pString.lower():
				print("found blacklisted user '" + foo + "'")
				self.scrollBy()
				return 1
		return 0		

	def scrollBy(self):
		print("scrolling down.")
		self.browser.execute_script( "window.scrollBy(0,30000);" )
		time.sleep(1) 

	def boneyard(self):
		print('boneyard')


# kick off everything here
instaliker = InstaLiker()
instaliker.launchPage()
print("all done liking....for now.")
