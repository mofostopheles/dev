from splinter import Browser
import time


# script to automate liking on twitter
# arloemerson@gmail.com
# dec 24, 2016
# https://splinter.readthedocs.io/en/latest/

class TwitterLiker():

	# constructor
	def __init__(self):
		self.mUrl = "https://www.twitter.com/"
		self.cycles = 2
		self.browser = Browser()
		self.username = "XXXXXXXXXXXXXXXXXX"
		self.pw = 'XXXXXXXXXX\r'
		self.totalLikes = 0
		self.userNameField = 'session[username_or_email]'
		self.passwordField = 'session[password]'
		self.loginButtonId = 'submit btn primary-btn js-submit'

	# scroll the page and
	# do the liking
	def launchPage(self):
		self.browser.visit(self.mUrl)
		self.login()


		# self.scrollBy()
		for i in range(0, self.cycles):
			self.likePosts()

		print(str(self.totalLikes) + " total likes this session...Yay!")		

	def login(self):
		print("login")
		print("logging in as " + self.username)
		self.browser.click_link_by_text('Log in')
		
		# time.sleep(1)

		assert self.browser.find_by_name(self.userNameField)
		self.browser.fill(self.userNameField, self.username)
		self.browser.fill(self.passwordField, self.pw)

		inputs = self.browser.find_by_tag('input')
		for foo in inputs:
			if foo['class'] == self.loginButtonId:
				foo.click()
				print('clicked the log in button')

		# need to sleep a few seconds here
		time.sleep(3)

	def likePosts(self):
		print("liking posts")
		buttonList = self.browser.find_by_tag('button')

		time.sleep(2)

		buttonList = self.browser.find_by_tag('button')
		likeList = 0

		time.sleep(1)
		
		for b in buttonList:			
			if 'title="Like"' in b['innerHTML']:
				#check if it's visible, if not move on
				if b.visible:
					b.click()
					self.totalLikes += 1
					likeList += 1
		print("just liked " + str(likeList) + " tweets.")
		
		self.scrollBy()

		time.sleep(1)

	def scrollBy(self):
		print("scrolling down.")
		# print( self.browser.execute_script( "window.scrollY" ))
		self.browser.execute_script( "window.scrollBy(0,30000);" )
		time.sleep(2) 

	def boneyard(self):
		print('boneyard')	

		# for foo in inputList:
		# 	print(foo['id'])
		# 	print(foo['name'])
		# 	print(foo['outerHTML'])

		# m = PyMouse()
		# print( m.position() ) #gets mouse current position coordinates
		# # m.move(x,y)

		# loop all the links on a page
		# likeList = browser.find_by_tag('a')
		# for foo in likeList:
		# 	print(foo['href'])

		#browser.execute_script( "window.scrollTo(0, 50000);")
		# from selenium import webdriver
		# from selenium.webdriver.common import action_chains, keys
		# import time

		# driver = webdriver.Firefox()
		# driver.get('Your URL here...')
		# assert 'NBA' in driver.page_source
		# action = action_chains.ActionChains(driver)

		# # open up the developer console, mine on MAC, yours may be diff key combo
		# action.send_keys(keys.Keys.COMMAND+keys.Keys.ALT+'i')
		# action.perform()
		# time.sleep(3)
		# # this below ENTER is to rid of the above "i"
		# action.send_keys(keys.Keys.ENTER)
		# # inject the JavaScript...
		# action.send_keys("document.querySelectorAll('label.boxed')[1].click()"+keys.Keys.ENTER)
		# action.perform()

		# from selenium.webdriver.common.keys import Keys
		# elem = br.find_element_by_name("username")
		# elem.send_keys(Keys.TAB) # tab over to not-visible element



# kick off everything here
twitterLiker = TwitterLiker()
twitterLiker.launchPage()
print("all done liking....for now.")
