/*
   this is a pattern harvester. use the output with "ae_expert_barometer_v1.mq4"
   
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

   author:  Arlo Emerson
   date:    8/23/2012
*/


int _pipMove = 50;
int _lookback = 12;
bool _ran = false;
double _openingPriceOpen;
double _openingPriceClose;
double _openingPriceHigh;
double _openingPriceLow;
string _openingPriceIndicator;
bool _runTest_OpeningPrice = true;

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_level1 1
#property indicator_color1  DodgerBlue
#property indicator_color2  Red
#property indicator_color3  Green

#define    SECINMIN         60  //Number of seconds in a minute

string vsiTitle = "barometer readings v.1";

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
double EMA_H[];
double EMA_L[];
double EMA_C[];

int _labelIndex = 0;
string _labelName1 = "volumeArrow";
string _labelName2 = "hhll_";
string _previousLabel = "";
int _hhIndex = 1;
int _llIndex = 1;

string Sym = "";
datetime _lastAlertTime;
bool _firstRun = false; //when script first loads, paint all the historical arrows if false


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   _lastAlertTime = TimeCurrent();

   Sym = Symbol();
   
   SetIndexStyle(0,DRAW_HISTOGRAM,1,4);
   SetIndexStyle(1,DRAW_LINE,1,2);

   SetIndexBuffer(0, vsiBuffer);
   SetIndexBuffer(1, vsiMABuffer);
 
   IndicatorShortName(vsiTitle);
   
   SetIndexLabel(0, vsiTitle);
   SetIndexLabel(1, "vsiMA(" + vsiMAPeriod + ")");
   SetIndexDrawBegin(1, vsiMAPeriod);
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

int ThisBarTrade=0;
int i=0;
int start()
{
   string _toPrint = "";

	int timeDiff;
	int limit;
		
//	if (_lastAlertTime < Time[0] || _firstRun == false ) //a candle just opened
//   {
   
      
      _firstRun = true;
      _lastAlertTime = Time[0];
      cleanUpChart();
      
      _labelIndex = 0;
       //  for(int i = Bars; i >= 0; i--)
       //  {
       
          if (Bars != ThisBarTrade )
   {
       ThisBarTrade = Bars;

		      EMA_H[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, i );
		      EMA_L[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, i );
		      EMA_C[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, i );
		
		      int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
			       time1  = iTime    (NULL,TimeFrame,shift1),
			       shift2 = iBarShift(NULL,0,time1);

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

		      string tmpMessage = "";
		      bool _trendImminent = false;		
		      string _trendDirection = "";
		      
		      int minus1Hour = TimeHour(Time[i+1]);
            int minus1Minute = TimeMinute(Time[i+1]);
            
            //---------------------- BEGIN OPENING PRICE INDICATOR ---------------------//            
            if (_runTest_OpeningPrice == true)
            {            
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
            }
		      //---------------------- END OPENING PRICE INDICATOR ---------------------//
		       
		       
		      //---------------------- find a candle that begins a massive trend ---------------------//

		      if (minus1CandleHigh - minus12CandleHigh > ((Point*10)*_pipMove) )
		      {
               ObjectCreate("bigUptrend"+i,OBJ_ARROW,0,Time[i+_lookback],minus12CandleLow);
               ObjectSet("bigUptrend"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
               ObjectSet("bigUptrend"+i,OBJPROP_COLOR,Green);
         
               _trendImminent = true;
               _trendDirection = "\"bull\", ";
		      }
		
	
		      if (minus12CandleLow - minus1CandleLow  > ((Point*10)*_pipMove) )
		      {
               ObjectCreate("bigDowntrend"+i,OBJ_ARROW,0,Time[i+_lookback],minus12CandleHigh);
               ObjectSet("bigDowntrend"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
               ObjectSet("bigDowntrend"+i,OBJPROP_COLOR,Red);
         
               _trendImminent = true;
               _trendDirection = "\"bear\", ";
		      }
		
		      string _signalMatrix = "";

		      
            int YY=TimeYear(  Time[i+1]);   // Year
            int MN=TimeMonth( Time[i+1]);   // Month         
            int DD=TimeDay(   Time[i+1]);   // Day
            int HH=TimeHour(  Time[i+1]);   // Hour         
            int MM=TimeMinute(Time[i+1]);   // Minute
		      string tmpDate = MN + "/" + DD + "/" + YY;
		
		      if (_trendImminent == true)
		      {				      
		          //------- DATE - FOR REFERENCE ONLY  --------//
		          _signalMatrix = StringConcatenate( _signalMatrix, "\"", tmpDate, "\",");	
		          
		          //------- OPENING PRICE INDICATOR - 0  --------//
		          _signalMatrix = StringConcatenate( _signalMatrix, "\"", _openingPriceIndicator, "\",");		          
		          
		          //------- MACD - 1 --------//
		          if (macdAVG143421 > 0)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"above\",");
		          }
		          else if (macdAVG143421 < 0)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"below\",");
		          }
		          
		          //------- MACD - 2 --------//
		          if (macdAVG8016021 > 0)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"above\",");
		          }
		          else if (macdAVG8016021 < 0)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"below\",");
		          }
		          else
			  {
				_signalMatrix = StringConcatenate( _signalMatrix, "\"-\",");
			  }
		          
		          	
		      	 //------- EMA - 3 --------//
		          if ( iMA(Sym, TimeFrame, 2, TimeFrame, MODE_EMA, PRICE_LOW, i+_lookback ) < iMA(Sym, TimeFrame, 12, TimeFrame, MODE_EMA, PRICE_TYPICAL, i+_lookback ))
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"below\",");
		          }
		          else if ( iMA(Sym, TimeFrame, 2, TimeFrame, MODE_EMA, PRICE_HIGH, i+_lookback ) > iMA(Sym, TimeFrame, 12, TimeFrame, MODE_EMA, PRICE_TYPICAL, i+_lookback ))
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"above\",");
		          }
		          else
			  {
				_signalMatrix = StringConcatenate( _signalMatrix, "\"-\",");
			  }
		          
		          			          	
			       //------- EMA - 4 --------//
		          if ( minus12CandleLow < iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, i+_lookback ))
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"below\",");
		          }
		          else if ( minus12CandleHigh > iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, i+_lookback ))
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"above\",");
		          }   
		          else
			  {
				_signalMatrix = StringConcatenate( _signalMatrix, "\"-\",");
			  }
		          
		             
		          //------- Standard Deviation - 5 --------//
		          if (iStdDev(NULL, 5, 7, 0, MODE_SMA, PRICE_CLOSE, i+_lookback) < 0.0003)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"below\",");
		          }
		          else if (iStdDev(NULL, 5, 7, 0, MODE_SMA, PRICE_CLOSE, i+_lookback) > 0.0003)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"above\",");
		          }
		          else
		          {
		          	_signalMatrix = StringConcatenate( _signalMatrix, "\"-\",");
		          }
		          
		          //------- Specific Volume - 6 --------//
		          if (vsiBuffer[i+_lookback] < 1)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"below\",");
		          }
		          else if (vsiBuffer[i+_lookback] > 1)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"above\",");
		          }
		          else
			  {
				_signalMatrix = StringConcatenate( _signalMatrix, "\"-\",");
		          }
		          
		          //------- MA Volume - 7 --------//
		          if (vsiMABuffer[i+_lookback] < 1)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"below\",");
		          }
		          else if (vsiMABuffer[i+_lookback] > 1)
		          {
		             _signalMatrix = StringConcatenate( _signalMatrix, "\"above\",");
		          }
		          else
			  {
				_signalMatrix = StringConcatenate( _signalMatrix, "\"-\",");
			  }
		          
         
               /*
                * SETUP OUR PRINTER VARIABLE
                */         
               _toPrint = StringConcatenate(_toPrint, "\n", _signalMatrix);
               
         
            }  	
	     }


  // }

  int handle;

  handle=FileOpen("barometer_3.txt", FILE_CSV|FILE_WRITE, ';');
  if(handle>0)
  {
     FileWrite(handle, _toPrint);
     FileClose(handle);
  }
  Print(_toPrint);



	
	

	return(0);
}



