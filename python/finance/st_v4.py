import re
import webbrowser
import win32com.client as comclt
from time import sleep
from PAM30 import *

wsh= comclt.Dispatch("WScript.Shell")

myURL = "www.google.com"

ie = PAMIE( )
ie.navigate(myURL)
sleep(2)
wsh.SendKeys("foobar code")
ie.clickButton("btnG" )
sleep(1)
ie.clickElement("gbxx" )
wsh.SendKeys("{TAB}")
sleep(2)
wsh.SendKeys("{TAB}")
sleep(2)
wsh.SendKeys("^a")
sleep(2)
wsh.SendKeys("^c")

#javascript:alert(document.body)