//arlo emerson, 5/25/2015

/*
   inspired by water dam formations, this is an attempt to classify candles into one of three camps:
   up, down and sideways.
   
   we do this based on relative price motion. in this model, price doesn't inch up and down, it moves sideways. 
   price moves up or down when it breaks the pattern, resembling a more binary standard deviation representation.
   
   this is a way to reduce noise, which is of paramount concern. 
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

					//manually fill and shift 34 last high prices
					//latest price is at 0, 
					_candidateLeftWallPrices[34] = _candidateLeftWallPrices[33]; 
					_candidateLeftWallPrices[33] = _candidateLeftWallPrices[32]; 
					_candidateLeftWallPrices[32] = _candidateLeftWallPrices[31]; 
					_candidateLeftWallPrices[31] = _candidateLeftWallPrices[30]; 
					_candidateLeftWallPrices[30] = _candidateLeftWallPrices[29]; 
					_candidateLeftWallPrices[29] = _candidateLeftWallPrices[28]; 
					_candidateLeftWallPrices[28] = _candidateLeftWallPrices[27]; 
					_candidateLeftWallPrices[27] = _candidateLeftWallPrices[26]; 
					_candidateLeftWallPrices[26] = _candidateLeftWallPrices[25]; 
					_candidateLeftWallPrices[25] = _candidateLeftWallPrices[24]; 
					_candidateLeftWallPrices[24] = _candidateLeftWallPrices[23]; 
					_candidateLeftWallPrices[23] = _candidateLeftWallPrices[22]; 
					_candidateLeftWallPrices[22] = _candidateLeftWallPrices[21]; 
					_candidateLeftWallPrices[21] = _candidateLeftWallPrices[20];  
					_candidateLeftWallPrices[20] = _candidateLeftWallPrices[19];  
					_candidateLeftWallPrices[19] = _candidateLeftWallPrices[18];  
					_candidateLeftWallPrices[18] = _candidateLeftWallPrices[17];  
					_candidateLeftWallPrices[17] = _candidateLeftWallPrices[16];  
					_candidateLeftWallPrices[16] = _candidateLeftWallPrices[15];  
					_candidateLeftWallPrices[15] = _candidateLeftWallPrices[14];  
					_candidateLeftWallPrices[14] = _candidateLeftWallPrices[13];  
					_candidateLeftWallPrices[13] = _candidateLeftWallPrices[12];  
					_candidateLeftWallPrices[12] = _candidateLeftWallPrices[11];  
					_candidateLeftWallPrices[11] = _candidateLeftWallPrices[10];  
					_candidateLeftWallPrices[10] = _candidateLeftWallPrices[9];  
					_candidateLeftWallPrices[9] = _candidateLeftWallPrices[8];  
					_candidateLeftWallPrices[8] = _candidateLeftWallPrices[7];  
					_candidateLeftWallPrices[7] = _candidateLeftWallPrices[6];  
					_candidateLeftWallPrices[6] = _candidateLeftWallPrices[5];  
					_candidateLeftWallPrices[5] = _candidateLeftWallPrices[4];  
					_candidateLeftWallPrices[4] = _candidateLeftWallPrices[3];  
					_candidateLeftWallPrices[3] = _candidateLeftWallPrices[2];  
					_candidateLeftWallPrices[2] = _candidateLeftWallPrices[1];            
					_candidateLeftWallPrices[1] = _candidateLeftWallPrices[0];
					_candidateLeftWallPrices[0] = minus1CandleHigh;
					
					_candidateLeftWallTime[34] = _candidateLeftWallTime[33]; 
					_candidateLeftWallTime[33] = _candidateLeftWallTime[32]; 
					_candidateLeftWallTime[32] = _candidateLeftWallTime[31]; 
					_candidateLeftWallTime[31] = _candidateLeftWallTime[30]; 
					_candidateLeftWallTime[30] = _candidateLeftWallTime[29]; 
					_candidateLeftWallTime[29] = _candidateLeftWallTime[28]; 
					_candidateLeftWallTime[28] = _candidateLeftWallTime[27]; 
					_candidateLeftWallTime[27] = _candidateLeftWallTime[26]; 
					_candidateLeftWallTime[26] = _candidateLeftWallTime[25]; 
					_candidateLeftWallTime[25] = _candidateLeftWallTime[24]; 
					_candidateLeftWallTime[24] = _candidateLeftWallTime[23]; 
					_candidateLeftWallTime[23] = _candidateLeftWallTime[22]; 
					_candidateLeftWallTime[22] = _candidateLeftWallTime[21]; 
					_candidateLeftWallTime[21] = _candidateLeftWallTime[20];  
					_candidateLeftWallTime[20] = _candidateLeftWallTime[19];  
					_candidateLeftWallTime[19] = _candidateLeftWallTime[18];  
					_candidateLeftWallTime[18] = _candidateLeftWallTime[17];  
					_candidateLeftWallTime[17] = _candidateLeftWallTime[16];  
					_candidateLeftWallTime[16] = _candidateLeftWallTime[15];  
					_candidateLeftWallTime[15] = _candidateLeftWallTime[14];  
					_candidateLeftWallTime[14] = _candidateLeftWallTime[13];  
					_candidateLeftWallTime[13] = _candidateLeftWallTime[12];  
					_candidateLeftWallTime[12] = _candidateLeftWallTime[11];  
					_candidateLeftWallTime[11] = _candidateLeftWallTime[10];  
					_candidateLeftWallTime[10] = _candidateLeftWallTime[9];  
					_candidateLeftWallTime[9] = _candidateLeftWallTime[8];  
					_candidateLeftWallTime[8] = _candidateLeftWallTime[7];  
					_candidateLeftWallTime[7] = _candidateLeftWallTime[6];  
					_candidateLeftWallTime[6] = _candidateLeftWallTime[5];  
					_candidateLeftWallTime[5] = _candidateLeftWallTime[4];  
					_candidateLeftWallTime[4] = _candidateLeftWallTime[3];  
					_candidateLeftWallTime[3] = _candidateLeftWallTime[2];  
					_candidateLeftWallTime[2] = _candidateLeftWallTime[1];            
					_candidateLeftWallTime[1] = _candidateLeftWallTime[0];
					_candidateLeftWallTime[0] = minus1CandleTime;
					
					_candidateLeftWallIndex[34] = _candidateLeftWallIndex[33]; 
					_candidateLeftWallIndex[33] = _candidateLeftWallIndex[32]; 
					_candidateLeftWallIndex[32] = _candidateLeftWallIndex[31]; 
					_candidateLeftWallIndex[31] = _candidateLeftWallIndex[30]; 
					_candidateLeftWallIndex[30] = _candidateLeftWallIndex[29]; 
					_candidateLeftWallIndex[29] = _candidateLeftWallIndex[28]; 
					_candidateLeftWallIndex[28] = _candidateLeftWallIndex[27]; 
					_candidateLeftWallIndex[27] = _candidateLeftWallIndex[26]; 
					_candidateLeftWallIndex[26] = _candidateLeftWallIndex[25]; 
					_candidateLeftWallIndex[25] = _candidateLeftWallIndex[24]; 
					_candidateLeftWallIndex[24] = _candidateLeftWallIndex[23]; 
					_candidateLeftWallIndex[23] = _candidateLeftWallIndex[22]; 
					_candidateLeftWallIndex[22] = _candidateLeftWallIndex[21]; 
					_candidateLeftWallIndex[21] = _candidateLeftWallIndex[20];  
					_candidateLeftWallIndex[20] = _candidateLeftWallIndex[19];  
					_candidateLeftWallIndex[19] = _candidateLeftWallIndex[18];  
					_candidateLeftWallIndex[18] = _candidateLeftWallIndex[17];  
					_candidateLeftWallIndex[17] = _candidateLeftWallIndex[16];  
					_candidateLeftWallIndex[16] = _candidateLeftWallIndex[15];  
					_candidateLeftWallIndex[15] = _candidateLeftWallIndex[14];  
					_candidateLeftWallIndex[14] = _candidateLeftWallIndex[13];  
					_candidateLeftWallIndex[13] = _candidateLeftWallIndex[12];  
					_candidateLeftWallIndex[12] = _candidateLeftWallIndex[11];  
					_candidateLeftWallIndex[11] = _candidateLeftWallIndex[10];  
					_candidateLeftWallIndex[10] = _candidateLeftWallIndex[9];  
					_candidateLeftWallIndex[9] = _candidateLeftWallIndex[8];  
					_candidateLeftWallIndex[8] = _candidateLeftWallIndex[7];  
					_candidateLeftWallIndex[7] = _candidateLeftWallIndex[6];  
					_candidateLeftWallIndex[6] = _candidateLeftWallIndex[5];  
					_candidateLeftWallIndex[5] = _candidateLeftWallIndex[4];  
					_candidateLeftWallIndex[4] = _candidateLeftWallIndex[3];  
					_candidateLeftWallIndex[3] = _candidateLeftWallIndex[2];  
					_candidateLeftWallIndex[2] = _candidateLeftWallIndex[1];            
					_candidateLeftWallIndex[1] = _candidateLeftWallIndex[0];
					_candidateLeftWallIndex[0] = _candidateLeftWallUniqueID;
					
					_candidateLeftWallUniqueID++;
							
				}	

//***************** IDENTIFY RIGHT WALL OF DAM CANDIDATES ******************//

		//loop the _candidateLeftWallPrices list, 
		for (int ss=0; ss<ArraySize(_candidateLeftWallPrices); ss++)
      { 
      	//bull candle opens below and closes above left dam wall
			if (	minus1CandleOpen < minus1CandleClose &&
					minus1CandleOpen < _candidateLeftWallPrices[ss] &&
					minus1CandleClose > _candidateLeftWallPrices[ss] &&
					//body size is healthy
					minus1CandleClose - minus1CandleOpen >= 4*(10*Point)
				)
				{
					ObjectCreate("rightWallCandidateLine"+_labelIndex,OBJ_ARROW,0,minus1CandleIndex, _candidateLeftWallPrices[ss]);
					ObjectSet("rightWallCandidateLine"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_CHECKSIGN);
					ObjectSet("rightWallCandidateLine"+_labelIndex,OBJPROP_COLOR,Red); 					
					
					//draw a connecting line between the left and right walls
					ObjectCreate("damLine" + _labelIndex,OBJ_TREND,0, minus1CandleTime, _candidateLeftWallPrices[ss], _candidateLeftWallTime[ss], _candidateLeftWallPrices[ss] );
					ObjectSet("damLine" + _labelIndex,OBJPROP_COLOR,Aqua);
					ObjectSet("damLine" + _labelIndex,OBJPROP_WIDTH,1);
					ObjectSet("damLine" + _labelIndex,OBJPROP_RAY,false);   
					
					_candidateLeftWallPrices[ss] = 100.00; //this is lazy
				}
				//need to check if any candles between the last and the signal left dam wall essentially invalidate this right wall
				//by wicking through the signal price. if so, then we can delete the signal left wall arrow, 
				//and we don't need to paint a right wall candidate, because we don't really have one.
				else if (	minus1CandleHigh > _candidateLeftWallPrices[ss] &&
								minus1CandleClose < _candidateLeftWallPrices[ss]
				 		  )
				{
					//invalidate
					_candidateLeftWallPrices[ss] = 100.00; //this is lazy			
					ObjectDelete("leftWallCandidateLine"+_candidateLeftWallIndex[ss]);		
				}
				
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


