//FINALLY, a multiframe indicator
//arlo emerson - 8/26/2012


//globally adjust tp/sl
double _stopLossFactor = 10;
double _takeProfitFactor = 50;

int _matchFoundIndex; //use this to store patterns...we will sort the good from the bad
string _matchFoundLibrary = "";
bool _entryCueMatchFound = false; //set to true when we match a time in the entryCue list
string _entryCueDirection = "";
double _openingPriceOpen;
double _openingPriceClose;
double _openingPriceHigh;
double _openingPriceLow;
string _openingPriceIndicator;
int _lookback = 12;
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

//this gets filled with the last 3 candles' pattern and checked and wiped every candle.
//for example, if it says X|upH|up then we had a volume reversal followed by some kind of higher high, followed by an up volume bull
//the order is minus1Candle, minus2Candle, minus3Candle, etc.

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


bool _WEAPON_ARMED = false;
bool _LOCKED_ON = false;
double _entryPrice;
double _TP;
double _SL;
int _targetAcquisitionTime;
double _targetAcquisitionPrice;
double _targetAcquisitionHigh;
double _targetAcquisitionLow;
double _targetAcquisitionOpen;
double _targetAcquisitionClose;



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
   {
       ThisBarTrade = Bars;
   
      //declarations
      int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
	        time1  = iTime    (NULL,TimeFrame,shift1);
	        
		int hourlyShift= MathFloor(i/12);	        
	        
	   double	high		= iHigh(NULL,TimeFrame,shift1),
			low		= iLow(NULL,TimeFrame,shift1),
			open		= iOpen(NULL,TimeFrame,shift1),
			close		= iClose(NULL,TimeFrame,shift1),
	 		bodyHigh	= MathMax(open,close),
			bodyLow	= MathMin(open,close);
			
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

 		       
		double minus1Volume = vsiBuffer[shift1+1];
      double minus2Volume = vsiBuffer[shift1+2];
      double minus3Volume = vsiBuffer[shift1+3];

      double _volumeLimit = 0.95;
      int _lineLength = 50;
      color _tmpColor = Orange; 
 
      RefreshBidsAndAsks();

      
//***************** CREATE INDICATOR VALUES ******************//
      
		int minus1Hour = TimeHour(Time[i+1]);
		int minus1Minute = TimeMinute(Time[i+1]);
		
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
		double hourlyMacd14_34_21 = iMACD(Sym,PERIOD_H1,14,34,21,PRICE_CLOSE,MODE_MAIN,hourlyShift+1);
		//hourly prices

		double hourlyMinus1CandleClose = iClose(NULL,PERIOD_H1, hourlyShift+ 1 );
         	
  
//***************** BEGIN TARGET ACQUISITION AND ENTRY ******************//      
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
				
      if ( 
				minus1CandleClose > ema160Minus1Candle
				&& cciMinus1Candle > 0
					&& cciMinus2Candle < 0
					&& stdDevMinus1Candle < 0.0003
					&& _cciTrendMode == "buy"
					&& hourlyMacd14_34_21 > 0
					//&& hourlyMinus1CandleClose - hourlyEma34Minus1CandleHigh < (10*(Point*10))
            )
      {

                  _entryCueMatchFound = false;
                  _entryCueDirection = "";

						ObjectCreate("buy"+_labelIndex,OBJ_ARROW,0,Time[i],open);
						ObjectSet("buy"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
						ObjectSet("buy"+_labelIndex,OBJPROP_COLOR,Green);

                  Print("attempting to buy at ", _ask, " i is ", i, " and OrdersTotal=", OrdersTotal());
               
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
                           _TP=_bid+_takeProfitFactor*(10*_point);
                           _SL=_bid-_stopLossFactor*(10*_point);
                           _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
                           _entryPrice = minus1CandleClose;
                           Print("entry price is: " + _entryPrice);
                           Print("OrderModify on a buy last called. Last error was: ",GetLastError());
                           
                           _matchFoundLibrary = StringConcatenate( _matchFoundLibrary, "order #: ", _ticketNumber, ", pattern #: ", _matchFoundIndex, "\n");
                           
                        }           
                     }                                             
                  }
                    
      }
      else if ( 
            _entryCueMatchFound == true
            && _openingPriceIndicator == "asdf" //currently restricting to buy patterns
            )
      {

                  _entryCueMatchFound = false;
                  _entryCueDirection = "";

                  ObjectCreate("sell"+_labelIndex,OBJ_ARROW,0,Time[i],open);
                  ObjectSet("sell"+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("sell"+_labelIndex,OBJPROP_COLOR,Red);   

               
                  //--------SELL ORDER---------//
                  if(i==0)//only trade current candle
                  {     
                     if (OrdersTotal() == 0)//open new order because one isn't open
                     {
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
                           _entryPrice = minus1CandleClose;
                           Print("entry price is: " + _entryPrice);
                           Print("OrderModify on a buy last called. Last error was: ",GetLastError());
                        }
                     }
                  }
                    
      }
      //***************** END TARGET ACQUISITION AND ENTRY ******************// 
      
      /*------- BEGIN MONEY MANAGEMENT -------- 
      //N pips advance - tighten up the SL
         if (
      minus1CandleClose >= (_entryPrice + 10*(_point*10))
      && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 2*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }  
      
      
     if (
      minus1CandleClose >= (_entryPrice + 15*(_point*10))
      && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 5*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }
      
      
     if (
            minus1CandleClose >= (_entryPrice + 20*(_point*10))
            && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 10*(_point*10), 4);
        //_TP = NormalizeDouble(_entryPrice + 60*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }
      
         if (
            minus1CandleClose >= (_entryPrice + 30*(_point*10))
            && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 20*(_point*10), 4);
        //_TP = NormalizeDouble(_entryPrice + 60*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }  

         if (
            minus1CandleClose >= (_entryPrice + 35*(_point*10))
            && OrdersTotal() == 1
          )
      {  
         
         _SL = NormalizeDouble(_entryPrice + 25*(_point*10), 4);
        //_TP = NormalizeDouble(_entryPrice + 60*(_point*10), 4);
         _modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL, _TP, 0);
         Print("Moving brackets up #1. Last error was: ",GetLastError(), " new SL: ", _SL, " new TP: " , _TP);                        
      }  
*/            
            /*------- last thing you do is update the index --------*/
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

