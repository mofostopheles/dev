"""
	Created by Arlo Emerson, July 3, 2012
"""

from random import *
import sys
import time
from threading import Timer
from Tkinter import *

print "python version: " + sys.version


class QuantWorld:
	FreeAgentsList = []
	BuyOrderList = []
	SellOrderList = []
	ClosingPriceHistory = []
	numberOfNatives = 17
	appInstance = object
	_allPrices = ""
	_chartInterval = 5.0

	def beginQuantWorld(self, master=None):
		print "---begin---"
		self.marketTick()

		#seed the world with Entities
		for i in range(0, self.numberOfNatives):
			newEntity = FreeAgent(i, self)
			newEntity.goTrade()
			#self.FreeAgentsList.append( newEntity )
			#self.appInstance.entitiesLabel = Label(self.appInstance)
			#self.appInstance.entitiesLabel["text"] = "FreeAgent " + str(i)
			#self.appInstance.entitiesLabel.pack()

	def incrementTickVolume(self):
		self._tickVolume += 0.1

	def marketTick(self):
		#attempt to match all open orders
		#loop the sell list
		for i in range(0, len(self.SellOrderList)):

			orderToMatch = self.SellOrderList[i]

			if (orderToMatch.status == "open"):

				for j in range(0, len(self.BuyOrderList)):

					if (self.BuyOrderList[j].status == "open"):

						if (orderToMatch.price == self.BuyOrderList[j].price):
							self._currentClose += 0.1
							self.ClosingPriceHistory.append(self._currentClose)
							orderToMatch.status = "closed"
							self.BuyOrderList[j].status = "closed"
							self.incrementTickVolume()



		#loop the buy list
		for i in range(0, len(self.BuyOrderList)):
			orderToMatch = self.BuyOrderList[i]

			if (orderToMatch.status == "open"):

				for j in range(0, len(self.SellOrderList)):

					if (self.SellOrderList[j].status == "open"):

						if (orderToMatch.price == self.SellOrderList[j].price):
							self._currentClose -= 0.1
							self.ClosingPriceHistory.append(self._currentClose)
							orderToMatch.status = "closed"
							self.SellOrderList[j].status = "closed"
							self.incrementTickVolume()


		#print "sell orders: " + str(len(self.SellOrderList))
		#print "buy orders: " + str(len(self.BuyOrderList))
		print str(self._currentClose) #+ " " + str(self._tickVolume)

		tmr = Timer(0.1, self.marketTick)
		tmr.start()

	def chaseLastPrice(self):
		if (len(self.ClosingPriceHistory)>1):
			if (self.ClosingPriceHistory[ len(self.ClosingPriceHistory)-1 ] > self._currentClose):
				self.submitOrder("buy", self._currentClose)
			elif (self.ClosingPriceHistory[ len(self.ClosingPriceHistory)-1 ] < self._currentClose):
				self.submitOrder("sell", self._currentClose)

	def sellLastPrice(self):
		self.submitOrder("sell", self._currentClose)

	def buyLastPrice(self):
		self.submitOrder("buy", self._currentClose)

	def submitOrder(self, pDirection, pPrice):
			self._orderID += 1
			newOrder = Order(self._orderID, pDirection, pPrice)
			newOrder.status = "open"
			if (pDirection == "buy"):
				self.BuyOrderList.append( newOrder )
			elif (pDirection == "sell"):
				self.SellOrderList.append( newOrder )


	def __init__(self):
		self._orderID = 1
		self._currentOpen = 0.0
		self._currentClose = 1.0 #default parity
		self._currentHigh = 0.0
		self._currentLow = 0.0
		self._tickVolume = 0.0

class FreeAgent:
	parentInstance = object

	def getRandomTradingStyle(self):
		return randrange(1,5)

	def goTrade(self):
		tradingStyle = self.getRandomTradingStyle()
		#print tradingStyle

		if tradingStyle	== 1:
			self.parentInstance.chaseLastPrice()
		if tradingStyle == 2:
			self.parentInstance.sellLastPrice()
		if tradingStyle == 3:
			self.parentInstance.chaseLastPrice()
		if tradingStyle == 4:
			self.parentInstance.buyLastPrice()


		tmr = Timer(1.0, self.goTrade)
		tmr.start()

	def __init__(self, pfreeAgentID, parentInstance):
		self.freeAgentID = pfreeAgentID
		self.parentInstance = parentInstance
		self._netWorth = 3
		self._tradingStyle = "chaseTrade"
		self.defaultTradingStyle = self.getRandomTradingStyle()

class Order:

	def __init__(self, pOrderID, pDirection, pPrice):
		self.orderID = pOrderID
		self.direction = pDirection #buy or sell
		self.price = pPrice
		self.status = "closed"

class Application(Frame):
	resetGame = 0

	def beginQuantWorld(self):
		self.qw.beginQuantWorld()
		#self.qw.printStats()

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



	def __init__(self, master=None):
		Frame.__init__(self, master)
		self.pack()
		self.createWidgets()
		self.qw = QuantWorld( )

root = Tk()
root.geometry("300x280+300+300")
app = Application(master=root)
app.mainloop()
root.destroy()


#http://infohost.nmt.edu/tcc/help/pubs/tkinter/control-variables.html




