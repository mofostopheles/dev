/*
  
   this script places a lot of markers during the off hours, i.e. the "flat spot" corresponding with non-London/NY overlap
   TODO: this is useful, so determine if we can gauge the sentiment of the following day, or at least the next major move.
   try counting up and down candles during the off peak volume anomolies

   author:  Arlo Emerson
   date:    8/7/2012
*/

#property indicator_separate_window
//#property indicator_minimum -6000
#property indicator_buffers 2

#property indicator_level1 1

#property indicator_color1  DodgerBlue
#property indicator_color2  Red
#property indicator_color3  White

#define    SECINMIN         60  //Number of seconds in a minute

string vsiTitle = "double the volume v.3";

extern int  TimeFrame		= 5;

extern int vsiMAPeriod    = 7;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */
double vsiBuffer[];
double vsiMABuffer[];
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

bool _firstRun = false; //when script first loads, paint all the historical arrows if false

bool _signalFired = false;
string _signalDirection = "";
string _tradeDirection = "";
bool _inTrade = false;

//for simulated order P&L
double _stopLoss; 
double _takeProfit;

//globally adjust tp/sl
double _stopLossFactor = 12;
double _takeProfitFactor = 50;

double _oscillatorOfStrength = 0.0;
int _lookbackLength = 12; //arbitrary limit to number of blue x's mark up the non-peak hours
double _lookbackVolumePattern[]; 
double strengthBuffer[];
double _averagePriceForSpikeZone;
int spikesCounted = 0;
double priceCollector = 0.0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   //populate the volume lookback array
   for (int z=0;z<_lookbackLength;z++)
   {
      _lookbackVolumePattern[z] = 0;
   }

   _lastAlertTime = TimeCurrent();


   Sym = Symbol();
   
   SetIndexStyle(0,DRAW_HISTOGRAM,1,4);
   SetIndexStyle(1,DRAW_LINE,1,2);
   SetIndexStyle(2,DRAW_LINE,1,1);
   
   SetIndexBuffer(0, vsiBuffer);
   SetIndexBuffer(1, vsiMABuffer);
   //SetIndexBuffer(2, strengthBuffer);
   
   IndicatorShortName(vsiTitle);
   
   SetIndexLabel(0, vsiTitle);
   SetIndexLabel(1, "vsiMA(" + vsiMAPeriod + ")");
   
   SetIndexDrawBegin(1, vsiMAPeriod);

	//ObjectsDeleteAll();
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
         else if (StringFind(on, "buy", 0) > -1)
         {
            ObjectDelete(on);
         }
         else if (StringFind(on, "sell", 0) > -1)
         {
            ObjectDelete(on);
         }
   }
  
   return(0);
}

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
         //for(int i = Bars-1-IndicatorCounted(); i >= 0; i--)
         for(int i = Bars; i >= 0; i--)
         //for(int i = 0; i < Bars; i++)//repaint newest to oldest
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

            double minus1MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+1);
            double minus2MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+2);
            double minus3MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+3);
            double minus4MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+4);
            double minus5MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+5);
            double minus6MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+6);
            double minus7MACD = iMACD(NULL,TimeFrame,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+7);
            
            double minus1_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+1 );
            double minus1_34EmaLow = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, shift1+1 );
            double minus1_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+1 );            
            
            double minus2_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+2 );
            double minus2_34EmaLow = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, shift1+2 );
            double minus2_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+2 );
            
            double minus3_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+3 );
            double minus3_34EmaLow = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, shift1+3 );
            double minus3_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+3 );
            
            double minus4_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+4 );
            double minus4_34EmaLow = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, shift1+4 );
            double minus4_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+4 );
            
            
            double minus5_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+5 );
            double minus5_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+5 );
            
            
            double minus6_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+6 );
            double minus6_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+6 );
            
            
            double minus7_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+7 );
            double minus7_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+7 );
            
            double minus8_34EmaHigh = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, shift1+8 );
            double minus8_34EmaClose = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, shift1+8 );
            
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

            vsiMABuffer[i] = iMAOnArray(vsiBuffer, Bars, vsiMAPeriod, 0, vsiMAType, i);
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
            //   ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleLow);
             //  ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
            //   ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Green);
               
               //build up a record for the candle
               _candleLookback = StringConcatenate(_candleLookback, "up");
            }
            else if (
               minus1CandleOpen > minus1CandleClose
               && minus2CandleOpen > minus2CandleClose
            )
            {
               //bearish volume
            //   ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleHigh);
           //    ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
             //  ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Red);
               
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
              // ObjectCreate (_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleHigh);
             //  ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
             //  ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Orange);   
               
               //build up a record for the candle
               _candleLookback = StringConcatenate(_candleLookback, "x");     
                      
            }
            else if (
               minus1CandleOpen < minus1CandleClose
               && minus2CandleOpen > minus2CandleClose
            )
            {
               //bull following a bear
              // ObjectCreate (_labelName1+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleLow);
               //ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
               //ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Orange);    
               
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
              
           //ObjectCreate(_labelName2+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
         
            _tmpColor = Green;           
            if (  minus1Volume < _volumeLimit && minus2Volume < _volumeLimit ){  _tmpColor = LightGray;}
            //ObjectSetText(_labelName2+_labelIndex,"H"+_hhIndex,7,"Arial",_tmpColor);
               
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
                                            
           //ObjectCreate(_labelName2+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleHigh+((Point*10)*2));

            _tmpColor = Red;           
            if (  minus1Volume < _volumeLimit && minus2Volume < _volumeLimit ){  _tmpColor = LightGray;}
            //ObjectSetText(_labelName2+_labelIndex,"L"+_llIndex,7,"Arial",_tmpColor);
            
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
      
      RefreshRates();
      double _bid = MarketInfo(Sym,MODE_BID);
      double _ask = MarketInfo(Sym,MODE_ASK);
      double _point =MarketInfo(Sym,MODE_POINT);
      

//***************** BEGIN PATTERN ******************// 
            
                  //this will mark the places where volume spikes during non-peak hours
                  //we will take the average price of these prices and set our if/else/OCOs based on the range
                  //this is basically where the big money is quietly accumulating and distributing
                  int minus1Hour = TimeHour(Time[i+1]);
                  int minus1Minute = TimeMinute(Time[i+1]);
                  
                  if ( //time independent                    
                     minus1Volume >= (minus2Volume*2)
                     && minus1Volume > vsiMABuffer[i+1]
                     && minus2Volume < vsiMABuffer[i+2]
                     )
                  {                                                          
                     ObjectCreate("buysell"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleClose);
                     ObjectSetText("buysell"+_labelIndex,"x",9,"Arial",Yellow);   
                  }
                  
                  //at n hours, wipe our variables and record the average price of spikes
                  if (minus1Hour == 18 && minus1Minute == 5 )
                  {                  
                     ObjectCreate("buysell"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow-((Point*10)*5));
                     ObjectSetText("buysell"+_labelIndex,"Z",12,"Arial",Orange); 
                                          
                     _averagePriceForSpikeZone = 0.0;
                     spikesCounted = 0;
                     priceCollector = 0.0;
                  }
                  
                  //describe a range of hours
                  if (
                        (minus1Hour >= 18 && minus1Hour < 24)
                        || (minus1Hour >=0 && minus1Hour < 6)
                        
                        )
                  {   
                     //this is the exact same test as above, but will only catch stuff after the n1 hour and before the n2 hour
                     if (                     
                        minus1Volume >= (minus2Volume*2)
                        && minus1Volume > vsiMABuffer[i+1]
                        && minus2Volume < vsiMABuffer[i+2]
                     )
                     {                                                          
                          spikesCounted++;
                          priceCollector+=minus1CandleClose;
                     }
                  
                  
                  }
//***************** END PATTERN ******************// 


//***************** BEGIN PRICE BOUNDARY ******************//   
                
                  int priceBoundary = 12;
                  
                  if (
                     minus1Hour == 6
                     && minus1Minute == 5
                     && priceCollector > 0
                     && spikesCounted > 0
                     )
                  {
                                          
                     _averagePriceForSpikeZone = priceCollector/spikesCounted;
                     
                     //INITIATE IF/ELSE/OCO ORDERS 
                     ObjectCreate("buyLine" + _labelIndex,OBJ_TREND,0,Time[i+1], _averagePriceForSpikeZone + (Point*10)*priceBoundary ,Time[i+145],_averagePriceForSpikeZone + (Point*10)*priceBoundary);
                     ObjectSet("buyLine" + _labelIndex,OBJPROP_COLOR,Green);
                     ObjectSet("buyLine" + _labelIndex,OBJPROP_WIDTH,1);
                     ObjectSet("buyLine" + _labelIndex,OBJPROP_RAY,false);
						                  
                     ObjectCreate("sellLine" + _labelIndex,OBJ_TREND,0,Time[i+1], _averagePriceForSpikeZone - (Point*10)*priceBoundary ,Time[i+145],_averagePriceForSpikeZone - (Point*10)*priceBoundary);
                     ObjectSet("sellLine" + _labelIndex,OBJPROP_COLOR,Red);
                     ObjectSet("sellLine" + _labelIndex,OBJPROP_WIDTH,1);
                     ObjectSet("sellLine" + _labelIndex,OBJPROP_RAY,false);
                     
                     
                     ObjectCreate("buysellTrendLine" + _labelIndex,OBJ_TREND,0,Time[i+1], _averagePriceForSpikeZone,Time[i+145],_averagePriceForSpikeZone);
                     ObjectSet("buysellTrendLine" + _labelIndex,OBJPROP_COLOR,White);
                     ObjectSet("buysellTrendLine" + _labelIndex,OBJPROP_WIDTH,1);
                     ObjectSet("buysellTrendLine" + _labelIndex,OBJPROP_RAY,false);  
                     
                                                  
                  }
                  
                  
                  //TRY TO DEVELOP A TRIGGER -- THIS ONE IS BROKEN
                  
                  if (                     
                        //minus1Volume >= 2.5
                        minus1Hour == 4
                        && minus1Minute == 5
                     )
                     {                                                          

                        ObjectCreate("buyentry"+_labelIndex,OBJ_ARROW,0,Time[i+1],_averagePriceForSpikeZone + (Point*10)*priceBoundary);
                        ObjectSet("buyentry"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                        ObjectSet("buyentry"+_labelIndex,OBJPROP_COLOR,Green); 
                        
                        ObjectCreate("sellentry"+_labelIndex,OBJ_ARROW,0,Time[i+1],_averagePriceForSpikeZone - (Point*10)*priceBoundary);
                        ObjectSet("sellentry"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                        ObjectSet("sellentry"+_labelIndex,OBJPROP_COLOR,Red); 
                     
                     }
                                       
                     
//***************** END PRICE BOUNDARY ******************//                                     
                  
                  
                  
                  
               if( _signalPattern == "down|xhh|up")
               {
               
               
                     ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],open);
                     ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                     ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Blue);                                              
                  
               }
            //last thing you do is update the index
            _labelIndex++;
        }
   }
   
//***************** BEGIN UPDATE STATS ******************// 
/*
      string _statsLabelName = "stats";
      ObjectCreate(_statsLabelName, OBJ_LABEL, 0, 0, 0);
      ObjectSet(_statsLabelName, OBJPROP_XDISTANCE, 650);
      ObjectSet(_statsLabelName, OBJPROP_YDISTANCE, 10);
      string foo = StringConcatenate( "winners: ", _winners, "   losers:", _losers );
      ObjectSetText(_statsLabelName,foo,7,"Arial",CornflowerBlue);
      */
//***************** END UPDATE STATS ******************// 

	return(0);
}

