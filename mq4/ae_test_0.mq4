/*
   this is an EA based on v6
   do not delete, refactor and test in real time

*/


#define    SECINMIN         60  //Number of seconds in a minute

extern int  TimeFrame		= 5;

extern int vsiMAPeriod    = 21;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */

double vsiBuffer[999999];

string Sym = "";

string _labelName1 = "volumeArrow";
string _labelName2 = "hhll_";

string _previousLabel = "";
int _hhIndex = 1;
int _llIndex = 1;

//this gets filled with the last 3 candles' pattern and checked and wiped every candle.
//for example, if it says X|upH|up then we had a volume reversal followed by some kind of higher high, followed by an up volume bull
//the order is minus1Candle, minus2Candle, minus3Candle, etc.

string _lookbackSignalPattern[3] = { "xx", "xx", "xx" }; 

//this is used for tidying up the chart at each new candle
datetime _lastAlertTime;
int _labelIndex = 0;
int _ticketNumber;
bool _modifyOrder = false;
bool _pendingOrder = false;

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
bool _testRunOnce = false;

int start()
{
	int timeDiff;
	int limit;
			
	if (_lastAlertTime < Time[0] || _firstRun == false) //a candle just opened
   {
      _firstRun = true;
      _lastAlertTime = Time[0];
      cleanUpChart();
      
      _labelIndex = 0;
  
         for(int i = Bars; i >= 0; i--)
         {
      
            //declarations
		      int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
			        time1  = iTime    (NULL,TimeFrame,shift1);
			        
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
      
            string _minus1PriceAttributes = "";
            string _minus2PriceAttributes = "";
            string _minus3PriceAttributes = "";		
            string _minus4PriceAttributes = "";	
         
//***************** BEGIN VSI ENGINE ******************//			  
            //Difference between the current time and the bar start
            timeDiff = CurTime() - Time[i];

            //If we are in the current bar and the tick doesn't fall exactly on the '00:00' min & sec
            if(i == 0 && timeDiff > 0) {
               vsiBuffer[i] = Volume[i] / timeDiff;
            } else {
               //Otherwise calculate the total bar volume divided by the total bar seconds
               vsiBuffer[i] = Volume[i] / (Time[i - 1] - Time[i]);
            }

            if(showPerPeriod == 1) {
               vsiBuffer[i] = vsiBuffer[i] * Period() * SECINMIN;
            }
//***************** END VSI ENGINE ******************//

            
//***************** BEGIN HH/LL DATA CAPTURE ******************//
            
  
            /*
            * MINUS 1 CANDLE PRICE ATTRIBUTES
            */
		
	          //HIGHS AND LOWS
	          //higher minus1CandleHigh "hh"
	          if (minus1CandleHigh > minus2CandleHigh)
	          {
                _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"hh|");
	          }
	
	          //lower minus1CandleHigh "lh"
	          if (minus1CandleHigh < minus2CandleHigh)
	          {
                _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"lh|");
	          }
	
	          //lower minus1CandleLow "ll"
	          if (minus1CandleLow < minus2CandleLow)
	          {
                _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"ll|");
	          }
	
	          //higher minus1CandleLow "hl"
	          if (minus1CandleLow > minus2CandleLow)
	          {
                _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"hl|");
	          }
			
	          //same minus1CandleHigh "sh"
	          if (minus1CandleHigh == minus2CandleHigh)
	          {
                _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"sh|");
	          }
	
	          //same minus1CandleLow "sl"
	          if (minus1CandleLow == minus2CandleLow)
	          {
                _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"sl|");
	          }
	             
            /*
            * MINUS 2 CANDLE PRICE ATTRIBUTES
            */

		
            //HIGHS AND LOWS
            //higher minus2CandleHigh "hh"
            if (minus2CandleHigh > minus3CandleHigh)
            {
               _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"hh|");
            }

            //lower minus2CandleHigh "lh"
            if (minus2CandleHigh < minus3CandleHigh)
            {
               _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"lh|");
            }

            //lower minus2CandleLow "ll"
            if (minus2CandleLow < minus3CandleLow)
            {
               _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"ll|");
            }

            //higher minus2CandleLow "hl"
            if (minus2CandleLow > minus3CandleLow)
            {
               _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"hl|");
            }
	
            //same minus2CandleHigh "sh"
            if (minus2CandleHigh == minus3CandleHigh)
            {
               _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"sh|");
            }

            //same minus2CandleLow "sl"
            if (minus2CandleLow == minus3CandleLow)
            {
               _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"sl|");
            }
            
            /*
            * MINUS 3 CANDLE PRICE ATTRIBUTES
            */
		
            //HIGHS AND LOWS
            //higher minus3CandleHigh "hh"
            if (minus3CandleHigh > minus4CandleHigh)
            {
               _minus3PriceAttributes = StringConcatenate(_minus3PriceAttributes,"hh|");
            }

            //lower minus3CandleHigh "lh"
            if (minus3CandleHigh < minus4CandleHigh)
            {
               _minus3PriceAttributes = StringConcatenate(_minus3PriceAttributes,"lh|");
            }

            //lower minus3CandleLow "ll"
            if (minus3CandleLow < minus4CandleLow)
            {
               _minus3PriceAttributes = StringConcatenate(_minus3PriceAttributes,"ll|");
            }

            //higher minus3CandleLow "hl"
            if (minus3CandleLow > minus4CandleLow)
            {
               _minus3PriceAttributes = StringConcatenate(_minus3PriceAttributes,"hl|");
            }
	
            //same minus3CandleHigh "sh"
            if (minus3CandleHigh == minus4CandleHigh)
            {
               _minus3PriceAttributes = StringConcatenate(_minus3PriceAttributes,"sh|");
            }

            //same minus3CandleLow "sl"
            if (minus3CandleLow == minus4CandleLow)
            {
               _minus3PriceAttributes = StringConcatenate(_minus3PriceAttributes,"sl|");
            }
                        
//***************** END HH/LL DATA CAPTURE ******************//		       
		       
		double minus1Volume = vsiBuffer[shift1+1];
      double minus2Volume = vsiBuffer[shift1+2];

      double _volumeLimit = 0.95;
      int _lineLength = 50;
      color _tmpColor = Orange; 
      
      string _candleLookback = "";
      
      /*
         pseudo rules:
         - if candle 1 and 2 are both same direction, and volume is up, paint a directional arrow (prices may surge)
         - if previous candle is different direction than latest closed candle, paint a stop sign (prices may reverse)
      */

      if (  minus1Volume >= _volumeLimit
            && minus2Volume >= _volumeLimit
         )
         { 
            if (
               minus1CandleOpen < minus1CandleClose
               && minus2CandleOpen < minus2CandleClose
            )
            {
               //bullish volume
               ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleLow);
               ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
               ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Green);
               
               //build up a record for the candle
               _candleLookback = StringConcatenate(_candleLookback, "up");
            }
            else if (
               minus1CandleOpen > minus1CandleClose
               && minus2CandleOpen > minus2CandleClose
            )
            {
               //bearish volume
               ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleHigh);
               ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
               ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Red);
               
               //build up a record for the candle
               _candleLookback = StringConcatenate(_candleLookback, "down");       
            }
            //reversal imminent
            else if ( 
               minus1CandleOpen > minus1CandleClose 
               && minus2CandleOpen < minus2CandleClose
            )
            {
               //bear following a bull
               ObjectCreate (_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleHigh);
               ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
               ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Orange);   
               
               //build up a record for the candle
               _candleLookback = StringConcatenate(_candleLookback, "x");     
                      
            }
            else if (
               minus1CandleOpen < minus1CandleClose
               && minus2CandleOpen > minus2CandleClose
            )
            {
               //bull following a bear
               ObjectCreate (_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleLow);
               ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
               ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Orange);    
               
               //build up a record for the candle
               _candleLookback = StringConcatenate(_candleLookback, "x");            
            }
         }  
         
      ///BEGIN MARKUP OF HH/LL
         
     if (StringFind(_minus1PriceAttributes, "hh|", 0) > -1)//higher high
     {
        if (StringFind(_minus2PriceAttributes, "lh|", 0) > -1)//lower high 
        {
           //in a pullback during a bull trend, this is a buy signal

           //check what previous label was
           if ( _previousLabel == "HH" )
           {
               _hhIndex += 1;
           }
           else if ( _previousLabel == "LL" )
           {
               _hhIndex = 1;
           }
              
           ObjectCreate(_labelName2+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
         
            _tmpColor = Green;           
            if (  minus1Volume < _volumeLimit && minus2Volume < _volumeLimit ){  _tmpColor = LightGray;}
            ObjectSetText(_labelName2+_labelIndex,"H"+_hhIndex,7,"Arial",_tmpColor);
               
           _previousLabel = "HH";
           
           //build up a record for the candle
           _candleLookback = StringConcatenate(_candleLookback, "hh");     
        }
     }
     else if(StringFind(_minus1PriceAttributes, "ll|", 0) > -1)//lower low
     {
        if (StringFind(_minus2PriceAttributes, "hl|", 0) > -1)//higher low
        {
           //in a pullback during a bear trend, this is a sell signal

           //check what previous label was
           if ( _previousLabel == "LL" )
           {
               _llIndex += 1;
           }
           else if ( _previousLabel == "HH" )
           {
               _llIndex = 1;
           }           
                                            
           ObjectCreate(_labelName2+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleHigh+((Point*10)*2));

            _tmpColor = Red;           
            if (  minus1Volume < _volumeLimit && minus2Volume < _volumeLimit ){  _tmpColor = LightGray;}
            ObjectSetText(_labelName2+_labelIndex,"L"+_llIndex,7,"Arial",_tmpColor);
            
           _previousLabel = "LL";
           
           //build up a record for the candle
           _candleLookback = StringConcatenate(_candleLookback, "ll");
        }
     }

//***************** BEGIN LOOKBACK PATTERN SETUP ******************//
      //shuffle the _lookbackSignalPattern so that the oldest candle is first, reading right to left
      _lookbackSignalPattern[0] = _lookbackSignalPattern[1];
      _lookbackSignalPattern[1] = _lookbackSignalPattern[2];
      _lookbackSignalPattern[2] = _candleLookback;
      
      //pseudo code:
      //if _lookbackSignalPattern = "a match" then
      //paint a price label and 
      //set up an order
      //_signalPattern is oldest candle to newest
      string _signalPattern = _lookbackSignalPattern[0] + "|" + _lookbackSignalPattern[1] + "|" + _lookbackSignalPattern[2];

//***************** END LOOKBACK PATTERN SETUP ******************//

      int _distSL = 15;                             // Preset SL (pt)
      int _distTP = 25;                              // Preset TP (pt)
      double _bid   =MarketInfo(Sym,MODE_BID); // Request for the value of Bid
      double _ask   =MarketInfo(Sym,MODE_ASK); // Request for the value of Ask
      double _point =MarketInfo(Sym,MODE_POINT);//Request for Point   
      double _minDist=MarketInfo(Sym,MODE_STOPLEVEL);// Min. distance
      
      if (_distSL < _minDist)                   // If it is less than allowed
        {
         _distSL=_minDist;                      // Set the allowed
         //Alert(" Increased the distance of SL = ",_distSL," pt");
        }
      double _SL=_bid - _distSL*(10*_point);            // Requested price of SL
      //--------------------------------------------------------------------
      if (_distTP < _minDist)                   // If it is less than allowed
        {
         _distTP=_minDist;                      // Set the allowed
         //Alert(" Increased the distance of TP = ",_distTP," pt");
        }
      //double _TP=_bid + _distTP*(10*_point);            // Requested price of TP
        
      if(
         _signalPattern == "x|uphh|up"
        // i < 1
         )
      {
            //refactor this
            ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],open);
            ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
            ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);
            
            if(i == 0)
            {
               _ticketNumber = OrderSend(Sym,OP_BUY,0.1,_ask,3,0,0,"order #" + _labelIndex,0,0,Green);     
               if(_ticketNumber<0)
               {
                  Print("OrderSend failed with error #",GetLastError());
               }
               else
               {
                  //mod ticket
                  _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _bid-10*(10*_point),_bid+22*(10*_point), 0);
                  Print("OrderModify last called. Last error was: ",GetLastError());
               }
            }   
      }
      else if ( _signalPattern == "x|downll|down" )
      {
            ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i],open);
            ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
            ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);       
            if(i==0)
            {     
               _ticketNumber = OrderSend(Sym,OP_SELL,0.1,_bid,3,0,0,"order #" + _labelIndex,0,0,Red);
               
               if(_ticketNumber<0)
               {
                  Print("OrderSend failed with error #",GetLastError());
               }
               else
               {
                  //mod ticket
                  _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _ask-10*(10*_point),_ask+22*(10*_point),0 );           
                  Print("OrderModify last called. Last error was: ",GetLastError());
               }
            }   
      }
            //last thing you do is update the index
            _labelIndex++;
        }
 
   }

	return(0);
}

