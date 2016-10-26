import re
import webbrowser
import win32com.client as comclt
from time import sleep
from PAM30 import *
from Tkinter import *

"""
	v.6
	- perform search query
	- copy contents of page to clipboard
	- print to console

"""

root = Tk()
wsh = comclt.Dispatch("WScript.Shell")

hostname = "www.google.com"
for i in range(0, 2):

	dateRange1 = "12%2F" + str(i+1) +"%2F"
	dateRange2 = "12%2F" + str(i+1) +"%2F"

	reqString = "/search?q=fear+OR+scared+site%3Aft.com&hl=en&biw=1095&bih=895&num=10&lr=&ft=i&cr=&safe=images&tbs=qdr:d#sclient=psy-ab&hl=en&lr=&tbs=cdr:1%2Ccd_min%3A" + dateRange1 +  "2011%2Ccd_max%3A" + dateRange2 + "2011&source=hp&q=DOW%20AND%20fear%20OR%20scared%20OR%20uncertainty%20site%3Aft.com&pbx=1&oq=&aq=&aqi=&aql=&gs_sm=&gs_upl=&bav=on.2,or.r_gc.r_pw.r_cp.,cf.osb&fp=a1bc1589ec616832&biw=1095&bih=895&pf=p&pdl=3000"

	webbrowser.open_new_tab(hostname + reqString)
	sleep(5)
	wsh.SendKeys("{TAB}")
	wsh.SendKeys("{TAB}")
	wsh.SendKeys("{TAB}")
	wsh.SendKeys("{TAB}")
	sleep(2)
	wsh.SendKeys("^a")
	sleep(2)
	wsh.SendKeys("^c")

	text = root.selection_get(selection="CLIPBOARD")
	print text.encode("utf-8")
	#print type(text), repr(text)


root.geometry("300x280+300+300")
app = Application(master=root)
app.mainloop()
root.destroy()
