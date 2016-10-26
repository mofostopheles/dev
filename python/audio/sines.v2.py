import wave
import datetime
import sys
import struct
import numpy as np
#import pyaudio
import math

"""
what this thing does is similar to the tonalizer, except
instead of rebuilding the song from actual wave samples, it
rebuilds it using synthetic sine waves

mono version
"""
print "python version: " + sys.version

#references
#http://www.lfd.uci.edu/~gohlke/pythonlibs/
#http://docs.python.org/release/2.6/library/wave.html
#http://xoomer.virgilio.it/sam_psy/psych/sound_proc/sound_proc_python.html
#http://stackoverflow.com/questions/3694918/how-to-extract-frequency-associated-with-fft-values-in-python

sourceFileName = '02 Concert pour violon, piano & quat.wav'

w = wave.open(sourceFileName, 'r')
print "audio palette: ", sourceFileName
print w.getparams()
listOfFrequencies_A = []

byteList = ''

frate = w.getparams()[2]
sampleRange = 4000

#SECTION 1: extract all the freq at sampleRange interval
for i in range(w.getnframes()):
	#grab frames in groups of sampleRange
	if i % sampleRange == 0 and i > 0 and i < w.getnframes()-sampleRange:
		w.setpos(i-sampleRange)

		data=struct.unpack('{n}h'.format(n=sampleRange), w.readframes(sampleRange) )
		data=np.array(data)
		wthing = np.fft.fft(data)
		freqs = np.fft.fftfreq(len(wthing))
		#print(freqs.min(), freqs.max())

		idx=np.argmax(np.abs(  wthing  )**2)
		freq=freqs[idx]
		freq_in_hertz=abs(freq*frate)
		#print(freq_in_hertz)
		listOfFrequencies_A.insert(i-sampleRange, freq_in_hertz )

		sys.stdout.write( "\r i " + str(i) )
		sys.stdout.flush()




frate=11025.0
amp=64000.0
nchannels=2
sampwidth=2
framerate=int(frate)
nframes=1000
comptype="NONE"
compname="not compressed"
pureSineList_L = []
pureSineList_R = []

print("building lists")
for y in range (len(listOfFrequencies_A)):
	for x in range(nframes):
		pureSineList_L.insert( x, math.sin(2*math.pi* listOfFrequencies_A[y] *(x/frate)))

		sys.stdout.write( "\r y, x " + str(y) + " " + str(x) )
		sys.stdout.flush()

tmpName = sourceFileName + "_" + str(datetime.datetime.now().microsecond) + "_" + str(sampleRange) + ".wav"
wav_file=wave.open(tmpName, 'w')
wav_file.setparams((nchannels,sampwidth,framerate,nframes,comptype,compname))

print("done building lists")
print("printing lists to wave file")

for v1, v2 in zip( pureSineList_L, pureSineList_L ):
	wav_file.writeframes(struct.pack('h', int(v1*amp/2)))
	wav_file.writeframes(struct.pack('h', int(v2*amp/2)))
wav_file.close()


