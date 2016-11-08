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
        size = 5.0
        blacky = []
        whitey = []
        commony = 40
        
        generalCounter = 1
        whitex = []
        blackx = []
        tmpX = 0
        #outer loop
        for c in range(1, 6):  #iterations

                #white keys
                for f1 in range(1, 6): #5 looper
      
                        if f1%2 == 0:
                                tmpcolor='black'
                        else:
                                tmpcolor='white'

                        plt.plot(tmpX,commony,c=tmpcolor, ms=size, markeredgecolor='black', marker='s')

                        tmpX += 100
                        generalCounter += 1

                #blacks
                for f1 in range(1, 8): #really 7
      
                        if f1%2 == 0:
                                tmpcolor='black'
                        else:
                                tmpcolor='white'

                        plt.plot(tmpX,commony,c=tmpcolor, ms=size, markeredgecolor='black', marker='s')

                        tmpX += 100
                        generalCounter += 1

        plt.show()


foo = MyPooPlotter("fred", 1)
foo.plotSomeStuff(0)
