/*
  
   FIND WEAK DEMAND THEN MARK ENTRY TO SELL

   author:  Arlo Emerson
   date:    8/1/2012
*/

#property indicator_separate_window
//#property indicator_minimum -3000
#property indicator_buffers 2

#property indicator_level1 1

#property indicator_color1  DodgerBlue
#property indicator_color2  Red
#property indicator_color3  White

#define    SECINMIN         60  //Number of seconds in a minute

extern int  TimeFrame		= 5;

extern int vsiMAPeriod    = 21;  //Period for the moving average.
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
double _lookbackVolumePattern[20] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }; 
double strengthBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   _lastAlertTime = TimeCurrent();

   string vsiTitle = "the verge of greatness v.2";
   Sym = Symbol();
   
   SetIndexStyle(0,DRAW_HISTOGRAM,1,4);
   SetIndexStyle(1,DRAW_LINE,1,2);
   //SetIndexStyle(2,DRAW_LINE,1,1);
   
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
      double minus3Volume = vsiBuffer[shift1+3];
      double minus4Volume = vsiBuffer[shift1+4];
      double minus5Volume = vsiBuffer[shift1+5];
      double minus6Volume = vsiBuffer[shift1+6];
      double minus7Volume = vsiBuffer[shift1+7];
      double minus8Volume = vsiBuffer[shift1+8];
      double minus9Volume = vsiBuffer[shift1+9];
      double minus10Volume = vsiBuffer[shift1+10];
      double minus11Volume = vsiBuffer[shift1+11];
      double minus12Volume = vsiBuffer[shift1+12];
      double minus13Volume = vsiBuffer[shift1+13];
      double minus14Volume = vsiBuffer[shift1+14];
      double minus15Volume = vsiBuffer[shift1+15];
      double minus16Volume = vsiBuffer[shift1+16];
      double minus17Volume = vsiBuffer[shift1+17];
      double minus18Volume = vsiBuffer[shift1+18];
      double minus19Volume = vsiBuffer[shift1+19];
      double minus20Volume = vsiBuffer[shift1+20];
      
      double volume20MA =       
         (minus1Volume +
         minus2Volume +
         minus3Volume +
         minus4Volume +
         minus5Volume +
         minus6Volume +
         minus7Volume +
         minus8Volume +
         minus9Volume +
         minus10Volume +
         minus11Volume +
         minus12Volume +
         minus13Volume +
         minus14Volume +
         minus15Volume +
         minus16Volume +
         minus17Volume +
         minus18Volume +
         minus19Volume +
         minus20Volume)/20;
                          

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
      
      RefreshRates();
      double _bid = MarketInfo(Sym,MODE_BID);
      double _ask = MarketInfo(Sym,MODE_ASK);
      double _point =MarketInfo(Sym,MODE_POINT);
      

//***************** BEGIN SELL PATTERN ******************//    
            if(4==3)//DO NOT RUN
            {
                  if(
                        _signalPattern == "foobar" 
                  )
               {                                
                     ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i],open);
                     ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                     ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);                           
               }
            }
//***************** END SELL PATTERN ******************//    


//***************** BEGIN PATTERN ******************// 
            
                  double _effort = 0.0;
                  double _strength = 0.0;
                  string tmpString = "";
                  
                  
                  _lookbackVolumePattern[0] = _lookbackVolumePattern[1];
                  _lookbackVolumePattern[1] = _lookbackVolumePattern[2];
                  _lookbackVolumePattern[2] = _lookbackVolumePattern[3];
                  _lookbackVolumePattern[3] = _lookbackVolumePattern[4];
                  _lookbackVolumePattern[4] = _lookbackVolumePattern[5];
                  _lookbackVolumePattern[5] = _lookbackVolumePattern[6];
                  _lookbackVolumePattern[6] = _lookbackVolumePattern[7];
                  _lookbackVolumePattern[7] = _lookbackVolumePattern[8];
                  _lookbackVolumePattern[8] = _lookbackVolumePattern[9];
                  _lookbackVolumePattern[9] = _lookbackVolumePattern[10];
                  _lookbackVolumePattern[10] = _lookbackVolumePattern[11];
                  _lookbackVolumePattern[11] = _lookbackVolumePattern[12];
                  _lookbackVolumePattern[12] = _lookbackVolumePattern[13];
                  _lookbackVolumePattern[13] = _lookbackVolumePattern[14];
                  _lookbackVolumePattern[14] = _lookbackVolumePattern[15];
                  _lookbackVolumePattern[15] = _lookbackVolumePattern[16];
                  _lookbackVolumePattern[16] = _lookbackVolumePattern[17];
                  _lookbackVolumePattern[17] = _lookbackVolumePattern[18];
                  _lookbackVolumePattern[18] = _lookbackVolumePattern[19];
                  
                  //if(minus1Volume > 1)
                  //{
                     _effort = minus1Volume - 1;
                     
                     if (minus1CandleClose > minus1CandleOpen)
                     {
                        _strength = _effort / (minus1CandleHigh - minus1CandleLow);
                        strengthBuffer[i+1] = _strength;
                       
                        //ObjectCreate("strength"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow-((Point*10)*5));
                        //tmpString = StringConcatenate("", MathRound(_strength ) );
                        //ObjectSetText("strength"+_labelIndex, tmpString,7,"Arial",Green);
                        
                        //_oscillatorOfStrength += _strength;
                        _lookbackVolumePattern[19] = _strength;
                        
         
                     }
                     else if (minus1CandleClose < minus1CandleOpen)
                     {
                        _strength = _effort / (minus1CandleHigh - minus1CandleLow);
                        
                        //ObjectCreate("strength"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleHigh+((Point*10)*5));
                        //tmpString = StringConcatenate("", MathRound(_strength ));
                        //ObjectSetText("strength"+_labelIndex, tmpString,7,"Arial",Red);
                        
                        
                         //_oscillatorOfStrength -= _strength;
                         _lookbackVolumePattern[19] = _strength*(-1);
                         strengthBuffer[i+1] = _strength*(-1);
                         
                     }                                                     
                  //}
                  
                  

                  double volumeAverage = (_lookbackVolumePattern[0] + 
                  _lookbackVolumePattern[1] +
                  _lookbackVolumePattern[2] +
                  _lookbackVolumePattern[3] +
                  _lookbackVolumePattern[4] +
                  _lookbackVolumePattern[5] +
                  _lookbackVolumePattern[6] +
                  _lookbackVolumePattern[7] +
                  _lookbackVolumePattern[8] +
                  _lookbackVolumePattern[9] +
                  _lookbackVolumePattern[10] +
                  _lookbackVolumePattern[11] +
                  _lookbackVolumePattern[12] +
                  _lookbackVolumePattern[13] +
                  _lookbackVolumePattern[14] +
                  _lookbackVolumePattern[15] +
                  _lookbackVolumePattern[16] +
                  _lookbackVolumePattern[17] +
                  _lookbackVolumePattern[18] +
                  _lookbackVolumePattern[19])/20;
                                   
                  //tmpString = StringConcatenate("", MathRound(tmpDub ) );
                  
                  
                  
                  //test for weak demand, then set up a sell order
                  //test for:
                  //low volume bull Bar
                  //narrow spread
                  //close in the middle?
                  //change from previous: narrow
                  if (
                        
                        //declining volume
                        minus1Volume <= minus2Volume
                        && minus1Volume < minus3Volume
                        && minus2Volume < minus3Volume
                        //&& minus3Volume < minus4Volume
                        
                        //bull bar
                        && minus1CandleOpen < minus1CandleClose
                        
                        //narrow spread
                        && isNarrowSpread(minus1CandleHigh, minus1CandleLow, minus2CandleHigh, minus2CandleLow, 2.0 ) == 1
                        && isNarrowSpread(minus1CandleHigh, minus1CandleLow, minus3CandleHigh, minus3CandleLow, 2.0 ) == 1
                        
                        && minus1CandleHigh - minus3CandleLow <= ((Point*10)*3)                        
                        
                        //&& minus1CandleHigh > minus1_34EmaLow
                        
                        //similarity to previous candle
                        
                        //strengthBuffer[i+1] > 0                        
                        //&& strengthBuffer[i+2] > 0
                        
                        //&& strengthBuffer[i+3] < 0
                        //&& strengthBuffer[i+4] < 0
                        //&& strengthBuffer[i+4] > strengthBuffer[i+3]
                        //&& strengthBuffer[i+5] > strengthBuffer[i+3]
                        //&& strengthBuffer[i+5] < 0
                        //&& strengthBuffer[i+6] < strengthBuffer[i+5]
                        //&& strengthBuffer[i+6] < 0
                        //&& strengthBuffer[i+7] > 0 
                        //&& strengthBuffer[i+8] > 0 
                        //&& strengthBuffer[i+7] < strengthBuffer[i+5] 
                        
                        //&& strengthBuffer[i+8] > 0 
                  
                        //_lookbackVolumePattern[19] > 0
                        //&& _lookbackVolumePattern[18] < 0
                        //&& _lookbackVolumePattern[17] < 0
                        //&& minus1CandleClose > minus1CandleOpen
                        //&& minus2CandleClose > minus2CandleOpen
                        
                        //&& (minus1CandleClose - minus1CandleOpen <  ) //check that signal candle doesn't dwarf the preceding
                        
                        //&& (_candleLookback == "xhh" || _candleLookback == "uphh" )
                        //&& minus1Volume > 1.5 //stealth acquisition
                        //&& minus1Volume < 2 //stealth acquisition
                        //&& volume20MA < 1.5//flat spot
                        //&& notDoji(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow) == 0
                     )
                  {
                     //ObjectCreate("oscillator"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow-((Point*10)*8));                  
                     //ObjectSetText("oscillator"+_labelIndex, "UP",9,"Arial",Yellow);
                     
                     ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i],open);
                     ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                     ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);  
                           
                           
                  }
//***************** END PATTERN ******************// 




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

int isNarrowSpread(double pCandle1High, double pCandle1Low, double pCandle2High, double pCandle2Low, double pPipRange)
{
   double spread1 = MathAbs(pCandle1High - pCandle1Low); //removes negative number
   double spread2 = MathAbs(pCandle2High - pCandle2Low); //removes negative number
   
   if ( MathAbs(spread1 - spread2) <= ((Point*10)*pPipRange) )
   {
      return(1);
   }

   return(0);
}


int testCandlesForRangeSimilarity(double pCandleA, double pCandleB, double pPipRange)
{
   double n3 = MathAbs(pCandleA - pCandleB); //removes negative number
   //Alert(((Point*10)*pPipRange));
   if ( n3 <= ((Point*10)*pPipRange) && n3 >= 0)
   {
      return(1);
   }

   return(0);
}


int notDoji(double pOpen, double pClose, double pHigh, double pLow)
{
		int _wickTopPercent;
		int _wickBottomPercent;
 
      if (pHigh - pClose == 0){return (0);}
      if (pHigh - pOpen == 0){return (0);}
      if (pHigh - pLow == 0){return (0);}
      if (pOpen - pLow == 0){return (0);}
      if (pClose - pLow == 0){return (0);}

	    if (pOpen < pClose)//bullish candle
	    {
		    _wickTopPercent = ((pHigh - pClose)/(pHigh - pLow)) * 100;
		    _wickBottomPercent = ((pOpen - pLow)/(pHigh - pLow)) * 100;
	    }
	    else //bearish candle
	    {
		    _wickTopPercent = ((pHigh - pOpen)/(pHigh - pLow)) * 100;
		    _wickBottomPercent = ((pClose - pLow)/(pHigh - pLow)) * 100;
	    }


      if (
            _wickTopPercent >= 30
	         && _wickBottomPercent >= 30
         )
         {
            return(0);
         }
      
      
      //or if the open and close are within a couple pips
      /*
   if (pOpen < pClose)//bullish candle
   {
      if (pClose - pOpen <= 4.0)
      {
         return(0);
      }      
   }
   else if (pOpen > pClose)//bullish candle
   {
      if (pOpen - pClose <= 4.0)
      {
         return(0);
      } 
   }
*/
   return (1);
}


int notShootingStar(double pOpen, double pClose, double pHigh, double pLow)
{
		int _wickTopPercent;
		int _wickBottomPercent;
 
		if (pOpen < pClose)//bullish candle
		{
			_wickTopPercent = ((pHigh - pClose)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pOpen - pLow)/(pHigh - pLow)) * 100;
		}
		else //bearish candle
		{
			_wickTopPercent = ((pHigh - pOpen)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pClose - pLow)/(pHigh - pLow)) * 100;
		}


   if (
         _wickTopPercent >= 50
		   //&& _wickBottomPercent >= 30
      )
      {
         return(0);
      }

   return (1);
}

