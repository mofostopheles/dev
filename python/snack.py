from Tkinter import *
root = Tk()

import tkSnack
tkSnack.initializeSnack(root)
mysound = tkSnack.Sound()
mysound.read('C:/MyDocs/dev/SnackSound/trytoput.wav')
mysound.play()
