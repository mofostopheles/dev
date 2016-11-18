/*

   v.7 is the best version thus far
   only two patterns netting 69/63.
   
   TODO:
   - isolate signals, write orders
   - bail out of trade if inverse signal appears
   - P & L on each entry
   
   
   KNOWN BUGS:
      - the current volume bar doesn't redraw dynamically, but it updates to correct value once a new bar opens
   
   
   NOTES:
   - open another chart running v5 to check for signal accuracy
   
   DEBUGGING TIPS:
   - you need to actually unload the indicator each time you retest because we prevent labels from being painted more than once
   - it will drive you crazy if you don't do this
   
   author:  Arlo Emerson
   date:    7/20/2012
*/

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 2
#property indicator_color1  DodgerBlue
#property indicator_color2  Red

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
double _takeProfitFactor = 28;

int _losers = 0;
int _winners = 0;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   _lastAlertTime = TimeCurrent();

   string vsiTitle = "volume and price - imminent swing finder --- v7";
   Sym = Symbol();
   
   SetIndexStyle(0,DRAW_HISTOGRAM,1,4);
   SetIndexStyle(1,DRAW_LINE,1,2);

   SetIndexBuffer(0, vsiBuffer);
   SetIndexBuffer(1, vsiMABuffer);
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
   }
   
   _winners = 0;
   _losers = 0;
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
      
      double _bid = MarketInfo(Sym,MODE_BID);
      double _ask = MarketInfo(Sym,MODE_ASK);
      double _point =MarketInfo(Sym,MODE_POINT);
     
      if(
         _signalPattern == "x|uphh|up"
         //_signalPattern == "downll|xhh|up" 
         )
      {
            ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],open);
            ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
            ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);
            
            _signalFired = true;
            _signalDirection = "buy";
            
            if (_inTrade==false)
            {
               _inTrade = true;
               _tradeDirection = "buy";
               
               //reset
               _signalFired = false;
             
               _takeProfit = _ask + 10*(_takeProfitFactor*_point);
               _stopLoss = _ask - 10*(_stopLossFactor*_point);
               
            }
      }
      else if (
         _signalPattern == "x|downll|down"
         )
      {
            ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i],open);
            ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
            ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);       
            
            _signalFired = true;
            _signalDirection = "sell";
            
            if (_inTrade==false)
            {
               _inTrade = true;
               _tradeDirection = "sell";
               
               //reset
               _signalFired = false;
               
               _takeProfit = _bid - 10*(_takeProfitFactor*_point);
               _stopLoss = _bid + 10*(_stopLossFactor*_point);
                string footrade = StringConcatenate("enter: ", _bid, " tp: ", _takeProfit, " sl: ", _stopLoss);
               //Alert(footrade);
            }
      }
       
//***************** BEGIN TRADE SIMULATION LOGIC ******************//
      double _spread = 2*_point;
      
      if (_inTrade == true)
      {
         if(_tradeDirection == "buy")
         {
            if (
               high <= _stopLoss
               || low <= _stopLoss
               || open <= _stopLoss
               || close <= _stopLoss
               )
            {
               _losers++;
               _inTrade = false;
               _tradeDirection = "";
            }
            else if(
               high >= _takeProfit
               || low >= _takeProfit
               || open >= _takeProfit
               || close >= _takeProfit
               )
            {
               _winners++;
               _inTrade = false;
               _tradeDirection = "";
            }
         }
         else if(_tradeDirection == "sell")
         {
            if (
                 high >= _stopLoss
               || low >= _stopLoss
               || open >= _stopLoss
               || close >= _stopLoss
               
               )
            {
               _losers++;
               _inTrade = false;
               _tradeDirection = "";
            }
            else if(
               high <= _takeProfit
               || low <= _takeProfit
               || open <= _takeProfit
               || close <= _takeProfit
               )
            {
               _winners++;
               _inTrade = false;
               _tradeDirection = "";
            }
         }
         
         
         //something here about 
         //if still in a trade but 
         //new signal appears then back out of current trade
         //use:
         //_signalDirection = "";  

      }

//***************** END TRADE SIMULATION LOGIC ******************// 
      
      
            //last thing you do is update the index
            _labelIndex++;
        }
   }
   
  

//***************** BEGIN UPDATE STATS ******************// 
      string _statsLabelName = "stats";
      ObjectCreate(_statsLabelName, OBJ_LABEL, 0, 0, 0);
      ObjectSet(_statsLabelName, OBJPROP_XDISTANCE, 650);
      ObjectSet(_statsLabelName, OBJPROP_YDISTANCE, 10);
      string foo = StringConcatenate( "winners: ", _winners, "   losers:", _losers );
      ObjectSetText(_statsLabelName,foo,7,"Arial",CornflowerBlue);
//***************** END UPDATE STATS ******************// 

	return(0);
}