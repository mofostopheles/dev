//arlo emerson, 9/3/2012

//added indicator for A/D cycle...the question is: how can you use it?

//also testing only trade entries if the number of resistence levels is over 3.

//globally adjust tp/sl
double _stopLossFactor = 10;
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

string _labelName1 = "volumeArrow";
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

double _resistencePrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00}; //list for storing prices where resistence occurs
int _resistencePriceCounter = 0;

double _zeroMacdPrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00}; //list for storing prices where resistence occurs
int _zeroMacdPriceCounter = 0;

int _shiftMacdStart, _shiftMacdEnd;
int _shiftZeroMacdStart, _shiftZeroMacdEnd;

int _tradeLeg = 0; //we count legs or our trades, currently we only do 2 legs per entry

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
				
         	//larger timeframe candles
         	double fiveMinMinus1CandleClose = iClose(NULL,PERIOD_M5, shift1 + 1 );
         	double hourlyMinus1CandleClose = iClose(NULL,PERIOD_H1, hourlyShift + 1 );
         	double fourHourlyMinus1CandleClose = iClose(NULL,PERIOD_H4, fourHourlyShift + 1 );
         	
         	//MACD
         	double fiveMinMacdMinus1Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+1);
         	double fiveMinMacdMinus2Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+2);
         	double fiveMinMacdMinus3Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+3);
         	double fiveMinMacdMinus4Candle = iMACD(Sym, PERIOD_M5, 5, 8, 9, PRICE_CLOSE, MODE_EMA, shift1+4);
        
/* ------------------------- S/R LINES - NEG TO POS TO NEG ---------------------------*/
            
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
      	     }
      	     
         	
         	//macd just flipped to -
         	if (
         	     fiveMinMacdMinus1Candle <= 0.0
         	     && fiveMinMacdMinus2Candle >= 0.0
         	     )
         	     {
         	        _shiftMacdEnd =  TimeCurrent();         	        
         	        
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
							//Print("************************ tmpPriceOfHH ", tmpPriceOfHH); 
         	     }
            
            //if prices moves through a level more than 10 pips, 
            //wipe that level clean, remove from list of levels
            //otherwise leave the level because it represents real S/R
            for (int hh=0; hh<ArraySize(_resistencePrices); hh++)
            {            
               if(minus1CandleClose >= _resistencePrices[hh] + 10*(10*Point))
               {
                  _resistencePrices[hh] = 100.00; //this is lazy
               }            
            }


/* ------------------------- BARBED WIRE MACD ---------------------------*/


			if (
					fiveMinMacdMinus1Candle > -0.000020
					&& fiveMinMacdMinus1Candle < -0.0
				)
				{
					ObjectCreate("barbedbuysell"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
         		ObjectSetText("barbedbuysell"+_labelIndex,"AD1",7,"Arial",Orange);
				}
				
			if (
					fiveMinMacdMinus1Candle > 0.0
					&& fiveMinMacdMinus1Candle < 0.000020
				)
				{
					ObjectCreate("barbedbuysell"+_labelIndex,OBJ_TEXT,0,Time[i+1],minus1CandleLow);
         		ObjectSetText("barbedbuysell"+_labelIndex,"AD2",7,"Arial",Orange);
				}




//let's mark up the chart with MACD flips that the above code is missing.
//above code is missing some key stairstep drops in price because MACD is not flipping in a switch-like fashion
//the barb wire is also where the A/D is really happening. my entries are often a little late to the party.
/*
      		if (
      	           fiveMinMacdMinus2Candle > 0.0
      	           && fiveMinMacdMinus1Candle < 0.0
      	           && fiveMinMacdMinus1Candle > -0.000020
      	     )
      	     {
      	        _shiftZeroMacdStart = TimeCurrent();      	       
      	     }
      	     
         	
         	//macd just flipped to -
         	if (
							fiveMinMacdMinus2Candle < 0.0
							&& fiveMinMacdMinus1Candle > 0.0
							&& fiveMinMacdMinus1Candle < 0.000020
         	     )
         	     {
         	        _shiftZeroMacdEnd =  TimeCurrent();         	        
         	        
         	        int tmpZShiftStart = iBarShift(Sym, PERIOD_M5, _shiftZeroMacdStart, true);
         	        int tmpZShiftEnd = iBarShift(Sym, PERIOD_M5, _shiftZeroMacdEnd, true);
         	        
         	        int tmpZShiftOfzhh = iHighest(Sym, PERIOD_M5, MODE_HIGH, (tmpZShiftStart-tmpZShiftEnd), tmpZShiftEnd);
         	        double tmpZPriceOfzhh = High[tmpZShiftOfzhh];
         	        
         	        int tmpZTimeOfzhhStart = iTime(Sym, PERIOD_M5, tmpZShiftStart);
         	        int tmpZTimeOfzhhEnd = iTime(Sym, PERIOD_M5, tmpZShiftEnd);

                    ObjectCreate("zeroMACDsellLine" + _labelIndex,OBJ_TREND,0, tmpZTimeOfzhhEnd, tmpZPriceOfzhh, tmpZTimeOfzhhStart, tmpZPriceOfzhh );
                    ObjectSet("zeroMACDsellLine" + _labelIndex,OBJPROP_COLOR,Purple);
                    ObjectSet("zeroMACDsellLine" + _labelIndex,OBJPROP_WIDTH,1);
                    ObjectSet("zeroMACDsellLine" + _labelIndex,OBJPROP_RAY,false);  
                    
                    //manually fill and shift 34 last high prices
                    //latest price is at 0, 
							_zeroMacdPrices[34] = _zeroMacdPrices[33]; 
							_zeroMacdPrices[33] = _zeroMacdPrices[32]; 
							_zeroMacdPrices[32] = _zeroMacdPrices[31]; 
							_zeroMacdPrices[31] = _zeroMacdPrices[30]; 
							_zeroMacdPrices[30] = _zeroMacdPrices[29]; 
							_zeroMacdPrices[29] = _zeroMacdPrices[28]; 
							_zeroMacdPrices[28] = _zeroMacdPrices[27]; 
							_zeroMacdPrices[27] = _zeroMacdPrices[26]; 
							_zeroMacdPrices[26] = _zeroMacdPrices[25]; 
							_zeroMacdPrices[25] = _zeroMacdPrices[24]; 
							_zeroMacdPrices[24] = _zeroMacdPrices[23]; 
							_zeroMacdPrices[23] = _zeroMacdPrices[22]; 
							_zeroMacdPrices[22] = _zeroMacdPrices[21]; 
							_zeroMacdPrices[21] = _zeroMacdPrices[20];  
							_zeroMacdPrices[20] = _zeroMacdPrices[19];  
							_zeroMacdPrices[19] = _zeroMacdPrices[18];  
							_zeroMacdPrices[18] = _zeroMacdPrices[17];  
							_zeroMacdPrices[17] = _zeroMacdPrices[16];  
							_zeroMacdPrices[16] = _zeroMacdPrices[15];  
							_zeroMacdPrices[15] = _zeroMacdPrices[14];  
							_zeroMacdPrices[14] = _zeroMacdPrices[13];  
							_zeroMacdPrices[13] = _zeroMacdPrices[12];  
							_zeroMacdPrices[12] = _zeroMacdPrices[11];  
							_zeroMacdPrices[11] = _zeroMacdPrices[10];  
							_zeroMacdPrices[10] = _zeroMacdPrices[9];  
							_zeroMacdPrices[9] = _zeroMacdPrices[8];  
							_zeroMacdPrices[8] = _zeroMacdPrices[7];  
							_zeroMacdPrices[7] = _zeroMacdPrices[6];  
							_zeroMacdPrices[6] = _zeroMacdPrices[5];  
							_zeroMacdPrices[5] = _zeroMacdPrices[4];  
							_zeroMacdPrices[4] = _zeroMacdPrices[3];  
							_zeroMacdPrices[3] = _zeroMacdPrices[2];  
							_zeroMacdPrices[2] = _zeroMacdPrices[1];            
							_zeroMacdPrices[1] = _zeroMacdPrices[0];
							_zeroMacdPrices[0] = tmpZPriceOfzhh;
							
							_zeroMacdPriceCounter++; 
							//Print("************************ tmpZPriceOfzhh ", tmpZPriceOfzhh); 
         	     }
            
            //if prices moves through a level more than 10 pips, 
            //wipe that level clean, remove from list of levels
            //otherwise leave the level because it represents real S/R
            for (int zhh=0; zhh<ArraySize(_zeroMacdPrices); zhh++)
            {            
               if(minus1CandleClose >= _zeroMacdPrices[zhh] + 10*(10*Point))
               {
                  _zeroMacdPrices[zhh] = 100.00; //this is lazy
               }            
            }

     */       
            
/* ------------------------- TRADE LOGIC ---------------------------*/

				//acquire a target				
				if(	//does price cross above and test the 160 EMA?
						//do the larger timeframes close above the 160 EMA?
						//if yes, support (demand) is at this price
					//	minus1CandleClose > fiveMinuteEma160Minus1Candle 
					//	&& minus2CandleLow < fiveMinuteEma160Minus2Candle 			
					//	&& hourlyMinus1CandleClose > hourlyEma160Minus1Candle
					//	&& fourHourlyMinus1CandleClose > fourHourEma160Minus1Candle		
              ((fiveMinMacdMinus1Candle > -0.000020 && fiveMinMacdMinus1Candle < -0.0)
              || (fiveMinMacdMinus1Candle > 0.0 && fiveMinMacdMinus1Candle < 0.000020))																						
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
						//open air -- believe it or not this improves profitability by a couple percent
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
						//gap must be less than n pips
						&& minus1CandleClose - _targetAcquisitionClose <= 17*(10*Point)
												
						//METHOD TO PREVENT ENTRIES IF WE ARE RIGHT UNDERNEATH RESISTENCE
						&& imminentResistence(minus1CandleClose) == false															
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
         		
               printResistenceLevels( minus1CandleClose, TimeCurrent() );
				}
				
				//target is real, price has broken free of the 34 EMA		
				if (					
						_TARGET_ACQUIRED == true
						&& _TARGET_LOCKED == true
						//&& getNumberOfResistenceLevels() > 3
						//&& Time[i+1] > _targetConfirmationTime //time must have passed so a retest can occur	
				)
				{
					ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],_ask);
					ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
					ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);

         		//Print("attempting to buy at ", _ask, " i is ", i, " and OrdersTotal=", OrdersTotal());         
         		_TARGET_ACQUIRED = false;
         		_TARGET_LOCKED = false;
         		_tradeLeg = 1;
      
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
                  		//_TP=_bid+_takeProfitFactor*(10*_point);
                  		_TP = calculateTP(minus1CandleClose);
                  		_SL=_bid-_stopLossFactor*(10*_point);                  
                  		_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                  		_entryPrice = minus1CandleClose;
                  		//Print("entry price is: " + _entryPrice);
                  		Print("OrderModify on a buy last called. Last error was: ",GetLastError());
               		}           
            		}                                             
         		}                    
      		}
      		else if (  1==9
            		)
      		{
                  ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i],open);
                  ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);   
               
                  //--------SELL ORDER---------//
                  if(i==0)//only trade current candle
                  {     
                     if (OrdersTotal() == 0)//open new order because one isn't open
                     {
                     	_entryPrice = _bid;
                        _ticketNumber = OrderSend(Sym,OP_SELL,0.1,_bid,3,0,0,"order #" + _labelIndex,0,0,Red);               
                        if(_ticketNumber<0)
                        {
                           Print("OrderSend on a sell failed with error #",GetLastError());
                        }
                        else
                        {
                           //mod ticket
                           _TP=_bid+_takeProfitFactor*(10*_point);
                           _SL=_bid-_stopLossFactor*(10*_point);
                           _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                           
                           //Print("entry price is: " + _entryPrice);
                           Print("OrderModify on a buy last called. Last error was: ",GetLastError());
                        }
                     }
                  }                    
      }

      //***************** END TARGET ACQUISITION AND ENTRY ******************//       
      
		//retire the target if it slips below our zone			
		//OR too much time has passed	
		if (  
				 _TARGET_ACQUIRED == true
				  && Time[i+1] > _targetConfirmationTime //time must have passed
				  && minus1CandleClose <= (_targetAcquisitionLow - 10*(Point*10)) //bottom of zone 
				)
				{				
					_TARGET_ACQUIRED = false;
					_TARGET_LOCKED = false;
				}					
      
      /*------- BEGIN MONEY MANAGEMENT -------- 
      //N pips advance - tighten up the SL
         if (
               minus1CandleClose >= (_entryPrice + 15*(_point*10))
               && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 3*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }
      */
      

//stop writing code that mimicks dumb money


		//***************** RE-ENTER THE TRADE IF WE GET A NEW TARGET ******************// 
		/*
		if (
				OrdersTotal() == 0
				&& _tradeLeg == 1
				&& _TARGET_ACQUIRED == true	
			)
			{
				if(OrderSelect(_ticketNumber, SELECT_BY_TICKET)==true)
				{
					if ( OrderProfit() >= 10*(10*Point) )
					{
						//open new order            
						_ticketNumber = OrderSend(Sym,OP_BUY,0.1,_ask,3,0,0,"order #" + _labelIndex,0,0,Purple); 
						_tradeLeg = 2;
		                            
						if(_ticketNumber<0)
						{
   						Print("Trying to buy. OrderSend failed with error #",GetLastError());
						}
						else //mod ticket
						{               	            		
   						//new TP is (minus1CandleClose - old entryPrice) + minus1CandleClose
   						_TP=_bid+20*(10*_point);
   						_SL=_bid-_stopLossFactor*(10*_point);                  
   						_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
   						_entryPrice = minus1CandleClose;
   						Print("OrderModify on a buy last called. Last error was: ",GetLastError());
						}
					}
				}    
			}
      */
      

		//***************** RE-ENTER THE TRADE IF THE TREND IS STRONG ******************//  
		/*    
		if (OrdersTotal() == 0 && _tradeLeg == 1) //no order, we just took profit and exited
		{		
			if(OrderSelect(_ticketNumber, SELECT_BY_TICKET)==true)
			{
				if ( OrderProfit() >= 10*(10*Point) )
				{
					//if price is under our TP, then next price closes over the TP, re-enter
					if (
							minus2CandleClose < _TP
							&& minus1CandleClose > _TP
							&& imminentResistence(minus1CandleClose) == false	
						)
						{
							//open new order            
         				_ticketNumber = OrderSend(Sym,OP_BUY,0.1,_ask,3,0,0,"order #" + _labelIndex,0,0,Green); 
							_tradeLeg = 2;
					                            
         				if(_ticketNumber<0)
         				{
            				Print("Trying to buy. OrderSend failed with error #",GetLastError());
         				}
         				else //mod ticket
         				{               	            		
            				//new TP is (minus1CandleClose - old entryPrice) + minus1CandleClose
            				_TP = (minus1CandleClose - _entryPrice) + minus1CandleClose;
            				_SL=_bid-_stopLossFactor*(10*_point);                  
            				_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
            				_entryPrice = minus1CandleClose;
            				//Print("entry price is: " + _entryPrice);
            				Print("OrderModify on a buy last called. Last error was: ",GetLastError());
         				}    
               						
						}					
				}
			}			
		}
		*/
		if (OrdersTotal() == 0 && _tradeLeg == 2)
		{
			_tradeLeg = 0;
		}
		
      //***************** END TREND RE-ENTRY ******************//  
                         
		/*------- last thing you do is update the index --------*/
		_labelIndex++;
	}   
	return(0);
}

//crazy but...
//subtract entry from S/R level divide by 2 and you get a reasonable TP
//TODO: if you get stopped out try one more time
double calculateTP(double pPrice)
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
      		&& priceToTest - _resistencePrices[k] > 13*(10*Point)
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


