/*
	arlo emerson, 4/18/2014
	
	algo overview:
	use on 5 min charts.
	this is based on the water dam method of identifying support and resistance.
	
	support:
	look for a single strong bear candle that causes MACD to go negative.
	verify trading previous to this candle was sideways. 
	note the median price of the S/R zone and draw a line
	wait for a strong bull to close above the median price of the sideways zone previously identified (target S/R price)
*/

//globally adjust tp/sl
double _stopLossFactor = 8;
double _takeProfitFactor = 47;

extern int  TimeFrame		= 5;

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
double _targetMedianPrice;
					

bool _minus1CandleSupportCycleOn = false;
double _downtrendStartPrice;
double _downtrendEndPrice;
int _downtrendStartPriceTime;
string _lastTrendlineName;
int _lastTrendlineShift;


double _candidateLeftWallPrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00};
int _candidateLeftWallIndex[34] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int _candidateLeftWallTime[34] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int _candidateLeftWallPricesCounter = 0;


int _candidateLeftWallUniqueID = 0;
double _candidateLeftWallPrice;


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
   	

	double macd1 = iMACD(NULL,0,5,8,9,PRICE_CLOSE,MODE_MAIN,i+1);
	double macd2 = iMACD(NULL,0,5,8,9,PRICE_CLOSE,MODE_MAIN,i+2);
	double macd3 = iMACD(NULL,0,5,8,9,PRICE_CLOSE,MODE_MAIN,i+3);
	double macd4 = iMACD(NULL,0,5,8,9,PRICE_CLOSE,MODE_MAIN,i+4);


      RefreshBidsAndAsks();

		
//***************** IDENTIFY LEFT WALL OF DAM CANDIDATES ******************//
		
		//shaved top bear candle
		if (	(minus1CandleOpen == minus1CandleHigh &&
				minus1CandleOpen > minus1CandleClose)
				||
				(//or a very small wick at top
				(minus1CandleHigh - minus1CandleOpen) <= 0.5*(10*Point) &&
				minus1CandleOpen > minus1CandleClose
				)
				
				)
				{
					//draw a temporary line from shaved top to infinity					
					//ObjectCreate("leftWallCandidateLine" + _labelIndex,OBJ_TREND,0, minus1CandleIndex, minus1CandleHigh, minus1CandleIndex+2, minus1CandleHigh );
					//ObjectSet("leftWallCandidateLine" + _labelIndex,OBJPROP_COLOR,Yellow);
					//ObjectSet("leftWallCandidateLine" + _labelIndex,OBJPROP_WIDTH,1);
					//ObjectSet("leftWallCandidateLine" + _labelIndex,OBJPROP_RAY,true);
					ObjectCreate("leftWallCandidateLine"+_labelIndex,OBJ_ARROW,0,minus1CandleIndex, minus1CandleHigh);
					ObjectSet("leftWallCandidateLine"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
					ObjectSet("leftWallCandidateLine"+_labelIndex,OBJPROP_COLOR,0x333333);

					
					
					//go back in time to see if MACD was flat
					if( (macd1 + macd2 + macd3 + macd4)/4 <0.21)
					{
						//macd was flat
						//set the median price of this zone
						_targetMedianPrice = (iClose(NULL,TimeFrame,1) + iClose(NULL,TimeFrame,2) + iClose(NULL,TimeFrame,3) + iClose(NULL,TimeFrame,4))/4;											
					}						
				}	

//***************** IDENTIFY RIGHT WALL OF DAM CANDIDATES ******************//

	//simply look for a strong bull closing above _targetMedianPrice
		
		
      	//bull candle opens below and closes above left dam wall
	if (	minus1CandleOpen < minus1CandleClose &&
			minus1CandleOpen < _targetMedianPrice &&
			minus1CandleClose > _targetMedianPrice &&
			//body size is healthy
			minus1CandleClose - minus1CandleOpen >= 4*(10*Point)
		)
		{
			ObjectCreate("rightWallCandidateLine"+_labelIndex,OBJ_ARROW,0,minus1CandleIndex, minus1CandleClose);
			ObjectSet("rightWallCandidateLine"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_CHECKSIGN);
			ObjectSet("rightWallCandidateLine"+_labelIndex,OBJPROP_COLOR,Red); 					
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


