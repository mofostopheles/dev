import wave
import datetime
import sys
import struct
import numpy as np
#import pyaudio
import math

print "python version: " + sys.version

#references
#http://www.lfd.uci.edu/~gohlke/pythonlibs/
#http://docs.python.org/release/2.6/library/wave.html
#http://xoomer.virgilio.it/sam_psy/psych/sound_proc/sound_proc_python.html
#http://stackoverflow.com/questions/3694918/how-to-extract-frequency-associated-with-fft-values-in-python


sourceFileName = 'japan_news.wav'
targetFileName = 'japan_news.wav'

w = wave.open(sourceFileName, 'r')
#print "audio palette: ", sourceFileName
#print "audio target: ", targetFileName
print w.getparams()
listOfFrequencies = []
listOfSoundSamples = []
byteList = ''

frate = w.getparams()[2]

#change this to determine how big a sample range we have
#2048 is pretty short
sampleRange = 200

counter = 0

#SECTION 1: extract all the freq at sampleRange interval
for i in range(w.getnframes()):
	#grab frames in groups of sampleRange
	if i % sampleRange == 0 and i > 0 and i < w.getnframes()-sampleRange:
		w.setpos(i-sampleRange)
		listOfSoundSamples.insert(i-sampleRange, w.readframes(sampleRange) )
		#listOfSoundSamples.insert(counter, w.readframes(sampleRange) )
		#counter = counter + 1

		data=struct.unpack('{n}h'.format(n=sampleRange), w.readframes(sampleRange) )
		data=np.array(data)
		wthing = np.fft.fft(data)
		freqs = np.fft.fftfreq(len(wthing))
		#print(freqs.min(), freqs.max())

		idx=np.argmax(np.abs(  wthing  )**2)
		freq=freqs[idx]
		freq_in_hertz=abs(freq*frate)
		#print(freq_in_hertz)
		listOfFrequencies.insert(i-sampleRange, freq_in_hertz )

#SECTION 2: extract all the freq at sampleRange interval of our target audio clip
w = wave.open(targetFileName, 'r')
targetListOfFrequencies = []
targetListOfSoundSamples = []
frate = w.getparams()[2]

for i in range(w.getnframes()):
	#grab frames in groups of sampleRange
	if i % sampleRange == 0 and i > 0 and i < w.getnframes()-sampleRange:
		w.setpos(i-sampleRange)
		targetListOfSoundSamples.insert(i-sampleRange, w.readframes(sampleRange) )

		data=struct.unpack('{n}h'.format(n=sampleRange), w.readframes(sampleRange) )
		data=np.array(data)
		wthing = np.fft.fft(data)
		freqs = np.fft.fftfreq(len(wthing))
		#print(freqs.min(), freqs.max())

		idx=np.argmax(np.abs(  wthing  )**2)

		freq=freqs[idx]
		freq_in_hertz=abs(freq*frate)
		#print(freq_in_hertz)
		targetListOfFrequencies.insert(i-sampleRange, freq_in_hertz )


#SECTION 3: loop our target and conduct a search for similar freqs

newListofSoundSamples = []
newIndex = 0

for i in range(len(targetListOfFrequencies)):
	for y in range (len(listOfFrequencies)):
		if round( targetListOfFrequencies[i], 3) > round( listOfFrequencies[y], 3 )-1 and round( targetListOfFrequencies[i], 3) < round( listOfFrequencies[y], 3 )+1:
			newListofSoundSamples.insert(newIndex, listOfSoundSamples[y])
			newIndex = newIndex + 1
			break


#scratchpad
#if round( targetListOfFrequencies[i], 2) > round( listOfFrequencies[y], 2 )-1 and round( targetListOfFrequencies[i], 2) < round( listOfFrequencies[y], 2 )+1:
#targetListOfFrequencies[i] == listOfFrequencies[y]:


"""
open a wave file of something you want to process
store a list of it's sound samples and freqs (just like above)
loop the list and compare with our reference list,
if a match occurs in freq
add the soundsample to a new list, this is our output list
convert the output list to a wave file
"""

#this is how you write a wav file

for i in range(len(newListofSoundSamples)):
	byteList += newListofSoundSamples[i]

tmpName = targetFileName + "_" + str(datetime.datetime.now().microsecond) + "_" + str(sampleRange) + ".wav"
print tmpName
newSoundFile = wave.open(tmpName, 'w')
newSoundFile.setparams(w.getparams())

newSoundFile.writeframesraw( byteList )
newSoundFile.close()


