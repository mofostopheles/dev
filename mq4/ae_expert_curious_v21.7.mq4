//arlo emerson, 1/2/2013

//water dam construction
//buy high, sell higher

//look for shaved top bears
//draw lines from shaved tops to infinity
//wait for strong price to surround the left wall candle
//redraw a new line from left wall to right wall, thus marking the "water level", aka: price support
//enter a trade with SL at low of right wall

//ADDED: sell indicators

//USING PRICE ACTION TO RULE THE WORLD

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

//####################### FOR BUYING
double _candidateLeftWallSupportPrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00};
int _candidateLeftWallSupportIndex[34] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int _candidateLeftWallSupportTime[34] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int _candidateLeftWallSupportID = 0;

//####################### FOR SELLING
double _candidateLeftWallResPrices[34] = {100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00,100.00};
int _candidateLeftWallResIndex[34] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int _candidateLeftWallResTime[34] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int _candidateLeftWallResID = 0;

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


//***************** SUPPORT ******************//		
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
					ObjectCreate("leftWallSupportLine"+_labelIndex,OBJ_ARROW,0,minus1CandleIndex, minus1CandleHigh);
					ObjectSet("leftWallSupportLine"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
					ObjectSet("leftWallSupportLine"+_labelIndex,OBJPROP_COLOR,0x333333); 

					//manually fill and shift 34 last high prices
					//latest price is at 0, 
					_candidateLeftWallSupportPrices[34] = _candidateLeftWallSupportPrices[33]; 
					_candidateLeftWallSupportPrices[33] = _candidateLeftWallSupportPrices[32]; 
					_candidateLeftWallSupportPrices[32] = _candidateLeftWallSupportPrices[31]; 
					_candidateLeftWallSupportPrices[31] = _candidateLeftWallSupportPrices[30]; 
					_candidateLeftWallSupportPrices[30] = _candidateLeftWallSupportPrices[29]; 
					_candidateLeftWallSupportPrices[29] = _candidateLeftWallSupportPrices[28]; 
					_candidateLeftWallSupportPrices[28] = _candidateLeftWallSupportPrices[27]; 
					_candidateLeftWallSupportPrices[27] = _candidateLeftWallSupportPrices[26]; 
					_candidateLeftWallSupportPrices[26] = _candidateLeftWallSupportPrices[25]; 
					_candidateLeftWallSupportPrices[25] = _candidateLeftWallSupportPrices[24]; 
					_candidateLeftWallSupportPrices[24] = _candidateLeftWallSupportPrices[23]; 
					_candidateLeftWallSupportPrices[23] = _candidateLeftWallSupportPrices[22]; 
					_candidateLeftWallSupportPrices[22] = _candidateLeftWallSupportPrices[21]; 
					_candidateLeftWallSupportPrices[21] = _candidateLeftWallSupportPrices[20];  
					_candidateLeftWallSupportPrices[20] = _candidateLeftWallSupportPrices[19];  
					_candidateLeftWallSupportPrices[19] = _candidateLeftWallSupportPrices[18];  
					_candidateLeftWallSupportPrices[18] = _candidateLeftWallSupportPrices[17];  
					_candidateLeftWallSupportPrices[17] = _candidateLeftWallSupportPrices[16];  
					_candidateLeftWallSupportPrices[16] = _candidateLeftWallSupportPrices[15];  
					_candidateLeftWallSupportPrices[15] = _candidateLeftWallSupportPrices[14];  
					_candidateLeftWallSupportPrices[14] = _candidateLeftWallSupportPrices[13];  
					_candidateLeftWallSupportPrices[13] = _candidateLeftWallSupportPrices[12];  
					_candidateLeftWallSupportPrices[12] = _candidateLeftWallSupportPrices[11];  
					_candidateLeftWallSupportPrices[11] = _candidateLeftWallSupportPrices[10];  
					_candidateLeftWallSupportPrices[10] = _candidateLeftWallSupportPrices[9];  
					_candidateLeftWallSupportPrices[9] = _candidateLeftWallSupportPrices[8];  
					_candidateLeftWallSupportPrices[8] = _candidateLeftWallSupportPrices[7];  
					_candidateLeftWallSupportPrices[7] = _candidateLeftWallSupportPrices[6];  
					_candidateLeftWallSupportPrices[6] = _candidateLeftWallSupportPrices[5];  
					_candidateLeftWallSupportPrices[5] = _candidateLeftWallSupportPrices[4];  
					_candidateLeftWallSupportPrices[4] = _candidateLeftWallSupportPrices[3];  
					_candidateLeftWallSupportPrices[3] = _candidateLeftWallSupportPrices[2];  
					_candidateLeftWallSupportPrices[2] = _candidateLeftWallSupportPrices[1];            
					_candidateLeftWallSupportPrices[1] = _candidateLeftWallSupportPrices[0];
					_candidateLeftWallSupportPrices[0] = minus1CandleHigh;
					
					_candidateLeftWallSupportTime[34] = _candidateLeftWallSupportTime[33]; 
					_candidateLeftWallSupportTime[33] = _candidateLeftWallSupportTime[32]; 
					_candidateLeftWallSupportTime[32] = _candidateLeftWallSupportTime[31]; 
					_candidateLeftWallSupportTime[31] = _candidateLeftWallSupportTime[30]; 
					_candidateLeftWallSupportTime[30] = _candidateLeftWallSupportTime[29]; 
					_candidateLeftWallSupportTime[29] = _candidateLeftWallSupportTime[28]; 
					_candidateLeftWallSupportTime[28] = _candidateLeftWallSupportTime[27]; 
					_candidateLeftWallSupportTime[27] = _candidateLeftWallSupportTime[26]; 
					_candidateLeftWallSupportTime[26] = _candidateLeftWallSupportTime[25]; 
					_candidateLeftWallSupportTime[25] = _candidateLeftWallSupportTime[24]; 
					_candidateLeftWallSupportTime[24] = _candidateLeftWallSupportTime[23]; 
					_candidateLeftWallSupportTime[23] = _candidateLeftWallSupportTime[22]; 
					_candidateLeftWallSupportTime[22] = _candidateLeftWallSupportTime[21]; 
					_candidateLeftWallSupportTime[21] = _candidateLeftWallSupportTime[20];  
					_candidateLeftWallSupportTime[20] = _candidateLeftWallSupportTime[19];  
					_candidateLeftWallSupportTime[19] = _candidateLeftWallSupportTime[18];  
					_candidateLeftWallSupportTime[18] = _candidateLeftWallSupportTime[17];  
					_candidateLeftWallSupportTime[17] = _candidateLeftWallSupportTime[16];  
					_candidateLeftWallSupportTime[16] = _candidateLeftWallSupportTime[15];  
					_candidateLeftWallSupportTime[15] = _candidateLeftWallSupportTime[14];  
					_candidateLeftWallSupportTime[14] = _candidateLeftWallSupportTime[13];  
					_candidateLeftWallSupportTime[13] = _candidateLeftWallSupportTime[12];  
					_candidateLeftWallSupportTime[12] = _candidateLeftWallSupportTime[11];  
					_candidateLeftWallSupportTime[11] = _candidateLeftWallSupportTime[10];  
					_candidateLeftWallSupportTime[10] = _candidateLeftWallSupportTime[9];  
					_candidateLeftWallSupportTime[9] = _candidateLeftWallSupportTime[8];  
					_candidateLeftWallSupportTime[8] = _candidateLeftWallSupportTime[7];  
					_candidateLeftWallSupportTime[7] = _candidateLeftWallSupportTime[6];  
					_candidateLeftWallSupportTime[6] = _candidateLeftWallSupportTime[5];  
					_candidateLeftWallSupportTime[5] = _candidateLeftWallSupportTime[4];  
					_candidateLeftWallSupportTime[4] = _candidateLeftWallSupportTime[3];  
					_candidateLeftWallSupportTime[3] = _candidateLeftWallSupportTime[2];  
					_candidateLeftWallSupportTime[2] = _candidateLeftWallSupportTime[1];            
					_candidateLeftWallSupportTime[1] = _candidateLeftWallSupportTime[0];
					_candidateLeftWallSupportTime[0] = minus1CandleTime;
					
					_candidateLeftWallSupportIndex[34] = _candidateLeftWallSupportIndex[33]; 
					_candidateLeftWallSupportIndex[33] = _candidateLeftWallSupportIndex[32]; 
					_candidateLeftWallSupportIndex[32] = _candidateLeftWallSupportIndex[31]; 
					_candidateLeftWallSupportIndex[31] = _candidateLeftWallSupportIndex[30]; 
					_candidateLeftWallSupportIndex[30] = _candidateLeftWallSupportIndex[29]; 
					_candidateLeftWallSupportIndex[29] = _candidateLeftWallSupportIndex[28]; 
					_candidateLeftWallSupportIndex[28] = _candidateLeftWallSupportIndex[27]; 
					_candidateLeftWallSupportIndex[27] = _candidateLeftWallSupportIndex[26]; 
					_candidateLeftWallSupportIndex[26] = _candidateLeftWallSupportIndex[25]; 
					_candidateLeftWallSupportIndex[25] = _candidateLeftWallSupportIndex[24]; 
					_candidateLeftWallSupportIndex[24] = _candidateLeftWallSupportIndex[23]; 
					_candidateLeftWallSupportIndex[23] = _candidateLeftWallSupportIndex[22]; 
					_candidateLeftWallSupportIndex[22] = _candidateLeftWallSupportIndex[21]; 
					_candidateLeftWallSupportIndex[21] = _candidateLeftWallSupportIndex[20];  
					_candidateLeftWallSupportIndex[20] = _candidateLeftWallSupportIndex[19];  
					_candidateLeftWallSupportIndex[19] = _candidateLeftWallSupportIndex[18];  
					_candidateLeftWallSupportIndex[18] = _candidateLeftWallSupportIndex[17];  
					_candidateLeftWallSupportIndex[17] = _candidateLeftWallSupportIndex[16];  
					_candidateLeftWallSupportIndex[16] = _candidateLeftWallSupportIndex[15];  
					_candidateLeftWallSupportIndex[15] = _candidateLeftWallSupportIndex[14];  
					_candidateLeftWallSupportIndex[14] = _candidateLeftWallSupportIndex[13];  
					_candidateLeftWallSupportIndex[13] = _candidateLeftWallSupportIndex[12];  
					_candidateLeftWallSupportIndex[12] = _candidateLeftWallSupportIndex[11];  
					_candidateLeftWallSupportIndex[11] = _candidateLeftWallSupportIndex[10];  
					_candidateLeftWallSupportIndex[10] = _candidateLeftWallSupportIndex[9];  
					_candidateLeftWallSupportIndex[9] = _candidateLeftWallSupportIndex[8];  
					_candidateLeftWallSupportIndex[8] = _candidateLeftWallSupportIndex[7];  
					_candidateLeftWallSupportIndex[7] = _candidateLeftWallSupportIndex[6];  
					_candidateLeftWallSupportIndex[6] = _candidateLeftWallSupportIndex[5];  
					_candidateLeftWallSupportIndex[5] = _candidateLeftWallSupportIndex[4];  
					_candidateLeftWallSupportIndex[4] = _candidateLeftWallSupportIndex[3];  
					_candidateLeftWallSupportIndex[3] = _candidateLeftWallSupportIndex[2];  
					_candidateLeftWallSupportIndex[2] = _candidateLeftWallSupportIndex[1];            
					_candidateLeftWallSupportIndex[1] = _candidateLeftWallSupportIndex[0];
					_candidateLeftWallSupportIndex[0] = _candidateLeftWallSupportID;
					
					_candidateLeftWallSupportID++;
							
				}	

//***************** IDENTIFY RIGHT WALL OF DAM CANDIDATES ******************//

		//loop the _candidateLeftWallSupportPrices list, 
		for (int ss=0; ss<ArraySize(_candidateLeftWallSupportPrices); ss++)
      { 
      	//bull candle opens below and closes above left dam wall
			if (	minus1CandleOpen < minus1CandleClose &&
					minus1CandleOpen < _candidateLeftWallSupportPrices[ss] &&
					minus1CandleClose > _candidateLeftWallSupportPrices[ss] &&
					//body size is healthy
					minus1CandleClose - minus1CandleOpen >= 4*(10*Point)
				)
				{
					ObjectCreate("rightWallSupportLine"+_labelIndex,OBJ_ARROW,0,minus1CandleIndex, _candidateLeftWallSupportPrices[ss]);
					ObjectSet("rightWallSupportLine"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_CHECKSIGN);
					ObjectSet("rightWallSupportLine"+_labelIndex,OBJPROP_COLOR,Red); 					
					
					//draw a connecting line between the left and right walls
					ObjectCreate("supportDamLine" + _labelIndex,OBJ_TREND,0, minus1CandleTime, _candidateLeftWallSupportPrices[ss], _candidateLeftWallSupportTime[ss], _candidateLeftWallSupportPrices[ss] );
					ObjectSet("supportDamLine" + _labelIndex,OBJPROP_COLOR,Aqua);
					ObjectSet("supportDamLine" + _labelIndex,OBJPROP_WIDTH,1);
					ObjectSet("supportDamLine" + _labelIndex,OBJPROP_RAY,false);   
					
					_candidateLeftWallSupportPrices[ss] = 100.00; //this is lazy
				}
				//need to check if any candles between the last and the signal left dam wall essentially invalidate this right wall
				//by wicking through the signal price. if so, then we can delete the signal left wall arrow, 
				//and we don't need to paint a right wall candidate, because we don't really have one.
				else if (	minus1CandleHigh > _candidateLeftWallSupportPrices[ss] &&
								minus1CandleClose < _candidateLeftWallSupportPrices[ss]
				 		  )
				{
					//invalidate
					_candidateLeftWallSupportPrices[ss] = 100.00; //this is lazy			
					ObjectDelete("leftWallSupportLine"+_candidateLeftWallSupportIndex[ss]);		
				}
				
      }

//***************** #################################### ******************//	
//***************** #################################### ******************//	
//***************** #################################### ******************//	

//***************** RESISTANCE ******************//		
//***************** IDENTIFY LEFT WALL OF DAM CANDIDATES ******************//
		
		//shaved bottom bull candle
		if (	(minus1CandleOpen == minus1CandleLow &&
				minus1CandleOpen < minus1CandleClose)
				||
				(//or a very small wick at bottom
				(minus1CandleOpen - minus1CandleLow) <= 0.5*(10*Point) &&
				minus1CandleOpen < minus1CandleClose
				)
				
				)
				{
					ObjectCreate("leftWallResLine"+_labelIndex,OBJ_ARROW,0,minus1CandleIndex, minus1CandleLow);
					ObjectSet("leftWallResLine"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
					ObjectSet("leftWallResLine"+_labelIndex,OBJPROP_COLOR,0x333333); 

					//manually fill and shift 34 last high prices
					//latest price is at 0, 
					_candidateLeftWallResPrices[34] = _candidateLeftWallResPrices[33]; 
					_candidateLeftWallResPrices[33] = _candidateLeftWallResPrices[32]; 
					_candidateLeftWallResPrices[32] = _candidateLeftWallResPrices[31]; 
					_candidateLeftWallResPrices[31] = _candidateLeftWallResPrices[30]; 
					_candidateLeftWallResPrices[30] = _candidateLeftWallResPrices[29]; 
					_candidateLeftWallResPrices[29] = _candidateLeftWallResPrices[28]; 
					_candidateLeftWallResPrices[28] = _candidateLeftWallResPrices[27]; 
					_candidateLeftWallResPrices[27] = _candidateLeftWallResPrices[26]; 
					_candidateLeftWallResPrices[26] = _candidateLeftWallResPrices[25]; 
					_candidateLeftWallResPrices[25] = _candidateLeftWallResPrices[24]; 
					_candidateLeftWallResPrices[24] = _candidateLeftWallResPrices[23]; 
					_candidateLeftWallResPrices[23] = _candidateLeftWallResPrices[22]; 
					_candidateLeftWallResPrices[22] = _candidateLeftWallResPrices[21]; 
					_candidateLeftWallResPrices[21] = _candidateLeftWallResPrices[20];  
					_candidateLeftWallResPrices[20] = _candidateLeftWallResPrices[19];  
					_candidateLeftWallResPrices[19] = _candidateLeftWallResPrices[18];  
					_candidateLeftWallResPrices[18] = _candidateLeftWallResPrices[17];  
					_candidateLeftWallResPrices[17] = _candidateLeftWallResPrices[16];  
					_candidateLeftWallResPrices[16] = _candidateLeftWallResPrices[15];  
					_candidateLeftWallResPrices[15] = _candidateLeftWallResPrices[14];  
					_candidateLeftWallResPrices[14] = _candidateLeftWallResPrices[13];  
					_candidateLeftWallResPrices[13] = _candidateLeftWallResPrices[12];  
					_candidateLeftWallResPrices[12] = _candidateLeftWallResPrices[11];  
					_candidateLeftWallResPrices[11] = _candidateLeftWallResPrices[10];  
					_candidateLeftWallResPrices[10] = _candidateLeftWallResPrices[9];  
					_candidateLeftWallResPrices[9] = _candidateLeftWallResPrices[8];  
					_candidateLeftWallResPrices[8] = _candidateLeftWallResPrices[7];  
					_candidateLeftWallResPrices[7] = _candidateLeftWallResPrices[6];  
					_candidateLeftWallResPrices[6] = _candidateLeftWallResPrices[5];  
					_candidateLeftWallResPrices[5] = _candidateLeftWallResPrices[4];  
					_candidateLeftWallResPrices[4] = _candidateLeftWallResPrices[3];  
					_candidateLeftWallResPrices[3] = _candidateLeftWallResPrices[2];  
					_candidateLeftWallResPrices[2] = _candidateLeftWallResPrices[1];            
					_candidateLeftWallResPrices[1] = _candidateLeftWallResPrices[0];
					_candidateLeftWallResPrices[0] = minus1CandleLow;
					
					_candidateLeftWallResTime[34] = _candidateLeftWallResTime[33]; 
					_candidateLeftWallResTime[33] = _candidateLeftWallResTime[32]; 
					_candidateLeftWallResTime[32] = _candidateLeftWallResTime[31]; 
					_candidateLeftWallResTime[31] = _candidateLeftWallResTime[30]; 
					_candidateLeftWallResTime[30] = _candidateLeftWallResTime[29]; 
					_candidateLeftWallResTime[29] = _candidateLeftWallResTime[28]; 
					_candidateLeftWallResTime[28] = _candidateLeftWallResTime[27]; 
					_candidateLeftWallResTime[27] = _candidateLeftWallResTime[26]; 
					_candidateLeftWallResTime[26] = _candidateLeftWallResTime[25]; 
					_candidateLeftWallResTime[25] = _candidateLeftWallResTime[24]; 
					_candidateLeftWallResTime[24] = _candidateLeftWallResTime[23]; 
					_candidateLeftWallResTime[23] = _candidateLeftWallResTime[22]; 
					_candidateLeftWallResTime[22] = _candidateLeftWallResTime[21]; 
					_candidateLeftWallResTime[21] = _candidateLeftWallResTime[20];  
					_candidateLeftWallResTime[20] = _candidateLeftWallResTime[19];  
					_candidateLeftWallResTime[19] = _candidateLeftWallResTime[18];  
					_candidateLeftWallResTime[18] = _candidateLeftWallResTime[17];  
					_candidateLeftWallResTime[17] = _candidateLeftWallResTime[16];  
					_candidateLeftWallResTime[16] = _candidateLeftWallResTime[15];  
					_candidateLeftWallResTime[15] = _candidateLeftWallResTime[14];  
					_candidateLeftWallResTime[14] = _candidateLeftWallResTime[13];  
					_candidateLeftWallResTime[13] = _candidateLeftWallResTime[12];  
					_candidateLeftWallResTime[12] = _candidateLeftWallResTime[11];  
					_candidateLeftWallResTime[11] = _candidateLeftWallResTime[10];  
					_candidateLeftWallResTime[10] = _candidateLeftWallResTime[9];  
					_candidateLeftWallResTime[9] = _candidateLeftWallResTime[8];  
					_candidateLeftWallResTime[8] = _candidateLeftWallResTime[7];  
					_candidateLeftWallResTime[7] = _candidateLeftWallResTime[6];  
					_candidateLeftWallResTime[6] = _candidateLeftWallResTime[5];  
					_candidateLeftWallResTime[5] = _candidateLeftWallResTime[4];  
					_candidateLeftWallResTime[4] = _candidateLeftWallResTime[3];  
					_candidateLeftWallResTime[3] = _candidateLeftWallResTime[2];  
					_candidateLeftWallResTime[2] = _candidateLeftWallResTime[1];            
					_candidateLeftWallResTime[1] = _candidateLeftWallResTime[0];
					_candidateLeftWallResTime[0] = minus1CandleTime;
					
					_candidateLeftWallResIndex[34] = _candidateLeftWallResIndex[33]; 
					_candidateLeftWallResIndex[33] = _candidateLeftWallResIndex[32]; 
					_candidateLeftWallResIndex[32] = _candidateLeftWallResIndex[31]; 
					_candidateLeftWallResIndex[31] = _candidateLeftWallResIndex[30]; 
					_candidateLeftWallResIndex[30] = _candidateLeftWallResIndex[29]; 
					_candidateLeftWallResIndex[29] = _candidateLeftWallResIndex[28]; 
					_candidateLeftWallResIndex[28] = _candidateLeftWallResIndex[27]; 
					_candidateLeftWallResIndex[27] = _candidateLeftWallResIndex[26]; 
					_candidateLeftWallResIndex[26] = _candidateLeftWallResIndex[25]; 
					_candidateLeftWallResIndex[25] = _candidateLeftWallResIndex[24]; 
					_candidateLeftWallResIndex[24] = _candidateLeftWallResIndex[23]; 
					_candidateLeftWallResIndex[23] = _candidateLeftWallResIndex[22]; 
					_candidateLeftWallResIndex[22] = _candidateLeftWallResIndex[21]; 
					_candidateLeftWallResIndex[21] = _candidateLeftWallResIndex[20];  
					_candidateLeftWallResIndex[20] = _candidateLeftWallResIndex[19];  
					_candidateLeftWallResIndex[19] = _candidateLeftWallResIndex[18];  
					_candidateLeftWallResIndex[18] = _candidateLeftWallResIndex[17];  
					_candidateLeftWallResIndex[17] = _candidateLeftWallResIndex[16];  
					_candidateLeftWallResIndex[16] = _candidateLeftWallResIndex[15];  
					_candidateLeftWallResIndex[15] = _candidateLeftWallResIndex[14];  
					_candidateLeftWallResIndex[14] = _candidateLeftWallResIndex[13];  
					_candidateLeftWallResIndex[13] = _candidateLeftWallResIndex[12];  
					_candidateLeftWallResIndex[12] = _candidateLeftWallResIndex[11];  
					_candidateLeftWallResIndex[11] = _candidateLeftWallResIndex[10];  
					_candidateLeftWallResIndex[10] = _candidateLeftWallResIndex[9];  
					_candidateLeftWallResIndex[9] = _candidateLeftWallResIndex[8];  
					_candidateLeftWallResIndex[8] = _candidateLeftWallResIndex[7];  
					_candidateLeftWallResIndex[7] = _candidateLeftWallResIndex[6];  
					_candidateLeftWallResIndex[6] = _candidateLeftWallResIndex[5];  
					_candidateLeftWallResIndex[5] = _candidateLeftWallResIndex[4];  
					_candidateLeftWallResIndex[4] = _candidateLeftWallResIndex[3];  
					_candidateLeftWallResIndex[3] = _candidateLeftWallResIndex[2];  
					_candidateLeftWallResIndex[2] = _candidateLeftWallResIndex[1];            
					_candidateLeftWallResIndex[1] = _candidateLeftWallResIndex[0];
					_candidateLeftWallResIndex[0] = _candidateLeftWallResID;
					
					_candidateLeftWallResID++;
							
				}	

//***************** IDENTIFY RIGHT WALL OF DAM CANDIDATES ******************//

		//loop the _candidateLeftWallResPrices list, 
		for (int rr=0; rr<ArraySize(_candidateLeftWallResPrices); rr++)
      { 
      	//bull candle opens below and closes above left dam wall
			if (	minus1CandleOpen > minus1CandleClose &&
					minus1CandleOpen > _candidateLeftWallResPrices[rr] &&
					minus1CandleClose < _candidateLeftWallResPrices[rr] &&
					//body size is healthy
					minus1CandleOpen - minus1CandleClose >= 4*(10*Point)
				)
				{
					ObjectCreate("rightWallResLine"+_labelIndex,OBJ_ARROW,0,minus1CandleIndex, _candidateLeftWallResPrices[rr]);
					ObjectSet("rightWallResLine"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_CHECKSIGN);
					ObjectSet("rightWallResLine"+_labelIndex,OBJPROP_COLOR,Red); 					
					
					//draw a connecting line between the left and right walls
					ObjectCreate("ResDamLine" + _labelIndex,OBJ_TREND,0, minus1CandleTime, _candidateLeftWallResPrices[rr], _candidateLeftWallResTime[rr], _candidateLeftWallResPrices[rr] );
					ObjectSet("ResDamLine" + _labelIndex,OBJPROP_COLOR,Orange);
					ObjectSet("ResDamLine" + _labelIndex,OBJPROP_WIDTH,1);
					ObjectSet("ResDamLine" + _labelIndex,OBJPROP_RAY,false);   
					
					_candidateLeftWallResPrices[rr] = 100.00; //this is lazy
				}
				//need to check if any candles between the last and the signal left dam wall errentially invalidate this right wall
				//by wicking through the signal price. if so, then we can delete the signal left wall arrow, 
				//and we don't need to paint a right wall candidate, because we don't really have one.
				else if (	minus1CandleLow < _candidateLeftWallResPrices[rr] &&
								minus1CandleClose > _candidateLeftWallResPrices[rr]
				 		  )
				{
					//invalidate
					_candidateLeftWallResPrices[rr] = 100.00; //this is lazy			
					ObjectDelete("leftWallResLine"+_candidateLeftWallResIndex[rr]);		
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


