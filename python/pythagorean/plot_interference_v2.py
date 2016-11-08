import matplotlib
import matplotlib.pyplot as plt

#http://matplotlib.org/api/pyplot_api.html

class MyPooPlotter(object):

	def __init__(self, name, experiment):
		self.name = name
		self.experiment = experiment

		print("...running...", self.name.title())
			
	def plotSomeStuff(self, num):
		print("plotting...", num)
		size = 25
		blacky = 40
		whitey = 40
		
                #white keys
		x = [0, 20, 40, 50, 70, 90, 110]
		y = [blacky, blacky, blacky, blacky, blacky, blacky, blacky]
		plt.plot(x,y,c='white', markersize=size, markeredgecolor='black', marker='s')

                #black keys
		x = [10, 30, 60, 80, 100, 130, 150]
		y = [whitey, whitey, whitey, whitey, whitey, whitey, whitey]
		plt.plot(x,y,c='black', markersize=size, markeredgecolor='black', marker='s')


		
		plt.show()




foo = MyPooPlotter("fred", 1)
foo.plotSomeStuff(0)
