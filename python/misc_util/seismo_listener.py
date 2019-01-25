import serial
import time
import datetime
import httplib
from urllib2 import Request, urlopen

#note: the following port value will differ per machine
ser = serial.Serial('COM44', 115200)

thresholdValue = 9
sensorValue = "x"
strForCSV = ""
timestamp = ""
formattedDate = ""
sensorActive = 0
tmpCounter = 0
tmpFileName = ""
quakeLog = []
lookback = 20
richterValue = 0.0

def readSerial():
	global ser, sensorValue, strForCSV, richterValue, timestamp, formattedDate, sensorActive, thresholdValue, tmpCounter, tmpFileName, quakeLog, lookback

	sensorReadingDivisor = 31
	tmpSensorValue = 0 #floating point not supported by MICROBITS
	sensorValue = ser.readline()
	tmpSensorValue = float(sensorValue)
	print tmpSensorValue

	if tmpSensorValue >= thresholdValue and sensorActive == 0:
		print "earthquake in progress"
		strForCSV = "" #wipe clean
		sensorActive = 1
		timestamp = time.time()
		formattedDate = datetime.datetime.fromtimestamp(timestamp).strftime('%m-%d-%Y %H:%M:%S')
		tmpFileName = datetime.datetime.fromtimestamp(timestamp).strftime('%m-%d-%Y__%H_%M_%S')

	if sensorActive == 1:
		#print str( tmpSensorValue )
		strForCSV = strForCSV + "{0:.2f}".format( float(tmpSensorValue/sensorReadingDivisor) ) + ","
		quakeLog.append(tmpSensorValue) #used for computing richter

	if sensorActive == 1 and len(quakeLog) > 31:
		if isQuakeOver() == True:

			#determine richter scale
			highestVal = sorted(quakeLog, reverse=True)
			print "highest val", highestVal[0]

			richterValue = float( highestVal[0] )

			richterValue = richterValue/sensorReadingDivisor
			print "richter ", richterValue

			#stop logging and write the file
			tmpCounter = 0
			sensorActive = 0
			f = open("quake_data/quake_data_" + tmpFileName + "_" + "{0:.2f}".format(richterValue) + ".csv", 'w')
			f.write("Quake data for " + formattedDate + "\n")
			f.write(strForCSV)

			f.close()
			print 'writing file ' + "'quake_data/quake_data_" + tmpFileName + ".csv'"

			quakeLog = []

	tmpCounter = tmpCounter + 1

def isQuakeOver():
	#look at the last 20 values and see if they are below
	#threshold, e.g. 3
	#if so, quake is over, file can be written
	#and richter calculated

	global quakeLog, thresholdValue, lookback
	calmnessCounter = 0

	sublist = quakeLog[-lookback:] #last N items

	#print "begin printing"
	for i in range(0, lookback):
		#print i, sublist[i]
		if sublist[i] <= thresholdValue:
			calmnessCounter = calmnessCounter+1

	#print "end printing"
	if calmnessCounter == lookback:
		print "quake is over"
		return True
	else:
		return False

#loop
for i in range(0, 100000):
	if i == 99999:
		print "restart python script"
		readSerial()