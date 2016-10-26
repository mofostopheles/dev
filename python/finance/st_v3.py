import re
import webbrowser
import win32com.client as comclt
from time import sleep
from PAM30 import *


"""
	sentiment tracker prototype v3
	search query for 15 days


	references:
	http://www.sentimentnews.com/2009_08_01_archive.html
	send keys
	http://www.rutherfurd.net/python/sendkeys/


	examples here on browser automation for Chrome and IE
"""

"""
hostname = "www.google.com"
for i in range(0, 18):

	dateRange1 = "12%2F" + str(i+1) +"%2F"
	dateRange2 = "12%2F" + str(i+1) +"%2F"
	reqString = "/search?q=fear+OR+scared+site%3Aft.com&hl=en&biw=1095&bih=895&num=10&lr=&ft=i&cr=&safe=images&tbs=qdr:d#sclient=psy-ab&hl=en&lr=&tbs=cdr:1%2Ccd_min%3A" + dateRange1 +  "2011%2Ccd_max%3A" + dateRange2 + "2011&source=hp&q=DOW%20AND%20fear%20OR%20scared%20OR%20uncertainty%20site%3Aft.com&pbx=1&oq=&aq=&aqi=&aql=&gs_sm=&gs_upl=&bav=on.2,or.r_gc.r_pw.r_cp.,cf.osb&fp=a1bc1589ec616832&biw=1095&bih=895&pf=p&pdl=3000"
	webbrowser.open_new_tab(hostname + reqString)




hostname = "www.google.com"
for i in range(0, 18):

	dateRange1 = "12%2F" + str(i+1) +"%2F"
	dateRange2 = "12%2F" + str(i+1) +"%2F"
	reqString = "/search?q=fear+OR+scared+site%3Abloomberg.com&hl=en&biw=1095&bih=895&num=10&lr=&ft=i&cr=&safe=images&tbs=qdr:d#sclient=psy-ab&hl=en&lr=&tbs=cdr:1%2Ccd_min%3A" + dateRange1 +  "2011%2Ccd_max%3A" + dateRange2 + "2011&source=hp&q=DOW%20AND%20fear%20OR%20scared%20OR%20uncertainty%20site%3Abloomberg.com&pbx=1&oq=&aq=&aqi=&aql=&gs_sm=&gs_upl=&bav=on.2,or.r_gc.r_pw.r_cp.,cf.osb&fp=a1bc1589ec616832&biw=1095&bih=895&pf=p&pdl=3000"
	webbrowser.open_new_tab(hostname + reqString)
"""




"""
wsh= comclt.Dispatch("WScript.Shell")

wsh.SendKeys("^a")


data1 = r1.read()


print data1
m = re.search('(?<=About )\w+', data1)
print m.group(0)
"""

#webbrowser.open_new_tab("http://www.sentimentnews.com/2009_08_01_archive.html")

wsh=comclt.Dispatch("WScript.Shell")

hostname = "www.google.com"
dateRange1 = "12%2F" + str(11) +"%2F"
dateRange2 = "12%2F" + str(11) +"%2F"
reqString = "/search?q=fear+OR+scared+site%3Aft.com&hl=en&biw=1095&bih=895&num=10&lr=&ft=i&cr=&safe=images&tbs=qdr:d#sclient=psy-ab&hl=en&lr=&tbs=cdr:1%2Ccd_min%3A" + dateRange1 +  "2011%2Ccd_max%3A" + dateRange2 + "2011&source=hp&q=DOW%20AND%20fear%20OR%20scared%20OR%20uncertainty%20site%3Aft.com&pbx=1&oq=&aq=&aqi=&aql=&gs_sm=&gs_upl=&bav=on.2,or.r_gc.r_pw.r_cp.,cf.osb&fp=a1bc1589ec616832&biw=1095&bih=895&pf=p&pdl=3000"


ie = PAMIE( )
ie.navigate(hostname + reqString)
ie.setTextBox("q", "python" )
ie.clickButton("btnG" )
sleep(3)
wsh.SendKeys("{TAB}")
wsh.SendKeys("^A")



"""

sleep(3)
wsh.SendKeys("^A", 2)



wsh.SendKeys("^F")
wsh.AppActivate("Iexplore")

wsh.SendKeys("%{TAB}", 2)

wsh.SendKeys("^A", 2)
"""
