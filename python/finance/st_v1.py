import httplib
import re

hostname = "www.google.com"

reqString = "/search?q=fear+OR+scared+site%3Abloomberg.com&hl=en&biw=1095&bih=895&num=10&lr=&ft=i&cr=&safe=images&tbs=qdr:d#sclient=psy-ab&hl=en&lr=&tbs=cdr:1%2Ccd_min%3A12%2F12%2F2011%2Ccd_max%3A12%2F12%2F2011&source=hp&q=DOW%20AND%20fear%20OR%20scared%20OR%20uncertainty%20site%3Abloomberg.com&pbx=1&oq=&aq=&aqi=&aql=&gs_sm=&gs_upl=&bav=on.2,or.r_gc.r_pw.r_cp.,cf.osb&fp=a1bc1589ec616832&biw=1095&bih=895&pf=p&pdl=3000"


conn = httplib.HTTPConnection(hostname)
conn.request("GET", reqString)
r1 = conn.getresponse()

print r1.status, r1.reason


"""
data1 = r1.read()


print data1
m = re.search('(?<=About )\w+', data1)
print m.group(0)
"""



conn.close()
