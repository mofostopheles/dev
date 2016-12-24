from splinter import Browser
import time


# script to automate liking on instagram
# arloemerson@gmail.com
# dec 23, 2016

class InstaLiker():

	# constructor
	def __init__(self):
		self.mUrl = "https://www.instagram.com/"
		#self.mUrl = "http://www.google.com"
		self.cycles = 20
		self.browser = Browser()
		self.username = "xxxxxxxxxxxxxxxxxx"
		self.pw = 'xxxxxxxxxxxxxxxxxxxx\r'
		self.totalLikes = 0

	# scroll the page and
	# do the liking
	def launchPage(self):
		self.browser.visit(self.mUrl)
		self.login()

		self.scrollBy()
		for i in range(0, self.cycles):
			self.likePosts()

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
				foo.click()
				self.totalLikes += 1

			time.sleep(1)

	def scrollBy(self):
		print("scrolling down.")
		# print( self.browser.execute_script( "window.scrollY" ))
		self.browser.execute_script( "window.scrollBy(0,30000);" )
		time.sleep(1) 

	def boneyard(self):
		print('boneyard')
		# m = PyMouse()
		# print( m.position() ) #gets mouse current position coordinates
		# # m.move(x,y)

		# loop all the links on a page
		# likeList = browser.find_by_tag('a')
		# for foo in likeList:
		# 	print(foo['href'])

		#browser.execute_script( "window.scrollTo(0, 50000);")




# kick off everything here
instaliker = InstaLiker()
instaliker.launchPage()
print("all done liking....for now.")
