import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

# API...
# http://selenium-python.readthedocs.io/getting-started.html?highlight=Keys

class TwitterLiker():

	# constructor
	def __init__(self):
		self.url = "http://www.twitter.com/login"
		self.browser = webdriver.Firefox()
		self.username = "xxxxxxxxxxxxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxxx\r'
		self.cycles = 2
		self.totalLikes = 0

		
	def launchPage(self):
		self.browser.get(self.url)
		self.login()
		
		for i in range(0, self.cycles):
			self.likeTweets(i+1)

		print(str(self.totalLikes) + " total likes this session...Yay!")

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

	def likeTweets(self, pCycleIndex):
		print("liking tweets now -- cycle " + str(pCycleIndex))
		buttonList = self.browser.find_elements_by_xpath("//button")
		likeList = 0

		time.sleep(1)
		
		# todo: determine if we really need to do this twice
		buttonList = self.browser.find_elements_by_xpath("//button")

		time.sleep(1)

		#print("found " + str(len(buttonList)) + " button objects.")

		for i in range(0, len( buttonList )):
			try:
				elem = buttonList[i]
				if elem.is_displayed():
					if 'title="Like"' in elem.get_attribute("innerHTML"):
						elem.click()	
						time.sleep(2)
						self.totalLikes += 1
						likeList += 1
			except Exception as e:
				print(e)
				#raise e
			else:
				pass
			
		print("just liked " + str(likeList) + " tweets.")
		
		self.scrollBy()
		time.sleep(1)

	def scrollBy(self):
		print("scrolling down.")
		# print( self.browser.execute_script( "window.scrollY" ))
		self.browser.execute_script( "window.scrollBy(0,30000);" )
		time.sleep(2) 

# kick off everything here
twitterLiker = TwitterLiker()
twitterLiker.launchPage()

