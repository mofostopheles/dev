//breakouts using multi timeframes
//see this thread
//https://mail.google.com/mail/?shva=1#inbox/1396b9c48774bb4e
//implementing "last resistence" test i.e. price must first break through last resistence and not fail.
//arlo emerson 8/29/2012

//if this isn't hunting, sex and war rolled all into one i don't know what is.


#property link "http://www.fuckyou.com/"
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



string vsiTitle = "curious v.8";
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
bool _TARGET_ACQUIRED = false;
bool _TARGET_LOCKED = false;
double _entryPrice;
double _TP;
double _SL;
int _targetAcquisitionTime;
double _targetAcquisitionHigh;
double _targetAcquisitionLow;
double _targetAcquisitionOpen;
double _targetAcquisitionClose;

int _targetConfirmationTime;
double _targetConfirmationHigh;
double _targetConfirmationLow;
double _targetConfirmationOpen;
double _targetConfirmationClose;

double _resistencePrices[]; //list for storing prices where resistence occurs
int _resistencePriceCounter = 0;

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
		
            int minus2CandleTime = iTime(NULL,TimeFrame,shift1+2);
		      double minus2CandleLow = iLow(NULL,TimeFrame,shift1+2);
		      double minus2CandleHigh = iHigh(NULL,TimeFrame,shift1+2);
            double minus2CandleClose = iClose(NULL,TimeFrame,shift1+2);
            double minus2CandleOpen = iOpen(NULL,TimeFrame,shift1+2);
      
            int minus3CandleTime = iTime(NULL,TimeFrame,shift1+3);      
            double minus3CandleLow = iLow(NULL,TimeFrame,shift1+3);
		      double minus3CandleHigh = iHigh(NULL,TimeFrame,shift1+3);
            double minus3CandleClose = iClose(NULL,TimeFrame,shift1+3);
            double minus3CandleOpen = iOpen(NULL,TimeFrame,shift1+3);
            
            int minus4CandleTime = iTime(NULL,TimeFrame,shift1+4);
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
         	
         	//MACD
         	double fiveMinMacd12269Minus1Candle = iMACD(Sym, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_EMA, shift1+1);
         	double fiveMinMacd12269Minus2Candle = iMACD(Sym, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_EMA, shift1+2);
         	double fiveMinMacd12269Minus3Candle = iMACD(Sym, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_EMA, shift1+3);
         	double fiveMinMacd12269Minus4Candle = iMACD(Sym, PERIOD_M5, 12, 26, 9, PRICE_CLOSE, MODE_EMA, shift1+4);
         	
/* ------------------------- S/R LINES ---------------------------*/
         	
         	//mark resistence lines
         	if (
         	     fiveMinMacd12269Minus1Candle < 0
         	     && fiveMinMacd12269Minus2Candle > 0
         	     && fiveMinMacd12269Minus3Candle > 0
         	     && fiveMinMacd12269Minus4Candle > 0
         	     )
         	     {
                     //start drawing a line at this price
                     ObjectCreate("resistenceSellLine" + _labelIndex,OBJ_TREND,0, minus1CandleTime, minus3CandleClose, minus4CandleTime, minus3CandleClose );
                     ObjectSet("resistenceSellLine" + _labelIndex,OBJPROP_COLOR,Yellow);
                     ObjectSet("resistenceSellLine" + _labelIndex,OBJPROP_WIDTH,1);
                     ObjectSet("resistenceSellLine" + _labelIndex,OBJPROP_RAY,false);
                        
                     _resistencePrices[_resistencePriceCounter] = minus3CandleClose;
                     /*                     
                     int tmpArraySize = ArraySize(_resistencePrices);
                     int priceFoundInList = ArrayBsearch(_resistencePrices, minus3CandleClose, WHOLE_ARRAY, 1, MODE_ASCEND);
                     
                     if (NULL == priceFoundInList)
                     {                        
                        
                     }
                     */            	     
         	     }

/* ------------------------- TRADE LOGIC ---------------------------*/

				//acquire a target				
				if(	//does price cross above and test the 160 EMA?
						//do the larger timeframes close above the 160 EMA?
						//if yes, support (demand) is at this price
						minus1CandleClose > fiveMinuteEma160Minus1Candle 
						&& minus2CandleLow < fiveMinuteEma160Minus2Candle 			
						&& hourlyMinus1CandleClose > hourlyEma160Minus1Candle
						&& fourHourlyMinus1CandleClose > fourHourEma160Minus1Candle					
						//&& hourlyMinus1CandleClose > hourlyEma34Minus1Candle
						//&& fourHourlyMinus1CandleClose > fourHourEma34Minus1Candle															
				)
				{
      			_TARGET_ACQUIRED = true;
      			_targetAcquisitionTime = Time[i+1];
      			_targetAcquisitionOpen = minus1CandleOpen;
					_targetAcquisitionHigh = minus1CandleHigh;
					_targetAcquisitionLow = minus1CandleLow;
					_targetAcquisitionClose = minus1CandleClose;
      			ObjectCreate("targetAcquiredbuy"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
         		ObjectSetText("targetAcquiredbuy"+_labelIndex,"Z",12,"Arial",Yellow);
				}
			
				//confirm the target is valid (i.e. support/demand is real)
				if (  
						_TARGET_ACQUIRED == true
						&& Time[i+1] > _targetAcquisitionTime
						
						//METHOD #1
						//confirm the support level of the target price
						//looking for a mini downtrend or down candle to revisit the zone
						//&& minus1CandleClose <= _targetAcquisitionLow //top of zone 
						//&& minus1CandleClose >= (_targetAcquisitionLow - 10*(Point*10)) //bottom of zone
							
						//METHOD #2
						//test for open air on 12 candles
						//don't want to be in the shadow of some huge candle
						//&& lastCloseInOpenAir(minus1CandleClose, 20, i+1) == 1
						&& minus1CandleClose > minus2CandleHigh
						&& minus1CandleClose > minus3CandleHigh
						&& minus1CandleClose > minus4CandleHigh
						&& minus1CandleClose > minus5CandleHigh
						&& minus1CandleClose > minus6CandleHigh
						&& minus1CandleClose > minus7CandleHigh
						&& minus1CandleClose > minus8CandleHigh
						&& minus1CandleClose > minus9CandleHigh
						&& minus1CandleClose > minus10CandleHigh
						&& minus1CandleClose > minus11CandleHigh
						&& minus1CandleClose > minus12CandleHigh
						&& minus1CandleClose > minus13CandleHigh
						&& minus1CandleClose > minus14CandleHigh
						&& minus1CandleClose > minus15CandleHigh
						&& minus1CandleClose > minus16CandleHigh
						&& minus1CandleClose > minus17CandleHigh
						&& minus1CandleClose > minus18CandleHigh
						&& minus1CandleClose > minus19CandleHigh
						&& minus1CandleClose > minus20CandleHigh
						
						
						//NEED TO DEFEND AGAINST FALLEN STARS 
						//TO MUCH PIP MOVE INDICATES FALLEN STAR
															
				)
				{
					_TARGET_LOCKED = true;
					_targetConfirmationTime = Time[i+1];
      			_targetConfirmationOpen = minus1CandleOpen;
					_targetConfirmationHigh = minus1CandleHigh;
					_targetConfirmationLow = minus1CandleLow;
					_targetConfirmationClose = minus1CandleClose;
					ObjectCreate("targetConfirmedbuy"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
         		ObjectSetText("targetConfirmedbuy"+_labelIndex,"X",12,"Arial",Red);
				}
				
				//target is real, price has broken free of the 34 EMA		
				if (					
						_TARGET_ACQUIRED == true
						&& _TARGET_LOCKED == true
						&& Time[i+1] > _targetConfirmationTime //time must have passed so a retest can occur
						
						
						//METHOD #1 - 34 EMA BREAKTHOUGH
						/*
						&& minus1CandleClose > _targetConfirmationClose //price must be higher than target confirmation
						&& minus1CandleClose > fiveMinEma34Minus1Candle
						&& minus2CandleClose > fiveMinEma34Minus2Candle
						&& minus3CandleClose > fiveMinEma34Minus3Candle
						&& minus4CandleClose > fiveMinEma34Minus4Candle
						&& minus5CandleClose > fiveMinEma34Minus5Candle
						&& minus6CandleClose > fiveMinEma34Minus6Candle
						&& minus7CandleClose > fiveMinEma34Minus7Candle						
						*/
						
						//METHOD #2 - PAST RESISTENCE BREAKTHROUGH
						&& resistenceBroken(minus1CandleClose) == true
				)
				{
					_TARGET_ACQUIRED = false;
					_TARGET_LOCKED = false;
					ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],open);
					ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
					ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);
				}		
				
				//retire the target if it slips below our zone				
				if (  
						_TARGET_ACQUIRED == true
						&& Time[i+1] > _targetConfirmationTime //time must have passed
						&& minus1CandleClose <= (_targetAcquisitionLow - 10*(Point*10)) //bottom of zone 
						)
						{
							_TARGET_ACQUIRED = false;
							_TARGET_LOCKED = false;
						}
						

        		/*------- last thing you do is update the index --------*/
				_labelIndex++;
	     }
   }

	return(0);
}

bool resistenceBroken(double priceToTest)
{
   int tmpArraySize = ArraySize(_resistencePrices);
   
   for(int k=0;k<tmpArraySize;k++)
   {
      if (priceToTest > _resistencePrices[k])
      {
         //remove price from array
         Print("array before resize: ",  ArraySize(_resistencePrices), " ",  _resistencePrices);
         _resistencePrices[k] = 0;
         ArraySort(_resistencePrices,  WHOLE_ARRAY, 0, MODE_DESCEND);
         ArrayResize(_resistencePrices, tmpArraySize-1);
         Print("array after resize: ",  ArraySize(_resistencePrices), " ",  _resistencePrices);
         return (true);
      }
   }

   return (false);
}

int lastCloseInOpenAir(double priceToTest, int pLookback, int pIndex)
{
   int counter = 0;
   //start at 2 because we are always passing in the +1 candle
   for (int z=2;z<=pLookback;z++)
   {  
      if (priceToTest <= iHigh(NULL,5,z+pIndex))
      {
      
         //ObjectCreate("buysellMissedOpp"+_labelIndex,OBJ_TEXT,0,Time[z+pIndex],priceToTest);
         //ObjectSetText("buysellMissedOpp"+_labelIndex,"x",14,"Arial",Orange); 
         
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

