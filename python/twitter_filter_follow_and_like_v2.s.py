import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

from blacklists.s import getBlacklistTerms, getBlacklistUsers


# API...
# http://selenium-python.readthedocs.io/getting-started.html?highlight=Keys

# bot loops all the like buttons and then all the follow buttons, 
# filtering out blacklisted items as it goes

class TwitterFilterFollowAndLike():

	# constructor
	def __init__(self):
		self.url = "http://www.twitter.com/login"
		self.browser = webdriver.Firefox()
		self.username = "xxxxxxxxxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxxxx\r'
		self.cycles = 2
		self.totalLikes = 0
		self.totalFollows = 0
		
	def launchProcess(self):
		self.browser.get(self.url)
		self.login()

		for i in range(0, self.cycles):
			self.likeAndFollow(i+1)
			self.browser.refresh()
			time.sleep(2)
			self.scrollBy()
			print("cycle " + str(i) + " of " + str(self.cycles))

		print("\n")
		print( str(self.totalLikes) + " total likes")
		print( str(self.totalFollows) + " total follows \n")

	def blacklistedTerm(self, pElem):
		for foo in getBlacklistTerms():
			if foo.lower() in pElem.get_attribute("innerText").lower():
				print("found blacklisted term '" + foo + "'")
				return 1

		return 0

	def blacklistedUser(self, pElem):
		for foo in getBlacklistUsers():
			if foo.lower() in pElem.get_attribute("innerText").lower():
				print("found blacklisted user '" + foo + "'")
				return 1

		#doesn't hurt to check for terms too
		for foo in getBlacklistTerms():
			if foo.lower() in pElem.get_attribute("innerText").lower():
				print("found blacklisted term associated with user '" + foo + "'")
				return 1

		return 0

	def isLikeButton(self, pElem):
		if 'title="Like"' in pElem.get_attribute("innerHTML"):
			return 1
		else:
			return 0

	def isFollowButton(self, pElem):
		if 'Icon Icon--follow' in pElem.get_attribute("innerHTML"):
			return 1
		else:
			return 0

	def login(self):				
		assert 'Log in' in self.browser.page_source
		elem = self.browser.find_element_by_xpath("//h1")

		for i in range(0,6): #hit tab key 6 times
			elem.send_keys(Keys.TAB)
			time.sleep(0.25)
		elem.send_keys(self.username)
		time.sleep(0.25)
		elem.send_keys(Keys.TAB)
		elem.send_keys(self.pw)
		time.sleep(1)
		elem.send_keys(Keys.ENTER)
		time.sleep(5)

	def likeAndFollow(self, pCycleIndex):
		buttonList = self.browser.find_elements_by_xpath("//button")

		for i in range(0, len( buttonList )):
			try:
				elem = buttonList[i]
				if elem.is_displayed():

					
					if self.isLikeButton(elem):					
						# clumsy but it works, contains the whole tweet including author name and handle
						tmpParentNode = elem.find_element_by_xpath("parent::node()/parent::node()/parent::node()/parent::node()/parent::node()")
						if not self.blacklistedTerm(tmpParentNode):
							elem.click()	
							time.sleep(1)
							self.totalLikes += 1
							# likeList += 1	
							# print(tmpParentNode.get_attribute("innerText"))	

					elif self.isFollowButton(elem):
						# clumsy but it works, contains the whole tweet including author name and handle
						tmpParentNode = elem.find_element_by_xpath("parent::node()/parent::node()/parent::node()")
						if not self.blacklistedUser(tmpParentNode):
							# print(tmpParentNode.get_attribute("innerText"))
							elem.click()	
							time.sleep(1)
							self.totalFollows += 1

			except Exception as e:
				print(e)
				#raise e
			else:
				pass


	def scrollBy(self):
		print("scrolling down.")
		# print( self.browser.execute_script( "window.scrollY" ))
		self.browser.execute_script( "window.scrollBy(0,30000);" )
		time.sleep(2) 

# kick off everything here
bot = TwitterFilterFollowAndLike()
bot.launchProcess()

