//FINALLY, a multiframe indicator
//arlo emerson - 8/28/2012
//based off "curious_v5.mq4"


//globally adjust tp/sl
double _stopLossFactor = 10;
double _takeProfitFactor = 70;

int _matchFoundIndex; //use this to store patterns...we will sort the good from the bad
string _matchFoundLibrary = "";
bool _entryCueMatchFound = false; //set to true when we match a time in the entryCue list
string _entryCueDirection = "";

string _val_macdAVG143421;
string _val_macdAVG8016021;
string _val_EMA_a;
string _val_EMA_b;
string _val_StdDev_a;
string _val_Volume_a;
string _val_Volume_b;
string _val_MFI_a;

string _cciTrendMode = "";

#define    SECINMIN         60  //Number of seconds in a minute

extern int  TimeFrame		= 5;

extern int vsiMAPeriod    = 21;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */

double vsiBuffer[999];
double vsiMABuffer[999];
string Sym = "";

string _labelName1 = "volumeArrow";
string _labelName2 = "hhll_";

string _previousLabel = "";
int _hhIndex = 1;
int _llIndex = 1;

string _lookbackSignalPattern[3] = { "xx", "xx", "xx" }; 

//this is used for tidying up the chart at each new candle
datetime _lastAlertTime;
int _labelIndex = 0;
int _ticketNumber;
bool _modifyOrder = false;

double _minDist;
double _bid; // Request for the value of Bid
double _ask; // Request for the value of Ask
double _point;//Request for Point   


bool _WEAPON_ARMED = false;
bool _LOCKED_ON = false;
double _entryPrice;
double _TP;
double _SL;
int _targetAcquisitionTime;
double _targetAcquisitionPrice;
double _targetAcquisitionHigh;
double _targetAcquisitionLow;
double _targetAcquisitionOpen;
double _targetAcquisitionClose;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   _lastAlertTime = TimeCurrent();
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

bool _firstRun = false;
int i=0; //i is never incremented. hard-code a 0 everywhere this occurs
int ThisBarTrade=0;
int start()
{
   int timeDiff;
   int limit;

   _firstRun = true;
   _lastAlertTime = Time[0];
   
   if (Bars != ThisBarTrade )
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

   	double minus5CandleLow = iLow(NULL,TimeFrame,shift1+5);
   	double minus5CandleHigh = iHigh(NULL,TimeFrame,shift1+5);
   	double minus5CandleClose = iClose(NULL,TimeFrame,shift1+5);

   	double minus6CandleLow = iLow(NULL,TimeFrame,shift1+6);
   	double minus6CandleHigh = iHigh(NULL,TimeFrame,shift1+6);
   	double minus6CandleClose = iClose(NULL,TimeFrame,shift1+6);

   	double minus7CandleLow = iLow(NULL,TimeFrame,shift1+7);
   	double minus7CandleHigh = iHigh(NULL,TimeFrame,shift1+7);
   	double minus7CandleClose = iClose(NULL,TimeFrame,shift1+7);

   	double minus8CandleLow = iLow(NULL,TimeFrame,shift1+8);
   	double minus8CandleHigh = iHigh(NULL,TimeFrame,shift1+8);
   	double minus8CandleClose = iClose(NULL,TimeFrame,shift1+8);

   	double minus9CandleLow = iLow(NULL,TimeFrame,shift1+9);
   	double minus9CandleHigh = iHigh(NULL,TimeFrame,shift1+9);
   	double minus9CandleClose = iClose(NULL,TimeFrame,shift1+9);

   	double minus10CandleLow = iLow(NULL,TimeFrame,shift1+10);
   	double minus10CandleHigh = iHigh(NULL,TimeFrame,shift1+10);
   	double minus10CandleClose = iClose(NULL,TimeFrame,shift1+10);

   	double minus11CandleLow = iLow(NULL,TimeFrame,shift1+11);
   	double minus11CandleHigh = iHigh(NULL,TimeFrame,shift1+11);
   	double minus11CandleClose = iClose(NULL,TimeFrame,shift1+11);
   	double minus11CandleOpen = iOpen(NULL,TimeFrame,shift1+11);

   	double minus12CandleLow = iLow(NULL,TimeFrame,shift1+12);
   	double minus12CandleHigh = iHigh(NULL,TimeFrame,shift1+12);
   	double minus12CandleClose = iClose(NULL,TimeFrame,shift1+12);
   	double minus12CandleOpen = iOpen(NULL,TimeFrame,shift1+12);

   	double minus13CandleLow = iLow(NULL,TimeFrame,shift1+13);
   	double minus13CandleHigh = iHigh(NULL,TimeFrame,shift1+13);
   	double minus13CandleClose = iClose(NULL,TimeFrame,shift1+13);
   	double minus13CandleOpen = iOpen(NULL,TimeFrame,shift1+13);

   	double minus14CandleLow = iLow(NULL,TimeFrame,shift1+14);
   	double minus14CandleHigh = iHigh(NULL,TimeFrame,shift1+14);
   	double minus14CandleClose = iClose(NULL,TimeFrame,shift1+14);
   	double minus14CandleOpen = iOpen(NULL,TimeFrame,shift1+14);

   	double minus15CandleLow = iLow(NULL,TimeFrame,shift1+15);
   	double minus15CandleHigh = iHigh(NULL,TimeFrame,shift1+15);
   	double minus15CandleClose = iClose(NULL,TimeFrame,shift1+15);
   	double minus15CandleOpen = iOpen(NULL,TimeFrame,shift1+15);

   	double minus16CandleLow = iLow(NULL,TimeFrame,shift1+16);
   	double minus16CandleHigh = iHigh(NULL,TimeFrame,shift1+16);
   	double minus16CandleClose = iClose(NULL,TimeFrame,shift1+16);
   	double minus16CandleOpen = iOpen(NULL,TimeFrame,shift1+16);

   	double minus17CandleLow = iLow(NULL,TimeFrame,shift1+17);
   	double minus17CandleHigh = iHigh(NULL,TimeFrame,shift1+17);
   	double minus17CandleClose = iClose(NULL,TimeFrame,shift1+17);
   	double minus17CandleOpen = iOpen(NULL,TimeFrame,shift1+17);

   	double minus18CandleLow = iLow(NULL,TimeFrame,shift1+18);
   	double minus18CandleHigh = iHigh(NULL,TimeFrame,shift1+18);
   	double minus18CandleClose = iClose(NULL,TimeFrame,shift1+18);
   	double minus18CandleOpen = iOpen(NULL,TimeFrame,shift1+18);

   	double minus19CandleLow = iLow(NULL,TimeFrame,shift1+19);
   	double minus19CandleHigh = iHigh(NULL,TimeFrame,shift1+19);
   	double minus19CandleClose = iClose(NULL,TimeFrame,shift1+19);
   	double minus19CandleOpen = iOpen(NULL,TimeFrame,shift1+19);

   	double minus20CandleLow = iLow(NULL,TimeFrame,shift1+20);
   	double minus20CandleHigh = iHigh(NULL,TimeFrame,shift1+20);
   	double minus20CandleClose = iClose(NULL,TimeFrame,shift1+20);
   	double minus20CandleOpen = iOpen(NULL,TimeFrame,shift1+20);

   	double minus21CandleLow = iLow(NULL,TimeFrame,shift1+21);
   	double minus21CandleHigh = iHigh(NULL,TimeFrame,shift1+21);
   	double minus21CandleClose = iClose(NULL,TimeFrame,shift1+21);
   	double minus21CandleOpen = iOpen(NULL,TimeFrame,shift1+21);

   	double minus22CandleLow = iLow(NULL,TimeFrame,shift1+22);
   	double minus22CandleHigh = iHigh(NULL,TimeFrame,shift1+22);
   	double minus22CandleClose = iClose(NULL,TimeFrame,shift1+22);
   	double minus22CandleOpen = iOpen(NULL,TimeFrame,shift1+22);

   	double minus23CandleLow = iLow(NULL,TimeFrame,shift1+23);
   	double minus23CandleHigh = iHigh(NULL,TimeFrame,shift1+23);
   	double minus23CandleClose = iClose(NULL,TimeFrame,shift1+23);
   	double minus23CandleOpen = iOpen(NULL,TimeFrame,shift1+23);

   	double minus24CandleLow = iLow(NULL,TimeFrame,shift1+24);
   	double minus24CandleHigh = iHigh(NULL,TimeFrame,shift1+24);
   	double minus24CandleClose = iClose(NULL,TimeFrame,shift1+24);
   	double minus24CandleOpen = iOpen(NULL,TimeFrame,shift1+24);

   	double minus25CandleLow = iLow(NULL,TimeFrame,shift1+25);
   	double minus25CandleHigh = iHigh(NULL,TimeFrame,shift1+25);
   	double minus25CandleClose = iClose(NULL,TimeFrame,shift1+25);
   	double minus25CandleOpen = iOpen(NULL,TimeFrame,shift1+25);
                
//***************** BEGIN VSI ENGINE ******************//			
      int arbitraryLimit = 21; //sub this for Bars
      for(int k = arbitraryLimit; k >= 0; k--)  
      {
            //Difference between the current time and the bar start
            timeDiff = CurTime() - Time[k];

            //If we are in the current bar and the tick doesn't fall exactly on the '00:00' min & sec
            if(k == 0 && timeDiff > 0) {
               vsiBuffer[k] = Volume[k] / timeDiff;
            } else {
               //Otherwise calculate the total bar volume divided by the total bar seconds
               vsiBuffer[k] = Volume[k] / (Time[k - 1] - Time[k]);
            }

            if(showPerPeriod == 1) {
               vsiBuffer[k] = vsiBuffer[k] * Period() * SECINMIN;
            }
            
            vsiMABuffer[k] = iMAOnArray(vsiBuffer, arbitraryLimit, vsiMAPeriod, 0, vsiMAType, k);
       }     
//***************** END VSI ENGINE ******************//

      RefreshBidsAndAsks();

//***************** CREATE INDICATOR VALUES ******************//
				
				//160 EMA
				double hourlyEma160Minus1Candle = iMA(Sym,PERIOD_H1,160,0,MODE_EMA,PRICE_TYPICAL,hourlyShift+1);
				double fiveMinEma160Minus1Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+1);				
				double fourHourEma160Minus1Candle = iMA(Sym,PERIOD_H4,160,0,MODE_EMA,PRICE_TYPICAL,fourHourlyShift+1);	
				
				double fiveMinuteEma160Minus1Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double fiveMinuteEma160Minus2Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+2);
				double fiveMinuteEma160Minus3Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+3);
				double fiveMinuteEma160Minus4Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+4);
				double fiveMinuteEma160Minus5Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+5);
				double fiveMinuteEma160Minus6Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+6);
				double fiveMinuteEma160Minus7Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+7);
				double fiveMinuteEma160Minus8Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+8);
				double fiveMinuteEma160Minus9Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+9);
				double fiveMinuteEma160Minus10Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+10);
				double fiveMinuteEma160Minus11Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+11);
				double fiveMinuteEma160Minus12Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+12);
				double fiveMinuteEma160Minus13Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+13);
				double fiveMinuteEma160Minus14Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+14);
				
				//34 EMA 
				double hourlyEma34Minus1Candle = iMA(Sym,PERIOD_H1,34,0,MODE_EMA,PRICE_TYPICAL,hourlyShift+1);
				double fiveMinEma34Minus1Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+1);				
				double fiveMinEma34Minus2Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+2);	
				double fiveMinEma34Minus3Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+3);	
				double fiveMinEma34Minus4Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+4);	
				double fiveMinEma34Minus5Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+5);	
				double fiveMinEma34Minus6Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+6);	
				double fiveMinEma34Minus7Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+7);	
				double fiveMinEma34Minus8Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+8);	
				
				double fourHourEma34Minus1Candle = iMA(Sym,PERIOD_H4,34,0,MODE_EMA,PRICE_TYPICAL,fourHourlyShift+1);
				
         	//larger timeframe candles
         	double fiveMinMinus1CandleClose = iClose(NULL,PERIOD_M5, shift1 + 1 );
         	double hourlyMinus1CandleClose = iClose(NULL,PERIOD_H1, hourlyShift + 1 );
         	double fourHourlyMinus1CandleClose = iClose(NULL,PERIOD_H4, fourHourlyShift + 1 );

//***************** BEGIN ENTRY LOGIC ******************//      

			if(	//does price cross above and test the 160 EMA?
						//do the larger timeframes close above the 160 EMA?
						//if yes, support (demand) is at this price
						minus1CandleClose > fiveMinuteEma160Minus1Candle 
						&& minus2CandleLow < fiveMinuteEma160Minus2Candle 
						//&& fiveMinMinus1CandleClose > fiveMinEma160Minus1Candle			
						&& hourlyMinus1CandleClose > hourlyEma160Minus1Candle
						&& fourHourlyMinus1CandleClose > fourHourEma160Minus1Candle	
				
						//&& hourlyMinus1CandleClose > hourlyEma34Minus1Candle
						//&& fourHourlyMinus1CandleClose > fourHourEma34Minus1Candle	
								
						
				)
				{
      			_WEAPON_ARMED = true;
      			_targetAcquisitionTime = Time[i+1];
      			_targetAcquisitionOpen = minus1CandleOpen;
					_targetAcquisitionHigh = minus1CandleHigh;
					_targetAcquisitionLow = minus1CandleLow;
					_targetAcquisitionClose = minus1CandleClose;
      			ObjectCreate("targetAcquiredbuy"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
         		ObjectSetText("targetAcquiredbuy"+_labelIndex,"Z",12,"Arial",Yellow);
				}
      
      
      //TO DO:
      //now that you have an entry targeted, pretend you are the MM want to run some stops
      //the only way to really make this sucker rise is to run stops and hold onto some loss short term 
      //so we need to let prices rise up around 10 pips then let them return to our level before entering.
      
      if (  
						_WEAPON_ARMED == true
						&& Time[i+1] > _targetAcquisitionTime //time must have passed so a retest can occur
						&& minus1CandleClose > _targetAcquisitionClose //price must be higher than target acquire
						&& minus1CandleClose > fiveMinEma34Minus1Candle
						&& minus2CandleClose > fiveMinEma34Minus2Candle
						&& minus3CandleClose > fiveMinEma34Minus3Candle
						&& minus4CandleClose > fiveMinEma34Minus4Candle
						&& minus5CandleClose > fiveMinEma34Minus5Candle
						&& minus6CandleClose > fiveMinEma34Minus6Candle
						&& minus7CandleClose > fiveMinEma34Minus7Candle
           )
		{
			ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],open);
			ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
			ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);

         Print("attempting to buy at ", _ask, " i is ", i, " and OrdersTotal=", OrdersTotal());
      
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
               	_WEAPON_ARMED = false;
               	
                  //mod ticket
                  _TP=_bid+_takeProfitFactor*(10*_point);
                  _SL=_bid-_stopLossFactor*(10*_point);
                  _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                  _entryPrice = minus1CandleClose;
                  Print("entry price is: " + _entryPrice);
                  Print("OrderModify on a buy last called. Last error was: ",GetLastError());
               }           
            }                                             
         }
                    
      }
      else if (  1==9
            )
      {


                  ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i],open);
                  ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);   

               
                  //--------SELL ORDER---------//
                  if(i==0)//only trade current candle
                  {     
                     if (OrdersTotal() == 0)//open new order because one isn't open
                     {
                     	_entryPrice = _bid;
                        _ticketNumber = OrderSend(Sym,OP_SELL,0.1,_bid,3,0,0,"order #" + _labelIndex,0,0,Red);               
                        if(_ticketNumber<0)
                        {
                           Print("OrderSend on a sell failed with error #",GetLastError());
                        }
                        else
                        {
                           //mod ticket
                           _TP=_bid+_takeProfitFactor*(10*_point);
                           _SL=_bid-_stopLossFactor*(10*_point);
                           _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                           
                           Print("entry price is: " + _entryPrice);
                           Print("OrderModify on a buy last called. Last error was: ",GetLastError());
                        }
                     }
                  }
                    
      }
      //***************** END TARGET ACQUISITION AND ENTRY ******************// 
      
      /*------- BEGIN MONEY MANAGEMENT -------- */
      //N pips advance - tighten up the SL
         if (
      minus1CandleClose >= (_entryPrice + 10*(_point*10))
      && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 2*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }  
      
      /*
     if (
      minus1CandleClose >= (_entryPrice + 15*(_point*10))
      && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 5*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }
      
      
     if (
            minus1CandleClose >= (_entryPrice + 20*(_point*10))
            && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 10*(_point*10), 4);
        //_TP = NormalizeDouble(_entryPrice + 60*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }
      
         if (
            minus1CandleClose >= (_entryPrice + 30*(_point*10))
            && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 20*(_point*10), 4);
        //_TP = NormalizeDouble(_entryPrice + 60*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }  

         if (
            minus1CandleClose >= (_entryPrice + 35*(_point*10))
            && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 25*(_point*10), 4);
        //_TP = NormalizeDouble(_entryPrice + 60*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }  
      */
            
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


int recentStandardDeviationCrossing(int pLookback, int pMaPeriod, double pLevel, int pIndex)
{
   int counter = 0;

   if (  iStdDev(NULL, 5, pMaPeriod, 0, MODE_SMA, PRICE_CLOSE, pIndex) >= pLevel  ) //is latest price above
   {
      for (int z=2;z<=pLookback;z++)
      { 
         if (iStdDev(NULL, 5, pMaPeriod, 0, MODE_SMA, PRICE_CLOSE, z+pIndex) <= pLevel) //was recent price below
         {
            counter = 1;
            break;
         }
      }
   }
   else
   {
      return (0);
   }


   if (counter > 0)
   {
      return (1);
   }
   else
   {
      return (0);
   }
}

int candleSpreadGreaterThanNPips(double pHigh, double pLow, int pSpread)
{
   double spread1 = MathAbs(pHigh - pLow); //removes negative number
   
   if (pSpread > spread1)
   {
      return (1);
   }
   else
   {
      return (0);
   }
}

int lastLowInOpenAir(double priceToTest, int pLookback, int pIndex)
{

   int counter = 0;
   //start at 2 because we are always passing in the +1 candle
   for (int z=2;z<=pLookback;z++)
   {                
      if (priceToTest >= iLow(NULL,5,z+pIndex))
      {    
         ObjectCreate("buysellMissedOpp"+_labelIndex,OBJ_TEXT,0,Time[z+pIndex],priceToTest);
         ObjectSetText("buysellMissedOpp"+_labelIndex,"x",14,"Arial",Aqua); 
       
         counter = 1;
         break;
      }
   }
   
   if (counter > 0)
   {
      return (0);
   }
   else
   {
      return (1);
   }
}

int lastHighInOpenAir(double priceToTest, int pLookback, int pIndex)
{
   int counter = 0;
   //start at 2 because we are always passing in the +1 candle
   for (int z=2;z<=pLookback;z++)
   {  
      if (priceToTest <= iHigh(NULL,5,z+pIndex))
      {
      
         ObjectCreate("buysellMissedOpp"+_labelIndex,OBJ_TEXT,0,Time[z+pIndex],priceToTest);
         ObjectSetText("buysellMissedOpp"+_labelIndex,"x",14,"Arial",Orange); 
         
         counter = 1;
         break;
      }
   }
   
   if (counter > 0)
   {
      return (0);
   }
   else
   {
      return (1);
   }
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

