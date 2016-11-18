//breakouts using multi timeframes
//this is an experiment to see if i can code an indicator w/o tailoring the trade logic to cherry pick from known good trades
//arlo emerson 8/27/2012



#property link "http://www.fuckyou.com/"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_level1 1
#property indicator_color1  DodgerBlue
#property indicator_color2  Red
#property indicator_color3  Green

//---- input parameters
extern int		TimeFrame		= 1,		// {1=M1, 5=M5, ..., 60=H1, 240=H4, 1440=D1, ...}
					BarWidth			= 1,
					CandleWidth		= 2;


double EMA_H[];
double EMA_L[];
double EMA_C[];
string Sym = "";

int _labelIndex = 0;
string _labelName1 = "volumeArrow";
string _labelName2 = "hhll_";



string vsiTitle = "curious v.5";
#define    SECINMIN         60  //Number of seconds in a minute
extern int vsiMAPeriod    = 7;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */
double vsiBuffer[99];
double vsiMABuffer[99];

datetime _lastAlertTime;
bool _firstRun = false; //when script first loads, paint all the historical arrows if false

string _cciTrendMode = ""; //buy or sell depending on CCI 100/-100 crossings


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

int i=0;
int start()
{
   string _toPrint = "";

	int timeDiff;
	int limit;
		
	if (_lastAlertTime < Time[0] || _firstRun == false ) //a candle just opened
	{
   
      
      _firstRun = true;
      _lastAlertTime = Time[0];
      cleanUpChart();
      
      _labelIndex = 0;
       for(int i = Bars; i >= 0; i--)
       {


		      EMA_H[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, i );
		      EMA_L[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, i );
		      EMA_C[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, i );
		
		      int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
			       time1  = iTime    (NULL,TimeFrame,shift1),
			       shift2 = iBarShift(NULL,0,time1);
			  	int fiveMinuteShift= MathFloor(i/5);
			   int hourlyShift= MathFloor(i/60);
			   int fourHourlyShift= MathFloor(i/240);

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

				double volMinus1Candle = vsiBuffer[i+1];
				double volMinus2Candle = vsiBuffer[i+2];
				double volMinus3Candle = vsiBuffer[i+3];
				double volMinus4Candle = vsiBuffer[i+4];
				double volMinus5Candle = vsiBuffer[i+5];
				double volMinus6Candle = vsiBuffer[i+6];
				double volAverage = (volMinus1Candle + volMinus2Candle + volMinus3Candle + volMinus4Candle + volMinus5Candle + volMinus6Candle)/6;
				
				//160 EMA IndicatorS
				double hourlyEma160Minus1Candle = iMA(Sym,PERIOD_H1,160,0,MODE_EMA,PRICE_TYPICAL,hourlyShift+1);
				double fiveMinEma160Minus1Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,fiveMinuteShift+1);				
				double fourHourEma160Minus1Candle = iMA(Sym,PERIOD_H4,160,0,MODE_EMA,PRICE_TYPICAL,fourHourlyShift+1);	
				double oneMinuteEma160Minus1Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double oneMinuteEma160Minus2Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+2);
				double oneMinuteEma160Minus3Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+3);
				double oneMinuteEma160Minus4Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+4);
				double oneMinuteEma160Minus5Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+5);
				double oneMinuteEma160Minus6Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+6);
				double oneMinuteEma160Minus7Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+7);
				double oneMinuteEma160Minus8Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+8);
				double oneMinuteEma160Minus9Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+9);
				double oneMinuteEma160Minus10Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+10);
				double oneMinuteEma160Minus11Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+11);
				double oneMinuteEma160Minus12Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+12);
				double oneMinuteEma160Minus13Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+13);
				double oneMinuteEma160Minus14Candle = iMA(Sym,PERIOD_M1,160,0,MODE_EMA,PRICE_TYPICAL,shift1+14);
				
         	//larger timeframe candles
         	double fiveMinMinus1CandleClose = iClose(NULL,PERIOD_M5, fiveMinuteShift + 1 );
         	double hourlyMinus1CandleClose = iClose(NULL,PERIOD_H1, hourlyShift + 1 );
         	double fourHourlyMinus1CandleClose = iClose(NULL,PERIOD_H4, fourHourlyShift + 1 );

/* ------------------------- TRADE LOGIC ---------------------------*/				
				if(
					//volMinus1Candle < volAverage
					//1 min candle goes to the watering hole, dips and rises back above the 160
					minus1CandleClose > oneMinuteEma160Minus1Candle 
					&& minus2CandleLow < oneMinuteEma160Minus2Candle 
					/*
					&& minus3CandleLow > oneMinuteEma160Minus3Candle 
					&& minus4CandleLow > oneMinuteEma160Minus4Candle 
					&& minus5CandleLow > oneMinuteEma160Minus5Candle 
					&& minus6CandleLow > oneMinuteEma160Minus6Candle 
					&& minus7CandleLow > oneMinuteEma160Minus7Candle 
					&& minus8CandleLow > oneMinuteEma160Minus8Candle 
					&& minus9CandleLow > oneMinuteEma160Minus9Candle 
					&& minus10CandleLow > oneMinuteEma160Minus10Candle 
					&& minus11CandleLow > oneMinuteEma160Minus11Candle 
					&& minus12CandleLow > oneMinuteEma160Minus12Candle 
					&& minus13CandleLow > oneMinuteEma160Minus13Candle 
					&& minus14CandleLow > oneMinuteEma160Minus14Candle 
					*/
					//larger timeframe is trending up
					&& fiveMinMinus1CandleClose > fiveMinEma160Minus1Candle			
					&& hourlyMinus1CandleClose > hourlyEma160Minus1Candle
					&& fourHourlyMinus1CandleClose > fourHourEma160Minus1Candle

					
				//&& cciMinus1Candle > 0
				//	&& cciMinus2Candle < 0
				//	&& stdDevMinus1Candle < 0.0003
					//&& _cciTrendMode == "buy"
					//&& macd14_34_21 > 0
					//&& hourlyMacd14_34_21 > 0
				//	&& fourHourlyMacd14_34_21 > 0
					//&& hourlyMinus1CandleClose - hourlyEma34Minus1CandleHigh < (10*(Point*10))
					//&& ( hourlyMinus1CandleClose > hourlyEma34Minus1CandleHigh
					//	|| hourlyMinus1CandleClose < hourlyEma34Minus1CandleLow )
					//&& atrMinus1Candle < 0.0006
					//&& atrMinus1Candle > 0.0001
					
					//TODO: add some kind of volotility so we aren't trading in the midst of barb wire
					
					//&& minus1CandleClose > ema34Minus1CandleHigh
					//volMinus1Candle < 0.8
					//&& minus1CandleClose > ema50Minus1Candle
					//&& minus1CandleClose > ema80Minus1Candle
					//&& minus1CandleClose > ema160Minus1Candle				
				)
				{
					ObjectCreate("buyUptrend"+_labelIndex,OBJ_ARROW,0,Time[i+1],minus1CandleClose);
               ObjectSet("buyUptrend"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
               ObjectSet("buyUptrend"+_labelIndex,OBJPROP_COLOR,Green);
				}
				/*
				if (
					cciMinus1Candle < cciLow
					&& cciMinus2Candle < cciLow
					&& vsiBuffer[i+1] > 1
					)
					{
					
						ObjectCreate("buyZ_"+_labelIndex, OBJ_TEXT, 0, Time[i+1], minus1CandleLow);
						ObjectSetText("buyZ_"+_labelIndex,"Z",8,"Arial",Yellow);
					}
					
				if (
					cciMinus1Hour < cciLow
					&& cciMinus2Hour < cciLow
					&& vsiBuffer[i+1] > 1
					)
					{
					
						ObjectCreate("buyX_"+_labelIndex, OBJ_TEXT, 0, Time[i+1], minus1CandleLow - (10*(Point*10)));
						ObjectSetText("buyX_"+_labelIndex,"X",8,"Arial",Red);
					}
				*/


        		/*------- last thing you do is update the index --------*/
				_labelIndex++;
	     }
   }

	return(0);
}



