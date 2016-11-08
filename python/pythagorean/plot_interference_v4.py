import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import math

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

        print("...running...", self.name.title())

        lengthOfRun = 10
        x = np.linspace(0, lengthOfRun*np.pi, 12) #just doing this to control the canvas at this point
        #FIND A BETTER WAY
        y = np.sin(x**2)

        # Just a figure and one subplot
        self.f, self.ax = plt.subplots()
        self.ax.plot(x, y)
        self.ax.set_title('Simple plot')

    def determineColor(self):
        if self.bwHolder[self.generalCounter]==0:
                return('white')
        else:
                return('black')
            
        
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

        #self.plotResonanceSeries(0.1)
        #self.plotResonanceSeries(0.2)
        #self.plotResonanceSeries(0.3)
        #self.plotResonanceSeries(0.4)
        #self.plotResonanceSeries(0.5)
        #self.plotResonanceSeries(0.6)
        #self.plotResonanceSeries(0.8)
        #self.plotResonanceSeries(0.8)
        #self.plotResonanceSeries(0.9)
        #self.plotResonanceSeries(1.1)
            
        self.plotResonanceSeries(1.5)
            
        self.plotResonanceSeries(5)  #WHAT THIS ACTUALLY DOES IS PAINTS 6 WHITE KEYS THEN IT
                                #LANDS ON 5 BLACK KEYS BEFORE BEGINNING AGAIN AT C
            
        self.plotResonanceSeries(6)  ### THIS LANDS ON EVERY F AND B ###

        self.plotResonanceSeries(7)

        self.plotResonanceSeries(8)
        
        self.plotResonanceSeries(9)
        
        self.plotResonanceSeries(11) # 11 appears to be a B/W oscillator
                                # could this indicate the boundary of the waveform?

        #TODO try to get the sine wave to outline the oscillation of the number series
        #make a sine wave here
        x = np.linspace(0, self.tmpX-100, num=22)
        y = np.sin(x*np.pi*math.sqrt(11))
        self.ax.plot(x, y)

        self.plotResonanceSeries(12) #12 is a multiple of 6 so we're already hitting these keys   

        self.plotResonanceSeries(13)

        self.plotResonanceSeries(17)

        self.plotResonanceSeries(1) # prints out the piano keys

        ######################################
        ############ DO THIS LAST ############
        plt.show()
        ######################################
        ######################################
        
        
    def plotResonanceSeries(self, pNumber):
        
        
        #RESET OUR ORIGINS
        self.tmpX = 0
        self.commony -= self.moveDown #move down a little
        self.generalCounter = 0
        isDirty = 0
        
        for c1 in range(1, self.innerLoopSize): 
            if c1%pNumber == 0:
                isDirty = 1
                tmpcolor=self.determineColor()
                self.ax.plot(self.tmpX,self.commony,c=tmpcolor, ms=self.size, markeredgecolor='black', marker='s')
            self.tmpX += 100
            self.generalCounter += 1

        if isDirty == 1:
            print("plotting " + str(pNumber))
        
foo = MyPooPlotter("fred", 1)
foo.plotSomeStuff()
