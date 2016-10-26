"""
	CHART TREND BREAKER ALERT SYSTEM
	VERSION 1
"""


from PIL import Image
import ImageChops
import sys
import urllib
import Image


#test...what python version are we running...
print(  sys.version )


# determine if images are identical
def imagesIdentical(im1, im2):
	return ImageChops.difference(im1, im2).getbbox() is None

"""
	1. retrieve a 10-year-note chart
	2. overlay the trend mask (manually drawn)
	3. reposition the trend mask to line up with wherever we started
	4. search the image for pure red or pure green, this will indicate the trend has broken.
	5. send email or text to alert me of trend break
"""
def conductChartAnalysis():
	candlewidth = 6
	dirPath = "C:/Users/v-aremer/Documents/arlo_stuff"

	liveImageURL__tenYearNote = "http://www.finviz.com/fut_chart.ashx?t=ZN&p=h1"
	savedImageName = "/tenyearnote.png"

	#imgTenYearNote = Image.open(urllib.urlopen(liveImageURL__tenYearNote))
	#retreive and save the latest 10 year note chart
	urllib.urlretrieve(liveImageURL__tenYearNote, dirPath + savedImageName)

	imageTrendMask = Image.open(dirPath + "/trend_mask.png")
	imageFrameMask = Image.open(dirPath + "/frame_mask.png")
	imageTenYearNoteChart = Image.open(dirPath + savedImageName)

	#overlay all the masks
	#imageTenYearNoteChart.paste(imageFrameMask, imageFrameMask)

	offset = -6 #this is going to be candlewidth * how many hours we have been running the analysis
	imageTenYearNoteChart.paste(imageTrendMask, (offset,0), imageTrendMask)

	imageTenYearNoteChart.save(dirPath + "/footest.png")


	#im2 = Image.open(dirPath + "/fx_image1.png")
	#out = imagesIdentical(im1, im2)
	#print( out )


conductChartAnalysis()








