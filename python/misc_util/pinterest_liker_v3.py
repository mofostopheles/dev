import time
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

# API...
# http://selenium-python.readthedocs.io/getting-started.html?highlight=Keys

class PinterestLiker():

	# constructor
	def __init__(self):
		self.url = "https://www.pinterest.com/login"
		self.browser = webdriver.Firefox()
		self.username = "xxxxxxxxxxxxxxxx@"
		self.host = "xxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxxx'
		self.cycles = 2
		self.totalLikes = 0
		self.boardName = "triage"
		
	def launchPage(self):
		self.browser.get(self.url)
		self.login()
		
		for i in range(0, self.cycles):
			self.likePosts(i+1)

		print(str(self.totalLikes) + " total likes this session...Yay!")

	def login(self):				
		assert 'Log in' in self.browser.page_source
		elem = self.browser.find_element_by_xpath("//body")
		elem.send_keys(Keys.TAB)
		elem.send_keys(Keys.TAB)
		elem.send_keys(Keys.TAB)
		elem.send_keys(Keys.TAB)


		elem.send_keys(self.username)
		time.sleep(1)
		elem.send_keys(self.host)
		time.sleep(1)
		elem.send_keys(Keys.TAB)
		elem.send_keys(self.pw)
		time.sleep(1)
		elem.send_keys(Keys.ENTER)
		time.sleep(5)

	def likePosts(self, pCycleIndex):
		print("liking posts now -- cycle " + str(pCycleIndex))
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
				#print(elem.get_attribute("innerText"))
				if 'Save' in elem.get_attribute("innerText"):
					elem.click()	
					time.sleep(2)

					#check for upsell doohickey
					try:
						popup = self.browser.find_element_by_xpath("//div[@class='promoHeader']")
						if popup:
							print('need to close this damn thing')
							newButtonList = self.browser.find_elements_by_xpath("//button")
							for k in range(0, len(newButtonList)):
								buttonInstance = newButtonList[k]

								if 'Close' in buttonInstance.get_attribute("innerText"):
									buttonInstance.click()
									time.sleep(1)
					except Exception as fooException:
						print("probs could not find this thing")
					else:
						pass

					field = self.browser.find_element_by_xpath("//input[@name='name']")
					print(field)
					field.send_keys(self.boardName)
					time.sleep(1)
					field.send_keys(Keys.ENTER)
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
pinterestLiker = PinterestLiker()
pinterestLiker.launchPage()
