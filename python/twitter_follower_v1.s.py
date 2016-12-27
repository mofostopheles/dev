import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

# API...
# http://selenium-python.readthedocs.io/getting-started.html?highlight=Keys

class TwitterFollower():

	# constructor
	def __init__(self):
		self.url = "http://www.twitter.com/login"
		self.browser = webdriver.Firefox()
		self.username = "xxxxxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxx\r'
		self.cycles = 20
		self.totalUnits = 0

		
	def launchPage(self):
		self.browser.get(self.url)
		self.login()
		
		for i in range(0, self.cycles):
			self.whoToFollow(i+1)

		print("followed a total of " + str(self.totalUnits) + " accounts")

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

	def whoToFollow(self, pCycleIndex):
		print("following accounts now -- cycle " + str(pCycleIndex))
		buttonList = self.browser.find_elements_by_xpath("//button")
		tmpCounter = 0

		time.sleep(1)
		
		# todo: determine if we really need to do this twice
		buttonList = self.browser.find_elements_by_xpath("//button")

		time.sleep(1)

		#print("found " + str(len(buttonList)) + " button objects.")

		for i in range(0, len( buttonList )):
			try:
				elem = buttonList[i]
				if elem.is_displayed():
					if 'Follow' in elem.get_attribute("innerText"):
						elem.click()	
						time.sleep(1)
						self.totalUnits += 1
						tmpCounter += 1
			except Exception as e:
				print(e)
				#raise e
			else:
				pass
			
		print("just followed " + str(tmpCounter) + " accounts.")
		
		time.sleep(1)

	def scrollBy(self):
		print("scrolling down.")
		# print( self.browser.execute_script( "window.scrollY" ))
		self.browser.execute_script( "window.scrollBy(0,30000);" )
		time.sleep(2) 

# kick off everything here
twitterFollower = TwitterFollower()
twitterFollower.launchPage()

