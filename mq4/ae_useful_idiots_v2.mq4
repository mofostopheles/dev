//arlo emerson, 3/27/2013

/*
	this expert uses patterns based on actual user's (me) fear and greed. 
	when the chart creates a pattern that matches one of these fear/greed profiles, 
	we paint an arrow and or enter a trade.
	the trick is that we will enter in the opposite direction, just like the mm. 
	
	the premise is: if indicators are laggy (they are), and all the dumb money is using them (they are),
	then create a bunch of idiotic trade recommendations based on these indicators, but take the opposite trade.
	
	patterns are:
	- above/below 34 ema, piercing the boll bands
*/

//globally adjust tp/sl
double _stopLossFactor = 8;
double _takeProfitFactor = 35;

#define    SECINMIN         60  //Number of seconds in a minute

extern int  TimeFrame		= 0;
string Sym = "";
string _labelName1 = "ASDFASF";
string _labelName2 = "ASDASDFSAFD";

int _labelIndex = 0;
int _ticketNumber;
bool _modifyOrder = false;

double _minDist;
double _bid; // Request for the value of Bid
double _ask; // Request for the value of Ask
double _point;//Request for Point   

double _entryPrice;
double _TP;
double _SL;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   Sym = Symbol();
	cleanUpChart();
	return(0);
}

int cleanUpChart()
{
	for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
	{
         string on = ObjectName(iObj);
         if (StringFind(on, _labelName1, 0) > -1)
         {
            ObjectDelete(on);
         }
         else if (StringFind(on, _labelName2, 0) > -1)
         {
            ObjectDelete(on);
         }
   }
   return(0);
}

int i=0; //i is never incremented. hard-code a 0 everywhere this occurs
int ThisBarTrade=0;


int start()
{
   if (Bars != ThisBarTrade )
   //for(int i = Bars; i >= 0; i--)
   {
		ThisBarTrade = Bars;
   
      //declarations
      int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
	        time1  = iTime    (NULL,TimeFrame,shift1);
	        
		//int fiveMinuteShift= MathFloor(i/5);
		//int hourlyShift= MathFloor(i/60);
		//int fourHourlyShift= MathFloor(i/240);
      int hourlyShift= MathFloor(i/12);
      int fourHourlyShift= MathFloor(i/48);

	   double	high		= iHigh(NULL,TimeFrame,shift1),
			low		= iLow(NULL,TimeFrame,shift1),
			open		= iOpen(NULL,TimeFrame,shift1),
			close		= iClose(NULL,TimeFrame,shift1),
	 		bodyHigh	= MathMax(open,close),
			bodyLow	= MathMin(open,close);
			
  		int minus1CandleTime = iTime(NULL,TimeFrame,shift1+1);
   	int minus1CandleIndex = iTime(NULL,TimeFrame,shift1+1);
   	double minus1CandleOpen = iOpen(NULL,TimeFrame,shift1+1);
   	double minus1CandleClose = iClose(NULL,TimeFrame,shift1+1);
   	double minus1CandleLow = iLow(NULL,TimeFrame,shift1+1);
   	double minus1CandleHigh = iHigh(NULL,TimeFrame,shift1+1);

   	double minus2CandleLow = iLow(NULL,TimeFrame,shift1+2);
   	double minus2CandleHigh = iHigh(NULL,TimeFrame,shift1+2);
   	double minus2CandleClose = iClose(NULL,TimeFrame,shift1+2);
   	double minus2CandleOpen = iOpen(NULL,TimeFrame,shift1+2);

   	double minus3CandleLow = iLow(NULL,TimeFrame,shift1+3);
   	double minus3CandleHigh = iHigh(NULL,TimeFrame,shift1+3);
   	double minus3CandleClose = iClose(NULL,TimeFrame,shift1+3);
   	double minus3CandleOpen = iOpen(NULL,TimeFrame,shift1+3);
   
   	double minus4CandleLow = iLow(NULL,TimeFrame,shift1+4);
   	double minus4CandleHigh = iHigh(NULL,TimeFrame,shift1+4);
   	double minus4CandleClose = iClose(NULL,TimeFrame,shift1+4);
   	double minus4CandleOpen = iOpen(NULL,TimeFrame,shift1+4);

//***************** 34 EMA WAVE ******************//					
		double ema34HighMinus1Candle = iMA(Sym,TimeFrame,34,0,MODE_EMA,PRICE_HIGH,shift1+1);
		double ema34LowMinus1Candle = iMA(Sym,TimeFrame,34,0,MODE_EMA,PRICE_LOW,shift1+1);				
		double ema34CloseMinus1Candle = iMA(Sym,TimeFrame,34,0,MODE_EMA,PRICE_CLOSE,shift1+1);
		
		double ema34HighMinus2Candle = iMA(Sym,TimeFrame,34,0,MODE_EMA,PRICE_HIGH,shift1+2);
		double ema34LowMinus2Candle = iMA(Sym,TimeFrame,34,0,MODE_EMA,PRICE_LOW,shift1+2);				
		double ema34CloseMinus2Candle = iMA(Sym,TimeFrame,34,0,MODE_EMA,PRICE_CLOSE,shift1+2);
		
//***************** 160 TYPICAL ******************//					
		double ema160Minus1Candle = iMA(Sym,TimeFrame,160,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
	
      
//*****************    MACd     ******************//

   	//MACD
   	double fiveMinMacdMinus1Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+1);
   	double fiveMinMacdMinus2Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+2);
   	double fiveMinMacdMinus3Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+3);
   	double fiveMinMacdMinus4Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+4);
        
            
/* ------------------------- TRADE LOGIC ---------------------------*/
		RefreshBidsAndAsks();
		
		//remember, these conditions mimick the dumb money.
		//watch out for fitting the algo to the chart
		
		//BUYING PATTERN MATCH
		if (
				lastNCandlesAreBulls(5, i) == true
				&& minus1CandleHigh > ema34HighMinus1Candle
				
				&& 7 == 1
			)
			{

				ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleOpen);
				ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
				ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);

				if(i == 0)//only trade current candle
				{        
					if (OrdersTotal() == 0)
					{                  
   					//open new order            
   					_ticketNumber = OrderSend(Sym,OP_BUY,0.1,_ask,3,0,0,"order #" + _labelIndex,0,0,Green); 
                      
   					if(_ticketNumber<0)
   					{
      					Print("Trying to buy. OrderSend failed with error #",GetLastError());
   					}
   					else
   					{               	
      					//mod ticket
      					_TP = _bid+_takeProfitFactor*(10*_point);
      					_SL=_bid-_stopLossFactor*(10*_point);                  
      					_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
      					_entryPrice = minus1CandleClose;
      					//Print("entry price is: " + _entryPrice);
      					Print("OrderModify on a buy last called. Last error was: ",GetLastError());
   					}           
					}                                             
				}                    
			}
			//SELLING PATTERN MATCH
			else if ( 
							//minus1CandleHigh > iBands(Sym,0,14,2.23,-3,PRICE_HIGH,MODE_UPPER,i+1)
							//&& minus1CandleHigh > ema34HighMinus1Candle
							//&& minus1CandleClose > minus1CandleOpen
							//&& iStdDev(NULL, TimeFrame, 7, 0, MODE_SMA, PRICE_CLOSE, i+1) < 0.07
							//int pLookback, int pMaPeriod, double pLevel, int pIndex
							//&& lastNCandlesBelowStandardDev(2, 7, 0.07, i) == true
							//lastNCandlesAreBulls(5, i) == true
							//&& minus1CandleHigh > ema34HighMinus1Candle
							//&& lastNLowsBelowWaveHigh(8, i) == true
							//&& lastNCandlesBelowStandardDev(5, 7, 0.1, i) == true
							minus1CandleClose > minus1CandleOpen
							//&& minus1CandleClose > ema160Minus1Candle
							//&& lastNLowsBelow160EMA(10, i+4) == true
                     //&& lastNCandlesBelowStandardDev(2, 7, 0.05, i+1) == true
							//&& lastNLowsBelowWaveHigh(8, i+4) == true
							
            		)
      			{
                  ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i+1],open);
                  ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);   
               
                  //--------SELL ORDER---------//
                  if(i==0)//only trade current candle
                  {     
                     if (OrdersTotal() == 0)//open new order because one isn't open
                     {
                        _ticketNumber = OrderSend(Sym,OP_SELL,0.1,_bid,3,0,0,"order #" + _labelIndex,0,0,Red);               
                        if(_ticketNumber<0)
                        {
                           Print("OrderSend on a sell failed with error #",GetLastError());
                        }
                        else
                        {
                           //mod ticket
                           _TP=_ask-_takeProfitFactor*(10*_point);
                           _SL=_ask+_stopLossFactor*(10*_point);
                           _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                           
                           Print("OrderModify on a buy last called. Last error was: ",GetLastError());
                        }
                     }
                  }  
                                    
      			}

		/*------- last thing you do is update the index --------*/
		_labelIndex++;
	}   
	return(0);
}


int RefreshBidsAndAsks()
{
   RefreshRates();
   _bid   =MarketInfo(Sym,MODE_BID); // Request for the value of Bid
   _ask   =MarketInfo(Sym,MODE_ASK); // Request for the value of Ask
   _point =MarketInfo(Sym,MODE_POINT);//Request for Point   
   _minDist=MarketInfo(Sym,MODE_STOPLEVEL);// Min. distance
   return (0);
}

int isCandleExtraWicky(double pOpen, double pClose, double pHigh, double pLow)
{
   if (
         (pClose > pOpen && pClose - pOpen <= (pHigh - pLow)/3)
         ||
         (pClose < pOpen && pOpen - pClose <= (pHigh - pLow)/3)
		 )
		 {
         return (1);
       }
       else
       {
         return(0);
       }
}

bool lastNLowsBelow160EMA(int pLookback, int pIndex)
{
	int counter = 0;

   for (int z=0;z<=pLookback;z++)
   {
		double candleOpen = iOpen(NULL,TimeFrame,z+pIndex);
		double candleClose = iClose(NULL,TimeFrame,z+pIndex);
		double candleHigh = iHigh(NULL,TimeFrame,z+pIndex);
		double candleLow = iLow(NULL,TimeFrame,z+pIndex);
		double emaPrice = iMA(NULL,TimeFrame,160,0,MODE_EMA,PRICE_TYPICAL,z+pIndex);
		
      if ( candleLow < emaPrice ) //was recent price below
      {
         counter += 1;      
      }
	}

   if (counter == pLookback)
   {
      return (true);
   }
   else
   {
      return (false);
   }
}

bool lastNLowsBelowWaveHigh(int pLookback, int pIndex)
{
	int counter = 0;

   for (int z=0;z<=pLookback;z++)
   {
		double candleOpen = iOpen(NULL,TimeFrame,z+pIndex);
		double candleClose = iClose(NULL,TimeFrame,z+pIndex);
		double candleHigh = iHigh(NULL,TimeFrame,z+pIndex);
		double candleLow = iLow(NULL,TimeFrame,z+pIndex);
		double ema34High = iMA(NULL,TimeFrame,34,0,MODE_EMA,PRICE_HIGH,z+pIndex);
		
      if ( candleLow < ema34High ) //was recent price below
      {
         counter += 1;      
      }
	}
Print(counter + " " + pLookback);
   if (counter == pLookback)
   {
      return (true);
   }
   else
   {
      return (false);
   }
}

bool lastNCandlesAreBulls(int pLookback, int pIndex)
{
	int counter = 0;

   for (int z=0;z<=pLookback;z++)
   {
		double candleOpen = iOpen(NULL,TimeFrame,z+pIndex);
		double candleClose = iClose(NULL,TimeFrame,z+pIndex);
      if ( candleOpen < candleClose ) //was recent price below
      {
         counter += 1;      
      }
	}

   if (counter == pLookback)
   {
      return (true);
   }
   else
   {
      return (false);
   }
}

bool lastNCandlesBelowStandardDev(int pLookback, int pMaPeriod, double pLevel, int pIndex)
{
   int counter = 0;

   for (int z=0;z<=pLookback;z++)
   {
      if (iStdDev(NULL, TimeFrame, pMaPeriod, 0, MODE_SMA, PRICE_CLOSE, z+pIndex) <= pLevel) 
      {
         counter += 1;      
      }
	}

   if (counter == pLookback)
   {
      return (true);
   }
   else
   {
      return (false);
   }
}



