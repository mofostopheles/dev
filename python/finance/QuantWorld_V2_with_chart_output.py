"""
	Created by Arlo Emerson, December 9, 2011
"""

from random import *
import sys
import time
from threading import Timer
from Tkinter import *
import os

#print "python version: " + sys.version

class Trio:
	parentInstance = object

	def apply(self, pEntity):
		if len( self.members ) < 3:
			#print "Trio # " + str(self.idNumber) + " is adding member " + str(pEntity)
			self.members.append(pEntity)
			pEntity.trioMembershipId = self.idNumber
			pEntity.trioReference = self
			return "added"

		if len( self.members ) == 3:
			self.parentInstance.AvailableTrios.remove(self)
			self.parentInstance.TrioCloud.append(self)
			#print "Trio # " + str(self.idNumber) + " is full. Members: " + str(self.members)
			return "not_added"

	def __init__(self, parentInstance):
		self.parentInstance = parentInstance
		self.members = []
		self.idNumber = 0
		self.cashAccount = 0
		self.interrogateField()

	def accessCashAccount(self, pAmount):
		self.parentInstance.firstBank.AccountList[self.idNumber].balance += pAmount

	def interrogateField(self):

		for i in range(0, len(self.parentInstance.FreeAgentsList)):
			if self.parentInstance.FreeAgentsList[i].memberOfTrio == 0:
				for j in range(0, len( self.members )):
					if self.members[j].netWorth < self.parentInstance.FreeAgentsList[i].netWorth:
						self.swapMember( self.members[j].freeAgentID, self.parentInstance.FreeAgentsList[i].freeAgentID  )
						print "trio " + str(self.idNumber) + " swapped " + str(self.members[j].freeAgentID) + " for " + str(self.parentInstance.FreeAgentsList[i].freeAgentID)
		#self.parentInstance.appInstance.trioLabelMembersVar.set("asdf")

		t = Timer(2.0, self.interrogateField)
		t.start()


	def swapMember(self, pOutgoingMemberID, pIncomingMemberID):
		#print stats here
		#self.parentInstance.printStats()

		#print "swapping member " + str(pOutgoingMemberID) + " for " + str(pIncomingMemberID)
		self.parentInstance.FreeAgentsList[pOutgoingMemberID].memberOfTrio = 0
		self.parentInstance.FreeAgentsList[pOutgoingMemberID].trioMembershipId = -1
		self.parentInstance.FreeAgentsList[pOutgoingMemberID].trioReference = None

		self.parentInstance.FreeAgentsList[pIncomingMemberID].memberOfTrio = 1
		self.parentInstance.FreeAgentsList[pIncomingMemberID].trioMembershipId = self.idNumber
		self.parentInstance.FreeAgentsList[pIncomingMemberID].trioReference = self


class FirstBankOfQuantWorld:
	parentInstance = object
	AccountList = []

class BankAccount:
	def __init__(self):
		self.balance = 0

class QuantWorld:
	strStatsOutput = ""
	FreeAgentsList = []
	TrioCloud = []
	numberOfNatives = 13
	numberOfTrios = 3
	AvailableTrios = []
	appInstance = object

	firstBank = FirstBankOfQuantWorld()

	def sayHi(self):
		print "hi"

	def __init__(self, pAppInstance):
		print "quant world instance"
		self.appInstance = pAppInstance

	def beginQuantWorld(self, master=None):
		print "---begin---"

		#seed the universe with Entities
		for i in range(0, self.numberOfNatives):
			newEntity = FreeAgent(i, self)
			self.FreeAgentsList.append( newEntity )

			self.appInstance.entitiesLabel = Label(self.appInstance)
			self.appInstance.entitiesLabel["text"] = "FreeAgent " + str(i)
			self.appInstance.entitiesLabel.pack()

		self.appInstance.entitiesLabelVar.set(self.numberOfNatives)

		#create Trios
		for i in range(0, self.numberOfTrios):
			newTrio = Trio(self)
			newTrio.idNumber = i
			self.AvailableTrios.append( newTrio )

			self.appInstance.trioLabels = Label(self.appInstance)
			self.appInstance.trioLabels["text"] = "Trio " + str(i)
			self.appInstance.trioLabels.pack()

			self.appInstance.trioLabelMembersVar = StringVar()
			self.appInstance.trioLabelMembers = Label(self.appInstance, textvariable = self.appInstance.trioLabelMembersVar)
			self.appInstance.trioLabelMembers["text"] = "-"
			self.appInstance.trioLabelMembers.pack()

			#create bank accounts for Trios
			newBankAccount = BankAccount()
			self.firstBank.AccountList.append(newBankAccount)

		for i in range(0, self.numberOfNatives):
			for i in range(0, len(self.FreeAgentsList)):
				self.FreeAgentsList[i].beSocial()

	"""
		TO DO: implement financial charts to show trends
	"""
	def printStats(self):
		print "___________________ STATUS ___________________________"
		print "number of free agents: " + str(self.numberOfNatives)
		print "number of trio licenses: " + str(self.numberOfTrios)
		print "list of free agent net worths:"
		for i in range(0, len(self.FreeAgentsList)):
			print str(self.FreeAgentsList[i]) + " " + str(self.FreeAgentsList[i].netWorth)
			self.strStatsOutput = self.strStatsOutput + str(self.FreeAgentsList[i].netWorth) + ","

		print "list of trios and cash accounts:"
		for i in range(0, len(self.TrioCloud)):
			print "number of members:" + str(self.TrioCloud[i].members)
			print str( self.TrioCloud[i] ) + str( self.firstBank.AccountList[self.TrioCloud[i].idNumber].balance )
			self.strStatsOutput = self.strStatsOutput + str( self.firstBank.AccountList[self.TrioCloud[i].idNumber].balance) + ","

		self.strStatsOutput = self.strStatsOutput + "\n"

		path, file = os.path.split(os.path.abspath(__file__))
		#print "++++++++++++++++++ " + path
		f = open(path + '\QuantWorldChart.csv', 'w')
		f.write(self.strStatsOutput)
		f.close()

		tmr = Timer(4.0, self.printStats)
		tmr.start()

	def printStatsHeader(self):
		for i in range(0, len(self.FreeAgentsList)):
			self.strStatsOutput = self.strStatsOutput + "freeAgent_" + str(self.FreeAgentsList[i].freeAgentID) + ","

		for i in range(0, len(self.TrioCloud)):
			self.strStatsOutput = self.strStatsOutput + "bank_" + str( self.TrioCloud[i].idNumber ) + ","

		self.strStatsOutput = self.strStatsOutput + "\n"


class FreeAgent:
	parentInstance = object

	def talk(asdf):
		retVal = randrange(0,2)
		return retVal

	def seekConversation(self):
		#loop the master list of entities
		#look for other entities to converse with
		for i in range(0, len(self.parentInstance.FreeAgentsList)):
			if self != self.parentInstance.FreeAgentsList[i]:
				if self.trioMembershipId != self.parentInstance.FreeAgentsList[i].trioMembershipId:
					self.memoryOfAllConversations += str( self.parentInstance.FreeAgentsList[i].talk())
					valueOfConversation = randrange(1,3) #natural stimuli introduced deviation
					valueOfConversation = valueOfConversation * 0.01
					self.netWorth += valueOfConversation
					self.parentInstance.FreeAgentsList[i].netWorth += valueOfConversation

					self.payTrioMembershipFee()

		t1 = Timer(3.0, self.seekConversation)
		t1.start()

	def payTrioMembershipFee(self):
		feeAmount = 0.01
		if self.memberOfTrio == 1:
			self.netWorth -= feeAmount
			self.trioReference.accessCashAccount(feeAmount)

	def applyToJoinTrio(self):
		if self.memberOfTrio == 0:
			for i in range(0, len(self.parentInstance.AvailableTrios)):
				try:
					if not self.parentInstance.AvailableTrios[i]:
						print "index error on AvailableTrios"
				except IndexError:
					print "FreeAgent " + str(self.freeAgentID) + " could not join a Trio"
					continue

				applicationResult = self.parentInstance.AvailableTrios[i].apply(self)
				if applicationResult == "added":
					self.memberOfTrio = 1
					break
		t2 = Timer(3.2, self.applyToJoinTrio)
		t2.start()

	def __init__(self, pfreeAgentID, parentInstance):
		self.freeAgentID = pfreeAgentID
		self.parentInstance = parentInstance
		self.memoryOfAllConversations = "0"
		self.netWorth = 3
		self.memberOfTrio = 0
		self.trioReference = None
		self.trioMembershipId = -1
		#print "new free agent "+ str(self.freeAgentID) + " created"

	def beSocial(self):
		self.seekConversation()
		self.applyToJoinTrio()


class Application(Frame):
	resetGame = 0

	def beginQuantWorld(self):
		self.qw.beginQuantWorld()
		self.qw.printStatsHeader()
		self.qw.printStats()


	def reset(self):
		self.resetGame = 1

	def createWidgets(self):
		self.QUIT = Button(self)
		self.QUIT["text"] = "QUIT"
		self.QUIT["fg"]   = "red"
		self.QUIT["command"] =  self.quit
		self.QUIT.pack({"side": "left"})
		self.hi_there = Button(self)
		self.hi_there["text"] = "Begin",
		self.hi_there["command"] = self.beginQuantWorld
		self.hi_there.pack({"side": "left"})
		self.reset = Button(self)
		self.reset["text"] = "RESET"
		self.reset["fg"]   = "red"
		self.reset["command"] =  self.reset
		self.reset.pack({"side": "left"})

		self.entitiesLabel = Label(self)
		self.entitiesLabel["text"] = "Entities",
		self.entitiesLabel.pack()

		self.entitiesLabelVar = StringVar()

		self.entitiesLabelVal = Label(root, textvariable = self.entitiesLabelVar)
		self.entitiesLabelVal["text"] = "-"
		#self.entitiesLabelVal.place(x=290, y= 200, width=100, height=20)
		self.entitiesLabelVal.pack()

		#self.entitiesLabelVar.set("asdfsadf")

		"""
		self.run_something = Button(self)
		self.run_something["text"] = "Run"
		self.run_something["fg"] = "red"
		self.run_something["command"] = Trio.interrogateField
		self.run_something.pack({"side": "left"})
		"""

	def __init__(self, master=None):
		Frame.__init__(self, master)
		self.pack()
		self.createWidgets()
		self.qw = QuantWorld( self )

root = Tk()
root.geometry("300x280+300+300")
app = Application(master=root)
app.mainloop()
root.destroy()


#http://infohost.nmt.edu/tcc/help/pubs/tkinter/control-variables.html




