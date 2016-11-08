import matplotlib
import matplotlib.pyplot as plt


class MyPooPlotter(object):

	def __init__(self, name, experiment):
		self.name = name
		self.experiment = experiment

		print("...running...", self.name.title())
			
	def plotSomeStuff(self, num):
		print("plotting...", num)
		#sq = [[12,14],[44,57],[89,122]]
		x = [2,4,6,7,8,9,12,16,24,32]
		y = [3,5,6,4,5,6,12,25,55,77]
		#plt.plot(sq)
		plt.scatter(x,y,s=100)
		plt.show()




foo = MyPooPlotter("fred", 1)
foo.plotSomeStuff(0)
