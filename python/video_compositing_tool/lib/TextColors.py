# -*- coding: utf8 -*-

KNOCKOUT = '\033[100m'
FOO2 = '\033[104m'
WHITE = '\033[97m'
CYAN = '\033[96m'
HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
ENDC = '\033[0m'
INVERTED = '\033[7m'
BLINK = '\033[5m'
UNDERLINE = '\033[4m'
DARKGREEN = '\033[32m'
BOLD = '\033[1m'
HEADERLEFT = FAIL + "░" + FAIL + "▒" + FAIL + "▓" + FAIL + "█"
HEADERLEFT2 = CYAN + "░" + CYAN + "▒" + CYAN + "▓" + CYAN + "█"
HEADERLEFT3 = WARNING + "░" + WARNING + "▒" + WARNING + "▓" + WARNING + "█"
# HEADERLEFT = WARNING + "░" + FAIL + "▒" + CYAN + "▓" + OKGREEN + "█"

def printLogo():
    print(" ")
    print("         ▓█░▓       ▓██▓   ▒░█░    ▒░█░     ▒               ")
    print("       ▒██▓██      ░██░▓  ▒░█░▓   ▓██░█▓  ▒░░▓     ▒░█░       ▒▓░▒      ")
    print("video compositing tool")
   
