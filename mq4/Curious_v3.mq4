//breakout trader

#property link "http://www.forexfactory.com/"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_level1 1
#property indicator_color1  DodgerBlue
#property indicator_color2  Red
#property indicator_color3  Green

//---- input parameters
extern int		TimeFrame		= 5,		// {1=M1, 5=M5, ..., 60=H1, 240=H4, 1440=D1, ...}
					BarWidth			= 1,
					CandleWidth		= 2;


double EMA_H[];
double EMA_L[];
double EMA_C[];
string Sym = "";

int _labelIndex = 0;
string _labelName1 = "volumeArrow";
string _labelName2 = "hhll_";



string vsiTitle = "curious v.3";
#define    SECINMIN         60  //Number of seconds in a minute
extern int vsiMAPeriod    = 7;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */
double vsiBuffer[9999];
double vsiMABuffer[9999];

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
 
				//date and time		
				int YY=TimeYear(  Time[i+1]);   // Year
				int MN=TimeMonth( Time[i+1]);   // Month         
				int DD=TimeDay(   Time[i+1]);   // Day
				int HH=TimeHour(  Time[i+1]);   // Hour         
				int MM=TimeMinute(Time[i+1]);   // Minute
      
      

      
				//CCI boundary recross detector
				int cciLow = 100;
				cciLow *= -1;
				int cciMinus1Candle = iCCI(Sym,PERIOD_M5,14,PRICE_TYPICAL,i+1);
				int cciMinus2Candle = iCCI(Sym,PERIOD_M5,14,PRICE_TYPICAL,i+2);
				int cciMinus3Candle = iCCI(Sym,PERIOD_M5,14,PRICE_TYPICAL,i+3);
				int cciMinus4Candle = iCCI(Sym,PERIOD_M5,14,PRICE_TYPICAL,i+4);
				int cciMinus5Candle = iCCI(Sym,PERIOD_M5,14,PRICE_TYPICAL,i+5);
				
				int cciMinus1CandleClose = iCCI(Sym,PERIOD_M5,14,PRICE_CLOSE,i+1);
				
				int cciMinus1Hour = iCCI(Sym,PERIOD_H1,14,PRICE_TYPICAL,i+1);
				int cciMinus2Hour = iCCI(Sym,PERIOD_H1,14,PRICE_TYPICAL,i+2);
				
				double ema34Minus1Candle = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double ema34Minus1CandleHigh = iMA(Sym,PERIOD_M5,34,0,MODE_EMA,PRICE_HIGH,shift1+1);
				
				double ema50Minus1Candle = iMA(Sym,PERIOD_M5,50,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double ema80Minus1Candle = iMA(Sym,PERIOD_M5,80,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double ema160Minus1Candle = iMA(Sym,PERIOD_M5,160,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				
				double stdDevMinus1Candle = iStdDev(Sym, PERIOD_M5, 7, 0, MODE_SMA, PRICE_CLOSE, shift1+1);
				
				double volMinus1Candle = vsiBuffer[i+1];
				double atrMinus1Candle = iATR(Sym, PERIOD_M5, 34, i+1);
				
				//hourly IndicatorS
				double hourlyEma34Minus1CandleHigh = iMA(Sym,PERIOD_H1,34,0,MODE_EMA,PRICE_HIGH,hourlyShift+1);
				double hourlyEma34Minus1CandleLow = iMA(Sym,PERIOD_H1,34,0,MODE_EMA,PRICE_LOW,hourlyShift+1);
				
				//MACD
				double macd14_34_21 = iMACD(Sym,PERIOD_M5,14,34,21,PRICE_CLOSE,MODE_MAIN,shift1+1);
				double hourlyMacd14_34_21 = iMACD(Sym,PERIOD_H1,14,34,21,PRICE_CLOSE,MODE_MAIN,hourlyShift+1);
				double fourHourlyMacd14_34_21 = iMACD(Sym,PERIOD_H4,14,34,21,PRICE_CLOSE,MODE_MAIN,fourHourlyShift+1);
   			//hourly prices
         	
         	double hourlyMinus1CandleClose = iClose(NULL,PERIOD_H1, hourlyShift+ 1 );

				if (MN==8 && DD == 27 && YY == 2012 && HH == 0 && MM == 0) //should be 1.2358
      		{      		

      			Print("5 min chart price: " + minus1CandleClose);
      			Print("i = " + i);
      			Print("hourly index: " + hourlyShift+ 1);
      			Print("hourlyMinus1CandleClose: " + hourlyMinus1CandleClose);
      		}				
				
				//need a CCI filter
				//if crosses above 100, we are in buy mode 
				//if crosses below -100, we are in sell mode 	
				
				if(
					cciMinus1CandleClose > 0
					)
				{
					_cciTrendMode = "buy";
				}
				else if (
					cciMinus1CandleClose < 0
					)
				{
					_cciTrendMode = "sell";
				}
				
				if(
					minus1CandleClose > ema160Minus1Candle
				//&& cciMinus1Candle > 0
				//	&& cciMinus2Candle < 0
				//	&& stdDevMinus1Candle < 0.0003
					&& _cciTrendMode == "buy"
					&& macd14_34_21 < 0
					&& hourlyMacd14_34_21 > 0
					&& fourHourlyMacd14_34_21 > 0
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

  int handle;

  handle=FileOpen("x.txt", FILE_CSV|FILE_WRITE, ';');
  if(handle>0)
  {
     FileWrite(handle, _toPrint);
     FileClose(handle);
  }

	return(0);
}



