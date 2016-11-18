//arlo emerson, 11/12/2014
//modified 5/25/2015

//old notes:
//experiment to see what chart looks like if we:
//draw a line from every high, terminating that line when it's superceded
//result will remain a water dam analysis but will be all inclusive

//this is a slight variation from the v2, where here we are going to lookback then look forward, 
//where v2 looked back only.

//new notes:




//globally adjust tp/sl
double _stopLossFactor = 8;
double _takeProfitFactor = 47;
int _lookback = 1000; //how many candles back in time do we check

extern int  TimeFrame		= 0;

string Sym = "";

string _labelName1 = "trend";
string _labelName2 = "hhll_";

string _previousLabel = "";

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


bool _minus1CandleSupportCycleOn = false;
double _downtrendStartPrice;
double _downtrendEndPrice;
int _downtrendStartPriceTime;
string _lastTrendlineName;
int _lastTrendlineShift;

int _PRICES_BUFFER = 34;

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



int start()
{
   _firstRun = true;
   _lastAlertTime = Time[0];
   
   //start in the past and then look foward
   for(int i = _lookback; i > 0; i--)
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
			
  		int minus1CandleTime = iTime(NULL,TimeFrame,i);
   	int minus1CandleIndex = iTime(NULL,TimeFrame,i);
   	double minus1CandleOpen = iOpen(NULL,TimeFrame,i);
   	double minus1CandleClose = iClose(NULL,TimeFrame,i);
   	double minus1CandleLow = iLow(NULL,TimeFrame,i);
   	double minus1CandleHigh = iHigh(NULL,TimeFrame,i);

      RefreshBidsAndAsks();
		
		
		int tmpIndexOfHigherCandle = 0; 
		
		//loop FOWARD N candles based on whatever candle i'm on now
		for (int b=1;b<500;b++)
		{
			//continue the line if high is higher than the candle we are looping
			if ((iHigh(NULL,TimeFrame,i - b) > minus1CandleHigh) && (minus1CandleClose == minus1CandleHigh))
			{
				tmpIndexOfHigherCandle = b;
				break;
				
			}		
		}
		
		if (tmpIndexOfHigherCandle>0)
		{
			ObjectCreate("supportDamLine" + _labelIndex,OBJ_TREND,0, minus1CandleTime, minus1CandleHigh, iTime(NULL,TimeFrame, i - tmpIndexOfHigherCandle), minus1CandleHigh );
			ObjectSet("supportDamLine" + _labelIndex,OBJPROP_COLOR,Aqua);
			ObjectSet("supportDamLine" + _labelIndex,OBJPROP_WIDTH,1);
			ObjectSet("supportDamLine" + _labelIndex,OBJPROP_RAY,false);  
		}
								
//***************** LAST THING YOU DO IS UPDATE THE INDEX  ******************//
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


