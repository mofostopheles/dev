//arlo emerson, 9/10/2012

//this is a raghee horner method
//13/21 green line
//34/55 red line, ema Close
//except for the 34 is low for buy and high for sell

//USING PRICE ACTION TO RULE THE WORLD

//globally adjust tp/sl
double _stopLossFactor = 8;
double _takeProfitFactor = 47;

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

string _labelName1 = "trend";
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


bool _TARGET_ACQUIRED = false;
bool _TARGET_LOCKED = false;
double _ENTRY_TARGET;
double _RESISTANCE_TARGET;
double _SUPPORT_TARGET;
double _LAST_AVERAGE_SUPPORT;
double _LAST_AVERAGE_RESISTANCE;
double _LAST_LOW;
double _LAST_HIGH;
int _LAST_HIGH_SHIFT;
int _LAST_LOW_SHIFT;
double _entryPrice;
double _TP;
double _SL;

int _tradeEntryTime;
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

double _resistencePrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00}; //list for storing prices where resistence occurs
int _resistencePriceCounter = 0;

double _supportPrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00}; //list for storing prices where resistence occurs
int _supportPriceCounter = 0;

int _shiftMacdStart, _shiftMacdEnd;
int _shiftSupportMacdStart, _shiftSupportMacdEnd;

int _tradeLeg = 0; //we count legs or our trades, currently we only do 2 legs per entry

double _lastZCrossingClose;
double _thisZCrossingClose;
double _lastZCrossingHigh;
double _thisZCrossingHigh;
double _lastZCrossingLow;
double _thisZCrossingLow;

int _lastZCrossingTime;
int _thisZCrossingTime;

bool _SUPPORT_CYCLE = false;
bool _RESISTANCE_CYCLE = false;
double _BULL_CANDLE_COUNTER;
double _BEAR_CANDLE_COUNTER;

bool _minus1CandleSupportCycleOn = false;
double _downtrendStartPrice;
double _downtrendEndPrice;
int _downtrendStartPriceTime;
string _lastTrendlineName;
int _lastTrendlineShift;


bool _STRONG_BEAR_CANDLE = false;
double _STRONG_BEAR_CANDLE_LOW;
double _STRONG_BEAR_CANDLE_HIGH;
bool _SUPPLY_INCREASING = false;
int _SUPPLY_INCREASING_TIME;
bool _MORE_SUPPLY = false;
int _SUPPLY_COUNTER = 0;


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
   //for(int i = Bars; i >= 0; i--)
   {
       ThisBarTrade = Bars;
   
      //declarations
      int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
	        time1  = iTime    (NULL,TimeFrame,shift1);
	        
		//int fiveMinuteShift= MathFloor(i/5);
		//int hourlyShift= MathFloor(i/60);
		//int fourHourlyShift= MathFloor(i/240);
		int fifteenMinShift = MathFloor(i/3);
      int hourlyShift = MathFloor(i/12);
      int fourHourlyShift = MathFloor(i/48);
      int dailyShift = MathFloor(i/288);

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
		double minus5CandleOpen = iOpen(NULL,TimeFrame,shift1+5);

   	double minus6CandleLow = iLow(NULL,TimeFrame,shift1+6);
   	double minus6CandleHigh = iHigh(NULL,TimeFrame,shift1+6);
   	double minus6CandleClose = iClose(NULL,TimeFrame,shift1+6);
		double minus6CandleOpen = iOpen(NULL,TimeFrame,shift1+6);

   	double minus7CandleLow = iLow(NULL,TimeFrame,shift1+7);
   	double minus7CandleHigh = iHigh(NULL,TimeFrame,shift1+7);
   	double minus7CandleClose = iClose(NULL,TimeFrame,shift1+7);
		double minus7CandleOpen = iOpen(NULL,TimeFrame,shift1+7);

   	double minus8CandleLow = iLow(NULL,TimeFrame,shift1+8);
   	double minus8CandleHigh = iHigh(NULL,TimeFrame,shift1+8);
   	double minus8CandleClose = iClose(NULL,TimeFrame,shift1+8);
		double minus8CandleOpen = iOpen(NULL,TimeFrame,shift1+8);

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
   	
//***************** DAILY CANDLES *******************//
   	
   	double minus1DailyCandleClose = iClose(NULL,TimeFrame,dailyShift+1);
   	double minus1DailyCandleOpen = iOpen(NULL,TimeFrame,dailyShift+1);
                
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
				
				//13, 21 EMA
				double fiveMinEma13Minus1Candle = iMA(Sym,PERIOD_M5,13,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				double fiveMinEma21Minus1Candle = iMA(Sym,PERIOD_M5,21,0,MODE_EMA,PRICE_TYPICAL,shift1+1);
				
				
         	//larger timeframe candles
         	double fiveMinMinus1CandleClose = iClose(NULL,PERIOD_M5, shift1 + 1 );
         	double hourlyMinus1CandleClose = iClose(NULL,PERIOD_H1, hourlyShift + 1 );
         	double fourHourlyMinus1CandleClose = iClose(NULL,PERIOD_H4, fourHourlyShift + 1 );
         	
         	//MACD
         	double fiveMinMacdMinus1Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+1);
         	double fiveMinMacdMinus2Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+2);
         	double fiveMinMacdMinus3Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+3);
         	double fiveMinMacdMinus4Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+4);
         	
         	double fiveMinMacd_143421_Minus1Candle = iMACD(Sym, PERIOD_M5, 14, 34, 21, PRICE_CLOSE, MODE_EMA, shift1+1);
         	double fiveMinMacd_143421_Minus2Candle = iMACD(Sym, PERIOD_M5, 14, 34, 21, PRICE_CLOSE, MODE_EMA, shift1+2);
         	double fiveMinMacd_143421_Minus3Candle = iMACD(Sym, PERIOD_M5, 14, 34, 21, PRICE_CLOSE, MODE_EMA, shift1+3);
        
        		double fifteenMacd_143421_Minus1Candle = iMACD(Sym, PERIOD_M15, 14, 34, 21, PRICE_CLOSE, MODE_EMA, fifteenMinShift+1);
        		double hourlyMacd_143421_Minus1Candle = iMACD(Sym, PERIOD_H1, 14, 34, 21, PRICE_CLOSE, MODE_EMA, hourlyShift+1);
/* ------------------------- RESISTANCE LINES - NEG TO POS TO NEG ---------------------------*/
            
            //PURPOSE OF S/R CODE:
            //to find resistence lines and prevent entries right under these lines

         	//psuedo code         	
         	//when macd rises over 0, store shiftMacdStart
         	//when macd dips below 0, store shiftMacdEnd
         	//and use iHighest to determine the highest price between shiftMacdStart and shiftMacdEnd
         	//store the highest price in the resistencePriceArray
         	
         	//macd just flipped to +
      		if (
      	           fiveMinMacdMinus1Candle >= 0.0
      	           && fiveMinMacdMinus2Candle <= 0.0
      	          
      	     )
      	     {
      	        _shiftMacdStart = TimeCurrent();  
      	        _RESISTANCE_CYCLE = true;
      	        _BULL_CANDLE_COUNTER = 0;    	       
      	        _BEAR_CANDLE_COUNTER = 0; 
      	     }
      	     
            if (_RESISTANCE_CYCLE == true)
            {
               if (minus1CandleClose > minus1CandleOpen)
               {
                  _BULL_CANDLE_COUNTER++;
                  //getBullCandlePercentage();
               }
               if (minus1CandleClose < minus1CandleOpen)
               {
                  _BEAR_CANDLE_COUNTER++;
               }
            }
      	     
         	
         	//macd just flipped to -
         	if (
         	     fiveMinMacdMinus1Candle <= 0.0
         	     && fiveMinMacdMinus2Candle >= 0.0
         	     )
         	     {
         	        _shiftMacdEnd =  TimeCurrent();         	        
         	        _RESISTANCE_CYCLE = false;
         	        
         	        int tmpShiftStart = iBarShift(Sym, PERIOD_M5, _shiftMacdStart, true);
         	        int tmpShiftEnd = iBarShift(Sym, PERIOD_M5, _shiftMacdEnd, true);
         	        
         	        int tmpShiftOfHH = iHighest(Sym, PERIOD_M5, MODE_HIGH, (tmpShiftStart-tmpShiftEnd), tmpShiftEnd);
         	        double tmpPriceOfHH = High[tmpShiftOfHH];
         	        
         	        int tmpTimeOfHHStart = iTime(Sym, PERIOD_M5, tmpShiftStart);
         	        int tmpTimeOfHHEnd = iTime(Sym, PERIOD_M5, tmpShiftEnd);

                    ObjectCreate("resistencesellLine" + _labelIndex,OBJ_TREND,0, tmpTimeOfHHEnd, tmpPriceOfHH, tmpTimeOfHHStart, tmpPriceOfHH );
                    ObjectSet("resistencesellLine" + _labelIndex,OBJPROP_COLOR,Yellow);
                    ObjectSet("resistencesellLine" + _labelIndex,OBJPROP_WIDTH,1);
                    ObjectSet("resistencesellLine" + _labelIndex,OBJPROP_RAY,false);  
                    
                    _LAST_HIGH = tmpPriceOfHH;
                    _LAST_HIGH_SHIFT = tmpShiftOfHH; 
                    
                    //manually fill and shift 34 last high prices
                    //latest price is at 0, 
							_resistencePrices[34] = _resistencePrices[33]; 
							_resistencePrices[33] = _resistencePrices[32]; 
							_resistencePrices[32] = _resistencePrices[31]; 
							_resistencePrices[31] = _resistencePrices[30]; 
							_resistencePrices[30] = _resistencePrices[29]; 
							_resistencePrices[29] = _resistencePrices[28]; 
							_resistencePrices[28] = _resistencePrices[27]; 
							_resistencePrices[27] = _resistencePrices[26]; 
							_resistencePrices[26] = _resistencePrices[25]; 
							_resistencePrices[25] = _resistencePrices[24]; 
							_resistencePrices[24] = _resistencePrices[23]; 
							_resistencePrices[23] = _resistencePrices[22]; 
							_resistencePrices[22] = _resistencePrices[21]; 
							_resistencePrices[21] = _resistencePrices[20];  
							_resistencePrices[20] = _resistencePrices[19];  
							_resistencePrices[19] = _resistencePrices[18];  
							_resistencePrices[18] = _resistencePrices[17];  
							_resistencePrices[17] = _resistencePrices[16];  
							_resistencePrices[16] = _resistencePrices[15];  
							_resistencePrices[15] = _resistencePrices[14];  
							_resistencePrices[14] = _resistencePrices[13];  
							_resistencePrices[13] = _resistencePrices[12];  
							_resistencePrices[12] = _resistencePrices[11];  
							_resistencePrices[11] = _resistencePrices[10];  
							_resistencePrices[10] = _resistencePrices[9];  
							_resistencePrices[9] = _resistencePrices[8];  
							_resistencePrices[8] = _resistencePrices[7];  
							_resistencePrices[7] = _resistencePrices[6];  
							_resistencePrices[6] = _resistencePrices[5];  
							_resistencePrices[5] = _resistencePrices[4];  
							_resistencePrices[4] = _resistencePrices[3];  
							_resistencePrices[3] = _resistencePrices[2];  
							_resistencePrices[2] = _resistencePrices[1];            
							_resistencePrices[1] = _resistencePrices[0];
							_resistencePrices[0] = tmpPriceOfHH;
							
							_resistencePriceCounter++; 
							
							_RESISTANCE_TARGET = tmpPriceOfHH;
							_LAST_AVERAGE_RESISTANCE = (_resistencePrices[0] + _resistencePrices[1])/2;
							//Print("************************ tmpPriceOfHH ", tmpPriceOfHH); 
         	     }
            
            //if prices moves through a level more than n pips, 
            //wipe that level clean, remove from list of levels
            //otherwise leave the level because it represents real S/R
            for (int hh=0; hh<ArraySize(_resistencePrices); hh++)
            {            
               if(minus1CandleClose >= _resistencePrices[hh])// + 10*(10*Point))
               {
                  _resistencePrices[hh] = 100; //this is lazy
               }            
            }
            

             
/* ------------------------- SUPPORT LINES - POS TO NEG TO POS ---------------------------*/
            
            //PURPOSE OF S/R CODE:
            //to find support lines and prevent entries right under these lines

         	//psuedo code         	
         	//when macd rises over 0, store shiftMacdStart
         	//when macd dips below 0, store shiftMacdEnd
         	//and use iHighest to determine the highest price between shiftMacdStart and shiftMacdEnd
         	//store the highest price in the resistencePriceArray
         	
         	//macd just flipped to +
      		if (
						fiveMinMacdMinus1Candle <= 0.0
						&& fiveMinMacdMinus2Candle >= 0.0
      	     )
      	     {
      	        _shiftSupportMacdStart = TimeCurrent();
      	        _SUPPORT_CYCLE = true;      	       
      	     }
      	              	
         	//macd just flipped to -
         	if (
						fiveMinMacdMinus1Candle >= 0.0
						&& fiveMinMacdMinus2Candle <= 0.0         	    
         	     )
         	     {         	     
         	        _SUPPORT_CYCLE = false;
         	        _shiftSupportMacdEnd =  TimeCurrent();         	        
         	        
         	        int tmpSupportShiftStart = iBarShift(Sym, PERIOD_M5, _shiftSupportMacdStart, true);
         	        int tmpSupportShiftEnd = iBarShift(Sym, PERIOD_M5, _shiftSupportMacdEnd, true);
         	        
         	        int tmpSupportShiftOfLL = iLowest(Sym, PERIOD_M5, MODE_LOW, (tmpSupportShiftStart-tmpSupportShiftEnd), tmpSupportShiftEnd);
         	        double tmpSupportPriceOfLL = Low[tmpSupportShiftOfLL];
         	        
         	        int tmpSupportTimeOfLLStart = iTime(Sym, PERIOD_M5, tmpSupportShiftStart);
         	        int tmpSupportTimeOfLLEnd = iTime(Sym, PERIOD_M5, tmpSupportShiftEnd);

                    ObjectCreate("supportsellLine" + _labelIndex,OBJ_TREND,0, tmpSupportTimeOfLLEnd, tmpSupportPriceOfLL, tmpSupportTimeOfLLStart, tmpSupportPriceOfLL );
                    ObjectSet("supportsellLine" + _labelIndex,OBJPROP_COLOR,Aqua);
                    ObjectSet("supportsellLine" + _labelIndex,OBJPROP_WIDTH,1);
                    ObjectSet("supportsellLine" + _labelIndex,OBJPROP_RAY,false);                      
                                        
                    _LAST_LOW = tmpSupportPriceOfLL;
                    _LAST_LOW_SHIFT = tmpSupportShiftOfLL;                    
                                                                 
                    //manually fill and shift 34 last high prices
                    //latest price is at 0, 
							_supportPrices[34] = _supportPrices[33]; 
							_supportPrices[33] = _supportPrices[32]; 
							_supportPrices[32] = _supportPrices[31]; 
							_supportPrices[31] = _supportPrices[30]; 
							_supportPrices[30] = _supportPrices[29]; 
							_supportPrices[29] = _supportPrices[28]; 
							_supportPrices[28] = _supportPrices[27]; 
							_supportPrices[27] = _supportPrices[26]; 
							_supportPrices[26] = _supportPrices[25]; 
							_supportPrices[25] = _supportPrices[24]; 
							_supportPrices[24] = _supportPrices[23]; 
							_supportPrices[23] = _supportPrices[22]; 
							_supportPrices[22] = _supportPrices[21]; 
							_supportPrices[21] = _supportPrices[20];  
							_supportPrices[20] = _supportPrices[19];  
							_supportPrices[19] = _supportPrices[18];  
							_supportPrices[18] = _supportPrices[17];  
							_supportPrices[17] = _supportPrices[16];  
							_supportPrices[16] = _supportPrices[15];  
							_supportPrices[15] = _supportPrices[14];  
							_supportPrices[14] = _supportPrices[13];  
							_supportPrices[13] = _supportPrices[12];  
							_supportPrices[12] = _supportPrices[11];  
							_supportPrices[11] = _supportPrices[10];  
							_supportPrices[10] = _supportPrices[9];  
							_supportPrices[9] = _supportPrices[8];  
							_supportPrices[8] = _supportPrices[7];  
							_supportPrices[7] = _supportPrices[6];  
							_supportPrices[6] = _supportPrices[5];  
							_supportPrices[5] = _supportPrices[4];  
							_supportPrices[4] = _supportPrices[3];  
							_supportPrices[3] = _supportPrices[2];  
							_supportPrices[2] = _supportPrices[1];            
							_supportPrices[1] = _supportPrices[0];
							_supportPrices[0] = tmpSupportPriceOfLL;
							
							_supportPriceCounter++; 
							
							
							_LAST_AVERAGE_SUPPORT = (_supportPrices[0] + _supportPrices[1])/2;						
         	     }
            
            //if prices moves through a level more than n pips, 
            //wipe that level clean, remove from list of levels
            //otherwise leave the level because it represents real S/R
            for (int ss=0; ss<ArraySize(_supportPrices); ss++)
            {            
               if(minus1CandleClose <= _supportPrices[ss])// + 10*(10*Point))
               {
                  _supportPrices[ss] = 100.00; //this is lazy
               }            
            }


/* ------------------------- BEAR FLAG ---------------------------*/
            //scenario: august 5 2012, 23:00, price is rising
            //price spikes up, falls back a little.
            //we see a bunch of candles that wick up, but price repeatedly closes below the halfway mark of the bigger drop
            //this is sellers swamping buyers 
            //this is buyers who are flipping to sell because they realize price is not going up
            //you are seeing demand being absorbed by supply
            //all this followed by a handful of small candles
            //the wick highs are within a couple pips
            if (
                  minus1CandleOpen > minus1CandleClose
                  && (minus1CandleHigh - minus1CandleOpen) <= (minus1CandleOpen - minus1CandleClose)/13  //tiny top wick
                  && minus1CandleLow <= iBands(Sym,0,12,2.23,0,PRICE_HIGH,MODE_BASE,i+1)
               )
               {
                  //strong bear candle found
                  _STRONG_BEAR_CANDLE = true;
                  _STRONG_BEAR_CANDLE_LOW = minus1CandleLow;
                  _STRONG_BEAR_CANDLE_HIGH = minus1CandleHigh;
                  
                  ObjectCreate("strongbear"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
						ObjectSetText("strongbear"+_labelIndex,"Y",12,"Arial",White);
               }
            
            //retire this bear flag...price broke below the low
            //or price closed above the signal bear
            if(
                  minus1CandleClose < _STRONG_BEAR_CANDLE_LOW - 2*(10*Point)//2 pip buffer below low
                  || minus1CandleClose > _STRONG_BEAR_CANDLE_HIGH + 2*(10*Point)
               )
            {
               _STRONG_BEAR_CANDLE = false;
               _SUPPLY_INCREASING = false;
               _MORE_SUPPLY = false;
               _SUPPLY_COUNTER = 0;
            }            
            
            //candles exhibiting buying swamped by selling...increasing supply!!
            if (
                  minus1CandleHigh < _STRONG_BEAR_CANDLE_HIGH
                  && minus1CandleLow >= _STRONG_BEAR_CANDLE_LOW
                  && isShootingStar(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow)==true
               )
            {
               _SUPPLY_COUNTER++;
               _SUPPLY_INCREASING = true;
               _SUPPLY_INCREASING_TIME = TimeCurrent();
                ObjectCreate("strongbear2"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
						ObjectSetText("strongbear2"+_labelIndex,"Y",8,"Arial",White);
            }
            
            if (
                  _SUPPLY_INCREASING == true
                  && Time[i+1] > _SUPPLY_INCREASING_TIME                  
               )
               {
                  if (
                        minus1CandleHigh < _STRONG_BEAR_CANDLE_HIGH
                        && minus1CandleLow >= _STRONG_BEAR_CANDLE_LOW
                        && isShootingStar(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow)==true
                     )
                     {
                        _MORE_SUPPLY = true;
                         ObjectCreate("strongbear3"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
						      ObjectSetText("strongbear3"+_labelIndex,"Y",8,"Arial",Red);
                     }
                  
               }
            
            
/* ------------------------- TRADE LOGIC ---------------------------*/

				//identify the trend
				
				if (_SUPPORT_CYCLE == false)
				{
				ObjectCreate("trendSupportCyc" + _labelIndex,OBJ_TREND,0, _downtrendStartPriceTime, _downtrendStartPrice, Time[i+1], _downtrendEndPrice  );
				ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_COLOR,Purple);
				ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_WIDTH,1);
				ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_RAY,false);
				}

		     	//confirm target
		     	if (  
						//_TARGET_ACQUIRED == true
						//&& _SUPPORT_CYCLE == false
						//&& Time[i+1] > _targetAcquisitionTime	
						minus1CandleClose > fiveMinuteEma160Minus1Candle 
						&& minus1CandleLow > fiveMinEma34Minus1Candle
						
						//price must be greater than last resistance
						&& minus1CandleClose > _RESISTANCE_TARGET
						
						//improves by a couple %
						&& isCandleTopExtraWicky(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow)==false
						&& isCandleTopExtraWicky(minus2CandleOpen, minus2CandleClose, minus2CandleHigh, minus2CandleLow)==false						
						
//						&& volMinus1Candle >= 0.9
						/*
						&& isShootingStar(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow)==false
						&& isShootingStar(minus2CandleOpen, minus2CandleClose, minus2CandleHigh, minus2CandleLow)==false
						&& isShootingStar(minus3CandleOpen, minus3CandleClose, minus3CandleHigh, minus3CandleLow)==false
						&& isShootingStar(minus4CandleOpen, minus4CandleClose, minus4CandleHigh, minus4CandleLow)==false
						&& isShootingStar(minus5CandleOpen, minus5CandleClose, minus5CandleHigh, minus5CandleLow)==false
						&& isShootingStar(minus6CandleOpen, minus6CandleClose, minus6CandleHigh, minus6CandleLow)==false
						&& isShootingStar(minus7CandleOpen, minus7CandleClose, minus7CandleHigh, minus7CandleLow)==false
						*/
//						&& isCandleTopExtraWicky(minus6CandleOpen, minus6CandleClose, minus6CandleHigh, minus6CandleLow)==false						
//						&& isCandleTopExtraWicky(minus7CandleOpen, minus7CandleClose, minus7CandleHigh, minus7CandleLow)==false
						
					//	&& minus1DailyCandleClose > minus1DailyCandleOpen 
						
						&& minus1CandleHigh < iBands(Sym,0,12,2.23,0,PRICE_HIGH,MODE_UPPER,i+1)
						
						//&& minus1CandleClose > minus1CandleOpen this reduces by small %
						
						&& minus1CandleHigh - minus1CandleLow < 30*(Point*10)	//bear monster			
						
						&& !(minus1CandleOpen == minus1CandleClose)

						//check if last 5 candles are trading range type dojis
						&& isRanging(minus2CandleOpen, minus2CandleClose, minus2CandleHigh, minus2CandleLow) == false						
						&& isRanging(minus3CandleOpen, minus3CandleClose, minus3CandleHigh, minus3CandleLow) == false	
						&& isRanging(minus4CandleOpen, minus4CandleClose, minus4CandleHigh, minus4CandleLow) == false	
						&& isRanging(minus5CandleOpen, minus5CandleClose, minus5CandleHigh, minus5CandleLow) == false	
						//&& isRanging(minus6CandleOpen, minus6CandleClose, minus6CandleHigh, minus6CandleLow) == false
						//&& isRanging(minus7CandleOpen, minus7CandleClose, minus7CandleHigh, minus7CandleLow) == false						
						
						//PRICE ACTION - BEAR FLAG
					   && _SUPPLY_COUNTER < 3 
						
						//gap between last price and support...improves but is limiting
						//&& ( minus1CandleClose - getHighestSupportLevel(minus1CandleClose) >= 50*(10*Point) )
						
						//measure if we are clocking higher lows (trending up) during the duration of this resistance cycle
						
						//try candle counting 
						//&& getBullCandlePercentage(_BULL_CANDLE_COUNTER, _BEAR_CANDLE_COUNTER) > 70
						
/*						
						&& !(minus1CandleHigh == minus2CandleHigh)
						&& !(minus2CandleHigh == minus3CandleHigh)
						&& !(minus3CandleHigh == minus4CandleHigh)
						&& !(minus4CandleHigh == minus5CandleHigh)
						&& !(minus5CandleHigh == minus6CandleHigh)
						&& !(minus6CandleHigh == minus7CandleHigh)
*/												
						//13/21 EMA
						&& (
							(minus1CandleClose < fiveMinEma13Minus1Candle && minus1CandleClose > fiveMinEma34Minus1Candle)
							|| (minus1CandleLow < fiveMinEma13Minus1Candle && minus1CandleLow > fiveMinEma34Minus1Candle)
							)
										
					)
					{
						_TARGET_LOCKED = true;
						_TARGET_ACQUIRED = true;//short circuiting	     			    
						_targetConfirmationTime = Time[i+1];
						_targetConfirmationOpen = minus1CandleOpen;
						_targetConfirmationHigh = minus1CandleHigh;
						_targetConfirmationLow = minus1CandleLow;
						_targetConfirmationClose = minus1CandleClose;
						
						ObjectCreate("targetConfirmedbuy"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
						ObjectSetText("targetConfirmedbuy"+_labelIndex,"X",12,"Arial",Red);
						
						//what is last price of support cycle...draw the trendline
						if (	
								_minus1CandleSupportCycleOn == true
								&& 5==8
							)
						{
							_minus1CandleSupportCycleOn = false;					
							_downtrendEndPrice = minus2CandleHigh;							
							
							ObjectCreate("trendSupportCyc" + _labelIndex,OBJ_TREND,0, _downtrendStartPriceTime, _downtrendStartPrice, Time[i+1], _downtrendEndPrice  );
							ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_COLOR,Purple);
							ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_WIDTH,1);
							ObjectSet("trendSupportCyc" + _labelIndex,OBJPROP_RAY,false);
							_lastTrendlineName = "trendSupportCyc" + _labelIndex;
							_lastTrendlineShift = iBarShift(Sym, PERIOD_M5, TimeCurrent(), true);
						}					
			     	}				         			       						

				//target is real		
				if (					
						_TARGET_ACQUIRED == true
						&& _TARGET_LOCKED == true						

						//TRADING WITH THE TREND
						&& minus1CandleClose > fiveMinuteEma160Minus1Candle 	
				)
				{

					//ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],_ask);
					//ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
					//ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);
       
       			printResistenceLevels( minus1CandleClose, TimeCurrent() );
       			printSupportLevels( minus1CandleClose, TimeCurrent() );
       
         		_TARGET_ACQUIRED = false;
         		_TARGET_LOCKED = false;
         		_tradeLeg = 1;
      
         		if(i == 0)//only trade current candle
         		{        
            		if (OrdersTotal() == 0)
            		{                  
               		//open new order            
               		_ticketNumber = OrderSend(Sym,OP_BUY,0.1,_ask,3,0,0,"order #" + _labelIndex,0,0,Green); 
                     _tradeEntryTime = TimeCurrent();
                                  
               		if(_ticketNumber<0)
               		{
                  		Print("Trying to buy. OrderSend failed with error #",GetLastError());
               		}
               		else
               		{               	
                  		//mod ticket
                  		//_TP =  getAdjustedTP(minus1CandleClose);
                  		//_TP=_bid+_takeProfitFactor*(10*_point);
                  		//_TP = getNextHighestResistenceLevel(minus1CandleClose); //do this after the candle closes
                  		_TP=_bid+_takeProfitFactor*(10*_point);
                  		_SL=_bid-_stopLossFactor*(10*_point);
                  		_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                  		_entryPrice = minus1CandleClose;
                  		//Print("entry price is: " + _entryPrice);
                  		Print("OrderModify on a buy last called. Last error was: ",GetLastError());
               		}           
            		}                                             
         		}                    
      		}
                 
      

      //***************** END TARGET ACQUISITION AND ENTRY ******************//       
     
		
		//***************** IF CANDLE/S FOLLOWING ENTRY ARE SHOOTING STARS, SELL OFF QUICKLY ******************//
		if (
				OrdersTotal() == 1  //we are in an order
				//&& isCandleTopExtraWicky(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow)==true //we have a shooting star
				&& TimeCurrent() - _tradeEntryTime == 300
				&& isShootingStar(minus1CandleOpen, minus1CandleClose, minus1CandleHigh, minus1CandleLow)==true
				&& 8==3
		)
		{
				RefreshBidsAndAsks();
				OrderClose(_ticketNumber, 0.1, _bid, 0, Red);			
      		Print("Tried to close this order. Last error was: ",GetLastError());
		}    
		
		 
   	//***************** WE ARE IN AN ORDER AND WE GET DOUBLE TOP HIGHS...EXIT ******************//
		if (
				OrdersTotal() == 1  //we are in an order
				&& (minus1CandleHigh == minus2CandleHigh)
				&& 8==2
		)
		{
				RefreshBidsAndAsks();
				OrderClose(_ticketNumber, 0.1, _bid, 0, Red);			
      		Print("Tried to close this order. Last error was: ",GetLastError());
		}   
      //***************** ADJUST TP AFTER THE ENTRY CANDLE CLOSES ******************//
      
      if(
      		Time[i+1] > _tradeEntryTime
      //		&& 1==3      
				&& OrdersTotal() == 1            		   		
      	)
      	{
      		_TP = getNextHighestSRLevel(minus1CandleClose);
      		//_TP = getAdjustedTP(minus1CandleClose);
      		//_TP = getNextHighestResistenceLevel(minus1CandleClose);
      		//_SL=_entryPrice+5*(10*_point);
      		_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
      		Print("OrderModify after the candle closed. Last error was: ",GetLastError());
      	}
      		
      
      
		//retire the target if it slips below our zone			
		//OR too much time has passed	
		if (  
				 _TARGET_ACQUIRED == true
				 //300 secs per 5 mins
				 && 7== 4
				 && Time[i+1] - _targetConfirmationTime > 3000
				// && _thisZCrossingTime - _lastZCrossingTime > 6000
				  //&& Time[i+1] > _targetConfirmationTime //time must have passed
				  //&& minus1CandleClose <= (_targetAcquisitionLow - 10*(Point*10)) //bottom of zone 
				  
				)
				{				
					_TARGET_ACQUIRED = false;
					_TARGET_LOCKED = false;
				}					
                     
		/*------- last thing you do is update the index --------*/
		_labelIndex++;
	}   
	return(0);
}

double getBullCandlePercentage(double pBulls, double pBears)
{

   if (
         pBulls > 0
         && pBears > 0
         )
         {
            double tmpTotal = pBulls+pBears;            
            double tmpPercentage = NormalizeDouble((pBulls/tmpTotal)*100, 2);
            return(tmpPercentage);
         }
         else
         {
             return(0);
         }
}

//this function is money
double getNextHighestSRLevel(double pPrice)
{
	int foo = ArraySort( _resistencePrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	int tmpArraySize = ArraySize(_resistencePrices);
	double tmpNextRezLine = 0.0;
	for(int k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_resistencePrices[k] > 0
   			&& _resistencePrices[k] > pPrice
   		)
   	{
   		tmpNextRezLine = _resistencePrices[k];
   		break;
   	}
   }
   
  	foo = ArraySort( _supportPrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	tmpArraySize = ArraySize(_supportPrices);
	double tmpNextSupLine = 0.0;
	for(k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_supportPrices[k] > 0
   			&& _supportPrices[k] > pPrice
   		)
   	{
   		tmpNextSupLine = _supportPrices[k];
   		break;
   	}
   } 
   

/*  
   if (tmpNextRezLine == 100)
   {
 	  return (pPrice + (10*(Point*10)));
   }
*/   
   if (tmpNextSupLine >= tmpNextRezLine)
   {
      return (tmpNextRezLine);
   }
   else if (tmpNextSupLine <= tmpNextRezLine)
   {
      return (tmpNextSupLine);
   }
   else //if there is no known resistance, run with 10 pips
   {
   	return (tmpNextSupLine);
      //return (pPrice + (10*(Point*10)));
   }   
}

double getHighestSupportLevel(double pPrice)
{
	int foo = ArraySort( _supportPrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	int tmpArraySize = ArraySize(_supportPrices);
	double tmpNextSRLine = 0.0;
	for(int k=tmpArraySize;k>=0;k--)
   {
   	if (	
   			_supportPrices[k] > 0
   			&& _supportPrices[k] < 100
   			&& _supportPrices[k] < pPrice
   		)
   	{
   		tmpNextSRLine = _supportPrices[k];
   		break;
   	}
   }   
   if (tmpNextSRLine > 0.0)
   {   	
   	return (tmpNextSRLine);
   }
   
   return (0);	//lazy b.s.
}


double getNextHighestResistenceLevel(double pPrice)
{
	int foo = ArraySort( _resistencePrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	int tmpArraySize = ArraySize(_resistencePrices);
	double tmpNextSRLine = 0.0;
	for(int k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_resistencePrices[k] > 0
   			&& _resistencePrices[k] > pPrice
   		)
   	{
   		tmpNextSRLine = _resistencePrices[k];
   		break;
   	}
   }   
   if (tmpNextSRLine > 0.0)
   {   	
   	return (tmpNextSRLine);
   }
   
   return (100);	//lazy b.s.
}

//crazy but...
//subtract entry from S/R level divide by 2 and you get a reasonable TP
//TODO: if you get stopped out try one more time
double getAdjustedTP(double pPrice)
{
	int foo = ArraySort( _resistencePrices, WHOLE_ARRAY, 0, MODE_ASCEND);
	int tmpArraySize = ArraySize(_resistencePrices);
	double tmpNextSRLine = 0.0;
	for(int k=0;k<tmpArraySize;k++)
   {
   	if (	
   			_resistencePrices[k] > 0
   			&& _resistencePrices[k] > pPrice
   		)
   	{
   		tmpNextSRLine = _resistencePrices[k];
   		break;
   	}
   }
   
   if (tmpNextSRLine > 0.0)
   {
   	return ( ((tmpNextSRLine - pPrice) / 2) + pPrice);
   }
   
   //return the default TP
   return (_bid+_takeProfitFactor*(10*_point));	
   
}

//13 works good
//if price is within  N pips of known resistence, do not enter trade
int _resistenceZone = 13;
int _resCounter = 0;
void printResistenceLevels(double pPrice, datetime pDate)
{
	int tmpArraySize = ArraySize(_resistencePrices);
   
   for(int k=0;k<tmpArraySize;k++)
   { 
			int tmpShift = iBarShift(Sym, PERIOD_M5, pDate, true);
			int tmpTime = iTime(Sym, PERIOD_M5, tmpShift);
			ObjectCreate("resistencebuysellline"+_resCounter,OBJ_ARROW,0,tmpTime, _resistencePrices[k]);
         ObjectSet("resistencebuysellline"+_resCounter, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
         ObjectSet("resistencebuysellline"+_resCounter,OBJPROP_COLOR,Yellow); 
			_resCounter++;
   }
}


int _supportZone = 13;
int _supCounter = 0;
void printSupportLevels(double pPrice, datetime pDate)
{
	int tmpArraySize = ArraySize(_supportPrices);
   
   for(int k=0;k<tmpArraySize;k++)
   { 
			int tmpShift = iBarShift(Sym, PERIOD_M5, pDate, true);
			int tmpTime = iTime(Sym, PERIOD_M5, tmpShift);
			ObjectCreate("supportbuysellline"+_supCounter,OBJ_ARROW,0,tmpTime, _supportPrices[k]);
         ObjectSet("supportbuysellline"+_supCounter, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
         ObjectSet("supportbuysellline"+_supCounter,OBJPROP_COLOR,Aqua); 
			_supCounter++;
   }
}


int getNumberOfResistenceLevels()
{
	int tmpArraySize = ArraySize(_resistencePrices);
	int tmpRezCount = 0;
   
   for(int k=0;k<tmpArraySize;k++)
   { 
			if( _resistencePrices[k] > 1 &&  _resistencePrices[k] < 100)
			{
			   tmpRezCount++;
			}
   }
   return (tmpRezCount);
}


//if price is within N pips of resistence, do not enter trade 
bool imminentResistence(double priceToTest)
{
   int tmpArraySize = ArraySize(_resistencePrices);
   
   for(int k=0;k<tmpArraySize;k++)
   {
      if (     		
      		_resistencePrices[k] - priceToTest <= _resistenceZone*(10*Point)     
      		&& _resistencePrices[k] - priceToTest > 0.0 
      		//and we're not sitting in a nest of rez prices
      		&& priceToTest - _resistencePrices[k] > 5*(10*Point)
      	)
      {  
         
         return (true);
      }
   }

   return (false);
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

int candleSpreadGreaterThanNPips(double pHigh, double pLow, double pSpread)
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


bool isCandleTopExtraWicky(double pOpen, double pClose, double pHigh, double pLow)
{
   if (
         (pClose > pOpen && pClose - pOpen <= (pHigh - pLow)/3)
         ||
         (pClose < pOpen && pOpen - pClose <= (pHigh - pLow)/3)
		 )
		 {
         return (true);
       }
       else
       {
         return(false);
       }
}

bool isShootingStar(double pOpen, double pClose, double pHigh, double pLow)
{
   if (
         (pClose > pOpen && ((pHigh - pClose) >= pClose - pOpen))
         ||
         (pClose < pOpen && ((pHigh - pOpen) >=  pOpen - pClose))
		 )
		 {
         return (true);
       }
       else
       {
         return(false);
       }
}

//this is one type of range
//it has a 2 pip body and fairly even wicks
bool isRanging(double pOpen, double pClose, double pHigh, double pLow)
{
		int _wickTopPercent;
		int _wickBottomPercent;
		double bodySize;
 
		if (pOpen < pClose)//bullish candle
		{		
			bodySize = pClose - pOpen;
		
			_wickTopPercent = ((pHigh - pClose)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pOpen - pLow)/(pHigh - pLow)) * 100;
		}
		else if (pOpen > pClose) //bearish candle
		{
			bodySize = pOpen - pClose;
			
			_wickTopPercent = ((pHigh - pOpen)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pClose - pLow)/(pHigh - pLow)) * 100;
		}
		else //open and close are the same
		{
			return (true);
		}


   if (
         _wickTopPercent >= 33
		   && _wickBottomPercent >= 33
      )
      {
         return(true);
      }

   return (false);
}

