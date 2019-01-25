'''
  Based on original script for encoding process -- essence digital

  Script converts video to PNG, then PNG into JPG, then base64 from each JPG.
  For initial testing purposes we rebuild a JPEG from each base64 segment so we can preview the quality.

  Usage:
  python ~/Documents/xxxxxx/vid_b64_test.py -w ~/Documents/xxxxxx/ -i XXXXXXXXXXXXXXXX.mov -o input%003d.png -s 600 -q 30 

  IMPORTANT: make sure you put a slash at the end of the -w argument.
'''


import os
import subprocess
import sys
import getopt
import base64

def main(argv):
    inputfile = ''
    outputfile = ''
    workpath = ''
    quality = '100'
    size = '600'
    usage = 'Usage: process.py -w [WORKING DIRECTORY] -i [INPUT VIDEO FILE] -o [OUTPUT PNG e.g. input%003d.png] -s [VIDEO WIDTH] -q [QUALITY i.e. kb per frame] \
            \n \
            WARNING: whole lot of hard-coded stuff in the script. FOR TESTING PURPOSES ONLY'

    try:
       opts, args = getopt.getopt(argv,'i:o:s:q:w:',['ifile=','ofile=','size=','qual=', 'workpath='])
    except getopt.GetoptError:
       print usage
       sys.exit(2)
    for opt, arg in opts:
       print(opt+" "+arg)
       if opt == '-h':
          print usage
          sys.exit()
       elif opt in ("-i", "--ifile"):
          inputfile = arg
       elif opt in ("-o", "--ofile"):
          outputfile = arg
       elif opt in ("-q", "--qual"):
          quality = arg
       elif opt in ("-s", "--size"):
          size = arg
       elif opt in ("-w", "--workpath"):
          workpath = arg
    print(unicode(args))

    # -r 15 forces framerate to 15fps
    os.system("ffmpeg -i " + workpath + inputfile + " -r 15 " + workpath + outputfile)

    os.system("convert " + workpath + "input*.png -quality "+str(quality)+" " + workpath + "output.jpg")

    proc = subprocess.Popen(["ls " + workpath + "*.jpg | wc -l"], stdout=subprocess.PIPE, shell=True)
    (nframes, err) = proc.communicate()

    strBase64Name = "_b64__quality_" + str(quality) + "_.txt"
    text_file = open(workpath + strBase64Name, "w")

    # open each JPG, convert to B64 and save to file
    for x in range(0, int(nframes)):
      filename = workpath + "output-"+str(x)+".jpg"
      text_file.write(open(filename, "rb").read().encode("base64").replace("\n",""))
      text_file.write("\n")
    text_file.close()

    base64File = open( workpath + strBase64Name, "rb")
    index = 0

    for line in base64File:
      tmpFile = open(workpath + "reconstruct_" + str( index ) + ".jpeg", "w")
      tmpFile.write(base64.decodestring(line))
      tmpFile.close()
      index += 1 

    # just move these out of the way, may need to look at them for reference
    os.system("mkdir " + workpath + "tmp")
    os.system("mv " + workpath + "*.png " + workpath  + "tmp")
    os.system("mv " + workpath + "*.jpg " + workpath  + "tmp")

main(sys.argv[1:])
