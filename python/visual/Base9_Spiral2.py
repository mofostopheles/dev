from visual import *

def isPrime(pInt):
	weArePrime = false
	numberIsDirty = false

	for i in range(2, pInt):
		remainder = pInt%i
		if remainder==0:
			numberIsDirty = true

	if numberIsDirty != true:
		weArePrime = true

	return weArePrime

def testNumber(pInt):
	#persian rug
	#if round(  pow(sqrt(pInt)/pi, 3.3) )%2==0:
	return isPrime(pInt)

#
#color the dot
#
def setColor(pDot, pColor):
	pDot.color = color.red

def getNumberSelfAffinity(pInt):
	# 2-layer z-zone
	#return sin(  pInt * pInt/ pInt )

	#pyramid
	#return (sqrt(pInt)/pi)*2

	#TALLER PYRAMIDS
	return (sqrt(pInt)*5)/pi

#
#main function
#
def createTable():

	f=open("workfile.txt", "w")

	counter=0
	for k in range(1,100):

		for i in range(1,10):
			counter=counter+1
			if isPrime(counter):
				f.write("*"+str( counter )+"*")
			else:
				f.write(str( counter ))
			f.write("\t" )

			if i%9==0:
				f.write("\n")


	print f

def createTable2():

	f=open("workfile.html", "w")
	f.write("<body bgcolor='black'><table><tr>")

	counter=0
	for k in range(1,2000):

		for i in range(1,10):
			counter=counter+1
			f.write("<td ")
			if isPrime(counter):
				f.write("style='background-color:red'>"+str( counter ))
			else:
				f.write("style='background-color:white'>" + str( counter ))
			f.write("</td>")

			if i%9==0:
				f.write("</tr><tr>")

	f.write("</table>")
	print f

def createTable3():

	f=open("workfile.html", "w")
	f.write("<body bgcolor='black'><table><tr>")

	counter=0
	for k in range(1,1000):

		max = 19
		for i in range(1,max):
			counter=counter+1
			f.write("<td ")
			if isPrime(counter):
				f.write("style='background-color:red'>"+str( counter ))
			else:
				f.write("style='background-color:white'>" + str( counter ))
			f.write("</td>")

			if i%(max-1)==0:
				f.write("</tr><tr>")

	f.write("</table>")
	print f

def createNumberSeq1():

	f=open("base-1-list.txt", "w")

	counter=0
	for k in range(1,100):

		for i in range(1,10):
			counter=counter+1
			f.write(str( counter )+",")
			f.write("\t" )

			if i%9==0:
				f.write("\n")


	print f

#fire it up
createTable3()