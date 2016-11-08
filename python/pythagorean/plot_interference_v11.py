import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import math
import datetime

#http://matplotlib.org/api/pyplot_api.html

'''

arlo emerson
arloemerson@gmail.com

november 2016, deep into the night

we're trying to figure out the interference pattern for 3:2 pythagorean frequency series
i.e. the notes on the piano

it must be made of several oscillations

this script aims to determine if this is true

'''

class MyPooPlotter(object):

    def __init__(self, name, experiment):
        self.name = name
        self.experiment = experiment
        self.moveDown = 0.05
        self.generalCounter = 0
        self.bwHolder = [] #0=white, 1=black
        self.outerLoopSize = 14
        self.innerLoopSize = 150
        self.commony = 0
        self.size = 5.0
        self.tmpX = 0

        chartTitle = "Pythagorean freq series from interferance patterns"

        print("...running...", self.name.title())

        lengthOfRun = 10
        x = np.linspace(0, lengthOfRun*np.pi, 12) #just doing this to control the canvas at this point
        #FIND A BETTER WAY
        y = np.sin(x**2)

        self.f, self.ax = plt.subplots()
        #self.f.set_size_inches(7.0,4.0)
        self.ax.plot(x, y)
        self.ax.set_title(chartTitle)

    def determineColor(self, pInvert):
        if self.bwHolder[self.generalCounter]==0:
            if pInvert == False:
                return('white') #this is it's natural color
            else:
                return('black')
        else:
            if pInvert == False:
                return('black') #this is it's natural color
            else:
                return('white')
            
        
    def plotSomeStuff(self):      
        self.generalCounter = 0
        self.tmpX = 0

        #outer loop
        for c in range(1, self.outerLoopSize):  #iterations

                ######## PAINT THE PIANO KEYS ########
                #white keys
                #STARTING ON C
                for f1 in range(1, 6): #5 looper
      
                        if f1%2 == 0:
                                tmpcolor='black'
                                self.bwHolder.append(1) #set up bwholder for later reference
                        else:
                                tmpcolor='white'
                                self.bwHolder.append(0) #set up bwholder for later reference

                        self.ax.plot(self.tmpX,self.commony,c=tmpcolor, ms=self.size, markeredgecolor='black', marker='s')

                        self.tmpX += 100
                        self.generalCounter += 1 #every time we plot, increment this so others can access bwholder

                #blacks
                for f1 in range(1, 8): #really 7
      
                        if f1%2 == 0:
                                tmpcolor='black'
                                self.bwHolder.append(1)
                        else:
                                tmpcolor='white'
                                self.bwHolder.append(0)

                        self.ax.plot(self.tmpX,self.commony,c=tmpcolor, ms=self.size, markeredgecolor='black', marker='s')

                        self.tmpX += 100
                        self.generalCounter += 1
       
        #THIS IS WHERE WE OVERLAY A BUNCH OF REPEATING FREQ WAVES
        # iterate through various dimensions

        #experimenting with time using an offset for the next frequency. like 3 phase AC wave with the offsets at 120 degrees
        #args:
            #number to plot a series on
            #offset in marker width units
            #invert the color - simulating a below-the-zero signal flip

        self.plotResonanceSeries(2, 0, False)
        self.plotResonanceSeries(2, 400, True)

        self.plotResonanceSeries(7, 0, False)
        
        self.plotResonanceSeries(3, 0, False)
        self.plotResonanceSeries(3, 400, True)

        self.plotResonanceSeries(1, 0, False)

        

        
        ######################################
        ############ DO THIS LAST ############
        plt.show()
        tmpName = 'render/_pyth_' + \
                  str( datetime.datetime.now().month ) + "-" + \
                  str( datetime.datetime.now().day ) + "-" + \
                  str( datetime.datetime.now().year ) + "-" + \
                  str( datetime.datetime.now().hour ) + \
                  str( datetime.datetime.now().minute ) + \
                  str( datetime.datetime.now().second) + ".png"
        self.f.savefig(tmpName)
        ######################################
        ######################################
        
        
    def plotResonanceSeries(self, pNumber, pOffset, pInvert):
        
        
        #RESET OUR ORIGINS
        self.tmpX = pOffset
        self.commony -= self.moveDown #move down a little
        self.generalCounter = 0
        isDirty = 0
        
        for c1 in range(1, self.innerLoopSize): 
            if c1%pNumber == 0:
                isDirty = 1
                tmpcolor=self.determineColor(pInvert)
                self.ax.plot(self.tmpX,self.commony,c=tmpcolor, ms=self.size, markeredgecolor='black', marker='s')
            self.tmpX += 100
            self.generalCounter += 1

        if isDirty == 1:
            print("plotting " + str(pNumber))
        
foo = MyPooPlotter("fred", 1)
foo.plotSomeStuff()
