/*
identify 50-100 pip moves intraday
take a reading based on an averages of N candles
readings consist of:
   bollinger band
   macd 14/34/21 and 80/160/21
   volume
   7 EMA, 8 EMA, 21 EMA, 34 EMA
   RSI
   CCI
   
opening price algorithm:
   After one hour of trading, if the current price is below the open, look to sell short, or
   if the current price is above the open, look to buy long
   use the candle price harvester code as a base.

Make these modular toggle-able so we can test them out one at a time.
*/

//arlo emerson - 8/23/2012


//globally adjust tp/sl
double _stopLossFactor = 10;
double _takeProfitFactor = 100;

bool _entryCueMatchFound = false; //set to true when we match a time in the entryCue list
string _entryCueDirection = "";
double _openingPriceOpen;
double _openingPriceClose;
double _openingPriceHigh;
double _openingPriceLow;
string _openingPriceIndicator;
int _lookback = 12;
string _val_macdAVG143421;
string _val_macdAVG8016021;
string _val_EMA_a;
string _val_EMA_b;
string _val_StdDev_a;
string _val_Volume_a;
string _val_Volume_b;

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
double vsiMABuffer[999999];
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


string _signalMatrix[28][11] = {
"1/19/2011","buy","above","above","below","above","above","below","above","above","",
"1/19/2011","buy","above","above","below","above","above","below","above","above","",
"1/19/2011","buy","above","above","below","above","above","above","above","above","",
"1/19/2011","buy","above","above","below","above","above","above","above","above","",
"1/19/2011","buy","above","above","above","above","below","above","above","","",
"1/25/2011","buy","below","above","below","below","above","above","above","","",
"1/25/2011","buy","below","above","below","below","below","above","above","","",
"1/25/2011","buy","above","below","below","above","below","above","above","above","above",
"1/25/2011","buy","above","below","below","below","above","above","above","above",
"1/25/2011","buy","above","below","below","above","below","above","above","above","above",
"1/25/2011","buy","above","below","below","above","below","above","above","above","above",
"1/25/2011","buy","above","below","below","above","above","above","above","above","",
"1/25/2011","buy","above","below","below","above","above","above","above","above","",
"1/25/2011","buy","above","below","below","above","above","above","above","above","",
"1/25/2011","buy","above","below","below","above","above","above","above","above","",
"1/25/2011","buy","above","below","above","above","above","above","above","",
"5/25/2012","buy","below","above","below","below","above","above","above","above","",
"5/25/2012","buy","below","above","below","above","below","above","above","above","",
"5/25/2012","buy","below","above","below","above","below","above","above","above","above",
"5/25/2012","buy","below","above","below","above","below","above","above","above","above",
"5/25/2012","buy","below","above","below","above","below","above","above","above","above",
"5/25/2012","buy","below","above","below","above","below","above","above","above","",
"7/17/2012","buy","below","above","below","above","below","above","below","above","above",
"7/17/2012","buy","below","above","below","above","below","above","below","above","above",
"7/17/2012","buy","below","above","below","above","below","above","below","below","above",
"7/17/2012","buy","below","above","below","above","below","above","below","above","above",
"7/17/2012","buy","below","above","below","above","below","above","below","above","above",
"7/17/2012","buy","below","above","below","above","below","above","below","above","above"
};



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
	        
	   double	high		= iHigh(NULL,TimeFrame,shift1),
			low		= iLow(NULL,TimeFrame,shift1),
			open		= iOpen(NULL,TimeFrame,shift1),
			close		= iClose(NULL,TimeFrame,shift1),
	 		bodyHigh	= MathMax(open,close),
			bodyLow	= MathMin(open,close);
			
           double minus1_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+1);
            double minus2_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+2);
            double minus3_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+3);
            double minus4_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+4);
            double minus5_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+5);
            double minus6_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+6);
            double minus7_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+7);
            double minus8_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+8);
            double minus9_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+9);
            double minus10_143421MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+10);
            double macdAVG143421 = (minus1_143421MACD + minus2_143421MACD + minus3_143421MACD + minus4_143421MACD + minus5_143421MACD + minus6_143421MACD + minus7_143421MACD)/7;
      
            double minus1_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+1);
            double minus2_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+2);
            double minus3_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+3);
            double minus4_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+4);
            double minus5_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+5);
            double minus6_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+6);
            double minus7_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+7);
            double minus8_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+8);
            double minus9_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+9);
            double minus10_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+10);
            double minus11_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+11);
            double minus12_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+12);
            double minus13_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+13);
            double minus14_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+14);
            double minus15_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+15);
            double minus16_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+16);
            double minus17_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+17);
            double minus18_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+18);
            double minus19_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+19);
            double minus20_8016021MACD = iMACD(NULL,TimeFrame,80,160,21,PRICE_CLOSE,MODE_MAIN,shift1+20);
      
            double macdAVG8016021 = (minus1_8016021MACD + minus2_8016021MACD + minus3_8016021MACD +
            minus4_8016021MACD + minus5_8016021MACD + minus6_8016021MACD +
            minus7_8016021MACD + minus8_8016021MACD + minus9_8016021MACD +
            minus10_8016021MACD + minus11_8016021MACD + minus12_8016021MACD +
            minus13_8016021MACD + minus14_8016021MACD + minus15_8016021MACD +
            minus16_8016021MACD + minus17_8016021MACD + minus18_8016021MACD +
            minus19_8016021MACD + minus20_8016021MACD)/20;


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
      string _minus1PriceAttributes = "";
      string _minus2PriceAttributes = "";
      string _minus3PriceAttributes = "";		
      string _minus4PriceAttributes = "";	
         
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
      double minus3Volume = vsiBuffer[shift1+3];

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
      //_signalPattern is oldest candle to newest, L TO R
      string _signalPattern = _lookbackSignalPattern[0] + "|" + _lookbackSignalPattern[1] + "|" + _lookbackSignalPattern[2];

//***************** END LOOKBACK PATTERN SETUP ******************//

      RefreshBidsAndAsks();

      
//***************** CREATE INDICATOR VALUES ******************//
      
		int minus1Hour = TimeHour(Time[i+1]);
		int minus1Minute = TimeMinute(Time[i+1]);

            //---------------------- BEGIN OPENING PRICE INDICATOR ---------------------//            
            
               if(
                  minus1Hour == 0
                  && minus1Minute == 5
                  )
                  {               
                     _openingPriceOpen = minus1CandleOpen;
                     _openingPriceClose = minus1CandleClose;
                     _openingPriceHigh = minus1CandleHigh;
                     _openingPriceLow = minus1CandleLow;
                  }
               
               if(
                  minus1Hour == 1
                  && minus1Minute == 5
                  )
                  {    
                     if (minus1CandleClose >= _openingPriceHigh)
                     {
                        ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleLow);
                        ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
                        ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Green);
                        _openingPriceIndicator = "buy";                        
                     }
                     else if (minus1CandleClose <= _openingPriceLow)   
                     {
                        ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleHigh);
                        ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
                        ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Red);
                        _openingPriceIndicator = "sell";
                     }
                  } 
            
               Print("========================opening price indicator " + _openingPriceIndicator);
		      //---------------------- END OPENING PRICE INDICATOR ---------------------//

		          //------- MACD - 2 --------//
		          if (macdAVG143421 > 0)
		          {
		             _val_macdAVG143421 = "above";
		          }
		          else if (macdAVG143421 < 0)
		          {
		             _val_macdAVG143421 = "below";
		          }
		          else
		          {
		             _val_macdAVG143421 = "-";
		          }
		          
		          //------- MACD - 3 --------//
		          if (macdAVG8016021 > 0)
		          {
		             _val_macdAVG8016021 = "above";
		          }
		          else if (macdAVG8016021 < 0)
		          {
		             _val_macdAVG8016021 = "below";
		          }
		          else
		          {
		             _val_macdAVG8016021 = "-";
		          }
		          	
		      	 //------- EMA - 4 --------//
		          if ( iMA(Sym, TimeFrame, 2, TimeFrame, MODE_EMA, PRICE_LOW, i+_lookback ) < iMA(Sym, TimeFrame, 12, TimeFrame, MODE_EMA, PRICE_TYPICAL, i+_lookback ))
		          {
		             _val_EMA_a = "below";
		          }
		          else if ( iMA(Sym, TimeFrame, 2, TimeFrame, MODE_EMA, PRICE_HIGH, i+_lookback ) > iMA(Sym, TimeFrame, 12, TimeFrame, MODE_EMA, PRICE_TYPICAL, i+_lookback ))
		          {
		              _val_EMA_a = "above";
		          } 
		          else
		          {
		             _val_EMA_a = "-";
		          }   	
		          			          	
			       //------- EMA - 5 --------//
		          if ( minus12CandleLow < iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, i+_lookback ))
		          {
		             _val_EMA_b = "below";
		          }
		          else if ( minus12CandleHigh > iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, i+_lookback ))
		          {
		              _val_EMA_b = "above";
		          }
		          else
		          {
		             _val_EMA_b = "-";
		          }
		             
		          //------- Standard Deviation - 6 --------//
		          if (iStdDev(NULL, 5, 7, 0, MODE_SMA, PRICE_CLOSE, i+_lookback) < 0.0003)
		          {
		             _val_StdDev_a = "below";
		          }
		          else if (iStdDev(NULL, 5, 7, 0, MODE_SMA, PRICE_CLOSE, i+_lookback) > 0.0003)
		          {
		             _val_StdDev_a = "above";
		          }
		          else
		          {
		             _val_StdDev_a = "-";
		          }
		          
		          //------- Specific Volume - 7 --------//
		          if (vsiBuffer[i+_lookback] < 1)
		          {
		             _val_Volume_a = "below";
		          }
		          else if (vsiBuffer[i+_lookback] > 1)
		          {
		              _val_Volume_a = "above";
		          }
		          else
		          {
		           _val_Volume_a = "-";
		          }
		          
		          //------- MA Volume - 8 --------//
		          if (vsiMABuffer[i+_lookback] < 1)
		          {
		             _val_Volume_b = "below";
		          }
		          else if (vsiMABuffer[i+_lookback] > 1)
		          {
		             _val_Volume_b = "above";
		          }	
		          else
		          {
		             _val_Volume_b = "-";
		          }	          		          		          	                         


      
//***************** END ******************//
    
//***************** LOOP DATA SET TO FIND MATCHES ******************//    
    
     Print(_openingPriceIndicator  + ", " + _val_macdAVG143421 + ", " + _val_macdAVG8016021  + ", " + _val_EMA_a + ", " +  _val_EMA_b + ", " + _val_StdDev_a + ", " + _val_Volume_a + ", " + _val_Volume_b);
     
    int entryCuesSize=ArrayRange(_signalMatrix, 0);
    
      for(int z = 0; z<entryCuesSize; z++)
      {
		    if (
			    _val_macdAVG143421 ==  _signalMatrix[z][2]
			    && _val_macdAVG8016021 ==  _signalMatrix[z][3]
			    && _val_EMA_a ==  _signalMatrix[z][4]
			    && _val_EMA_b ==  _signalMatrix[z][5]
			    && _val_StdDev_a ==  _signalMatrix[z][6]
			    && _val_Volume_a ==  _signalMatrix[z][7]
			    && _val_Volume_b ==  _signalMatrix[z][8]
			    )
			    {
			       _entryCueMatchFound = true;
			       break;
		       }      
      }
    
//***************** END ******************//    
      
//***************** BEGIN TARGET ACQUISITION AND ENTRY ******************//      
      if ( 
            _entryCueMatchFound == true
            && _openingPriceIndicator == "buy" //currently restricting to buy patterns
            )
      {

                  _entryCueMatchFound = false;
                  _entryCueDirection = "";

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
      //***************** END TARGET ACQUISITION AND ENTRY ******************// 


            
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

