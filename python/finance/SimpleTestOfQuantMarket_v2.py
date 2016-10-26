"""
	Created by Arlo Emerson, July 7, 2012
"""

from random import *
import sys
import time
from threading import Timer
from Tkinter import *
import uuid

print "python version: " + sys.version


class QuantWorld:
	FreeAgentsList = []
	BuyOrderList = []
	SellOrderList = []
	ClosingPriceHistory = []
	numberOfNatives = 47
	appInstance = object
	_chartInterval = 5.0

	def printOrders(self):
		print "buy orders"
		for i in range(0, len(self.BuyOrderList)):
			print self.BuyOrderList[i].price

		print "sell orders"
		for i in range(0, len(self.SellOrderList)):
			print self.SellOrderList[i].price

	def beginQuantWorld(self, master=None):
		print "---begin---"
		self.marketTick()

		#seed the world with Entities
		for i in range(0, self.numberOfNatives):
			newEntity = FreeAgent(i, self)
			newEntity.goTrade()

	def marketTick(self):
		#attempt to match all open orders
		#loop the sell list
		for i in range(0, len(self.SellOrderList)):

			orderToMatch = self.SellOrderList[i]

			if (orderToMatch.status == "open"):

				for j in range(0, len(self.BuyOrderList)):

					if (self.BuyOrderList[j].status == "open"):

						if (orderToMatch.price == self.BuyOrderList[j].price):

							#go deactivate sister OCO order
							if (orderToMatch.guid != "foo"):
								for p in range(0, len(self.SellOrderList)):
									if (self.SellOrderList[p].guid == orderToMatch.guid):
										self.SellOrderList[p].status = "closed"

							#print "order match" + str(orderToMatch.price)
							self._currentClose = orderToMatch.price
							self.ClosingPriceHistory.append(self._currentClose)
							orderToMatch.status = "closed"
							self.BuyOrderList[j].status = "closed"


		#loop the buy list
		for i in range(0, len(self.BuyOrderList)):
			orderToMatch = self.BuyOrderList[i]

			if (orderToMatch.status == "open"):

				for j in range(0, len(self.SellOrderList)):

					if (self.SellOrderList[j].status == "open"):

						if (orderToMatch.price == self.SellOrderList[j].price):

							#go deactivate sister OCO order
							if (orderToMatch.guid != "foo"):
								for p in range(0, len(self.BuyOrderList)):
									if (self.BuyOrderList[p].guid == orderToMatch.guid):
										self.BuyOrderList[p].status = "closed"

							#print "order match" + str(orderToMatch.price)
							self._currentClose = orderToMatch.price
							self.ClosingPriceHistory.append(self._currentClose)
							orderToMatch.status = "closed"
							self.SellOrderList[j].status = "closed"
							self.SellOrderList.pop(j)

		#garbage collect all closed orders
		"""
		for t in range(0, len(self.BuyOrderList)):
			#orderToMatch = self.BuyOrderList[t]
			if (self.BuyOrderList[t].status == "closed"):
				self.BuyOrderList.pop(t)

		for t in range(0, len(self.SellOrderList)):
			#orderToMatch = self.SellOrderList[t]
			if (self.SellOrderList[t].status == "closed"):
				self.SellOrderList.pop(t)
		"""

		#print "sell orders: " + str(len(self.SellOrderList))
		#print "buy orders: " + str(len(self.BuyOrderList))
		print str(self._currentClose)

		tmr = Timer(0.5, self.marketTick)
		tmr.start()


	def submitOrder(self, pDirection, pPrice, pGUID):
			self._orderID += 1
			newOrder = Order(self._orderID, pDirection, pPrice)
			newOrder.status = "open"
			newOrder.guid = pGUID
			if (pDirection == "buy"):
				self.BuyOrderList.append( newOrder )
			elif (pDirection == "sell"):
				self.SellOrderList.append( newOrder )

	def randomBid(self):
		tmpDiscount = randrange(0,9)
		tmpPrice = self._currentClose-(tmpDiscount*.1)
		tmpPrice += self.getHumanFactor()*.1
		tmpGuid = uuid.uuid4()
		self.submitOrder("buy", tmpPrice, "foo")
		self.submitOrder("sell", tmpPrice+10, tmpGuid)
		self.submitOrder("sell", tmpPrice-10, tmpGuid)

	def randomOffer(self):
		tmpBonus = randrange(0,9)
		tmpPrice = self._currentClose+(tmpBonus*.1)
		tmpPrice += self.getHumanFactor()*.1
		tmpGuid = uuid.uuid4()
		self.submitOrder("sell", tmpPrice, "foo")
		self.submitOrder("buy", tmpPrice+10, tmpGuid)
		self.submitOrder("buy", tmpPrice-10, tmpGuid)

	def getHumanFactor(self):
		#this is fear or greed, depends on how you add it back
		return randrange(0,9)

	def __init__(self):
		self._orderID = 1
		self._currentOpen = 0.0
		self._currentClose = 100.0 #default parity
		self._currentHigh = 0.0
		self._currentLow = 0.0
		self._tickVolume = 0.0

class FreeAgent:
	parentInstance = object

	def getRandomTradingStyle(self):
		return randrange(1,4)

	def goTrade(self):
		tradingStyle = self.getRandomTradingStyle()
		#print tradingStyle

		if tradingStyle	== 1:
			self.parentInstance.randomBid()
		if tradingStyle == 2:
			self.parentInstance.randomOffer()

		tmr = Timer(1.0, self.goTrade)
		tmr.start()

	def __init__(self, pfreeAgentID, parentInstance):
		self.freeAgentID = pfreeAgentID
		self.parentInstance = parentInstance
		self._netWorth = 3

class Order:

	def __init__(self, pOrderID, pDirection, pPrice):
		self.orderID = pOrderID
		self.direction = pDirection #buy or sell
		self.price = pPrice
		self.stopLoss = 0.0
		self.limit = 0.0
		self.guid = ""
		self.status = "closed"

class Application(Frame):
	resetGame = 0

	def beginQuantWorld(self):
		self.qw.beginQuantWorld()

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
		self.reset["text"] = "printOrders"
		self.reset["fg"]   = "red"
		self.reset["command"] =  self.printOrders
		self.reset.pack({"side": "left"})

		self.entitiesLabel = Label(self)
		self.entitiesLabel["text"] = "Entities",
		self.entitiesLabel.pack()

		self.entitiesLabelVar = StringVar()

		self.entitiesLabelVal = Label(root, textvariable = self.entitiesLabelVar)
		self.entitiesLabelVal["text"] = "-"
		#self.entitiesLabelVal.place(x=290, y= 200, width=100, height=20)
		self.entitiesLabelVal.pack()

	def printOrders(self):
		self.qw.printOrders()


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




