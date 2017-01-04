import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

# API...
# http://selenium-python.readthedocs.io/getting-started.html

# bot loops all the like buttons and then all the follow buttons, 
# filtering out blacklisted items as it goes

class TwitterFilterFollowAndLike():

	# constructor
	def __init__(self):
		self.url = "http://www.twitter.com/login"
		self.browser = webdriver.Firefox()
		self.username = "xxxxxxxxxxxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxxxxx\r'
		self.cycles = 10
		self.totalLikes = 0
		self.totalFollows = 0
		self.blacklist = ["missing", "dead", "death", "etc etc etc"]

		
	def launchProcess(self):
		self.browser.get(self.url)
		self.login()

		
		
		for i in range(0, self.cycles):
			self.likeAndFollow(i+1)
			self.browser.refresh()
			time.sleep(2)
			self.scrollBy()


		print("\n")
		print( str(self.totalLikes) + " total likes")
		print( str(self.totalFollows) + " total follows \n")

	def blacklisted(self, pElem):
		for foo in self.blacklist:
			if foo.lower() in pElem.get_attribute("innerText").lower():
				print("found blacklisted item '" + foo + "'")
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
						if not self.blacklisted(tmpParentNode):
							elem.click()	
							time.sleep(1)
							self.totalLikes += 1
							# likeList += 1	
							# print(tmpParentNode.get_attribute("innerText"))	

					elif self.isFollowButton(elem):
						# clumsy but it works, contains the whole tweet including author name and handle
						tmpParentNode = elem.find_element_by_xpath("parent::node()/parent::node()/parent::node()")
						if not self.blacklisted(tmpParentNode):
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

