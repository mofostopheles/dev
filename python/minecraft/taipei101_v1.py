import time
import RPi.GPIO as GPIO

from picraft import World, Vector, Block

'''
    arlo emerson, december 2016
    script builds the Taipei 101 skyscraper at current player's location
    

'''
class TaipeiBuilding():

    def __init__(self):
        print('constructor')


    def makeFoundation(self):
        print('make foundation')
        print( world.player.pos )

world = World()
tb = TaipeiBuilding()
tb.makeFoundation()
