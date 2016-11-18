#property link "http://www.thedamagereport.com"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 2
#property indicator_color1  DodgerBlue
#property indicator_color2  Red

#define    SECINMIN         60  //Number of seconds in a minute

extern int vsiMAPeriod    = 21;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */

double vsiBuffer[];
double vsiMABuffer[];



extern int		TimeFrame		= 0,		// {1=M1, 5=M5, ..., 60=H1, 240=H4, 1440=D1, ...}
					BarWidth			= 1,
					CandleWidth		= 2;

double EMA_H[];
double EMA_L[];
double EMA_C[];
string Sym = "";
bool _bollBreakUp = false;
bool _waveBreakUp = false;
bool _bollBreakDown = false;
bool _waveBreakDown = false;
double _entryPrice;
int _signalIndex = 0;
int _buyOrSell = 0; //-1 sell, 1 buy



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	Sym = Symbol();

	string vsiTitle = "VSI(" + vsiMAPeriod + ")";
	SetIndexStyle(0,DRAW_LINE);
	SetIndexStyle(1,DRAW_LINE);
	SetIndexBuffer(0, vsiBuffer);
	SetIndexBuffer(1, vsiMABuffer);
	IndicatorShortName(vsiTitle);
	SetIndexLabel(0, vsiTitle);
	SetIndexLabel(1, "vsiMA(" + vsiMAPeriod + ")");
	SetIndexDrawBegin(1, vsiMAPeriod);

   ObjectsDeleteAll();
	return(0);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   for(int i = Bars-1-IndicatorCounted(); i >= 0; i--)
	{

		EMA_H[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, i );
		EMA_L[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_LOW, i );
		EMA_C[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_CLOSE, i );

		int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
			 time1  = iTime    (NULL,TimeFrame,shift1),
			 shift2 = iBarShift(NULL,0,time1);

		double	high		= iHigh(NULL,TimeFrame,shift1),
					low		= iLow(NULL,TimeFrame,shift1),
					open		= iOpen(NULL,TimeFrame,shift1),
					close		= iClose(NULL,TimeFrame,shift1),
			 		bodyHigh	= MathMax(open,close),
					bodyLow	= MathMin(open,close);

		int previousTime = iTime(NULL,TimeFrame,shift1+1);
		int previousIndex = iTime(NULL,TimeFrame,shift1+1);
		double previousOpen = iOpen(NULL,TimeFrame,shift1+1);
		double previousClose = iClose(NULL,TimeFrame,shift1+1);
		double previousLow = iLow(NULL,TimeFrame,shift1+1);
		double previousHigh = iHigh(NULL,TimeFrame,shift1+1);

		double thirdCandleClose = iClose(NULL,TimeFrame,shift1+2);
		double thirdCandleHigh = iHigh(NULL,TimeFrame,shift1+2);
		double thirdCandleLow = iLow(NULL,TimeFrame,shift1+2);

		double currentMacd = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
		double shortTermMacd = iMACD(NULL,0,5,8,9,PRICE_CLOSE,MODE_MAIN,i);
		double shortTermMacd2 = iMACD(NULL,0,5,8,9,PRICE_CLOSE,MODE_MAIN,i+1);
		double shortTermMacd3 = iMACD(NULL,0,5,8,9,PRICE_CLOSE,MODE_MAIN,i+2);
		double longTermMacd = iMACD(NULL,0,50,80,9,PRICE_CLOSE,MODE_MAIN,i);

		int indicatorShift = 1;
		double standardDeviation = 2.23;
		int bollMA = 12;

		//CCI boundary recross detector
		int cciLow = 100;
		cciLow *= -1;
		int cciActual = iCCI(Sym,0,12,PRICE_TYPICAL,i+1);
		int cciActualPrevious = iCCI(Sym,0,12,PRICE_TYPICAL,i+2);
		int cciActualThird = iCCI(Sym,0,12,PRICE_TYPICAL,i+3);

		int timeDiff = CurTime() - Time[i];

		//If we are in the current bar and the tick doesn't fall exactly on the '00:00' min & sec
		if(i == 0 && timeDiff > 0)
		{
			vsiBuffer[i] = Volume[i] / timeDiff;
		}
		else
		{
			//Otherwise calculate the total bar volume divided by the total bar seconds
			vsiBuffer[i] = Volume[i] / (Time[i - 1] - Time[i]);
		}

      double _magicVolumeLevel = 1;

      double currentVolMA = 
             (vsiBuffer[i] +
             vsiBuffer[i+1] +
             vsiBuffer[i+2] +
             vsiBuffer[i+3] +
             vsiBuffer[i+4] +
             vsiBuffer[i+5] +
             vsiBuffer[i+6] +
             vsiBuffer[i+7] +
             vsiBuffer[i+8] +
             vsiBuffer[i+9] +
             vsiBuffer[i+10] +
             vsiBuffer[i+11] +
             vsiBuffer[i+12] +
             vsiBuffer[i+13] +
             vsiBuffer[i+14] +
             vsiBuffer[i+15] +
             vsiBuffer[i+16] +
             vsiBuffer[i+17] +
             vsiBuffer[i+18] +
             vsiBuffer[i+19] +
             vsiBuffer[i+20] +
             vsiBuffer[i+21])/21;

		if (vsiBuffer[i] >= currentVolMA &&
		    vsiBuffer[i+1] <= currentVolMA &&
		    vsiBuffer[i+2] <= currentVolMA &&
		    vsiBuffer[i+3] <= currentVolMA &&
		    vsiBuffer[i+4] <= currentVolMA &&
		    vsiBuffer[i+5] <= currentVolMA
		)
		{
         double imaShift = -2;
         string objName = "";

         if (longTermMacd > 0)
         {                
              objName = "fooSell"+i;
                           
              //always send the email first
              SendAlertMail(time1, objName, "SELL", previousClose);
         
              doSell(i, time1, objName);
                              
              //sell                     
              ObjectCreate(objName,OBJ_ARROW,0,Time[i+1],previousClose);
              ObjectSet(objName, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
              ObjectSet(objName,OBJPROP_COLOR,Red);			            
          }
        
         if (longTermMacd < 0)
         {
              objName = "fooBuy"+i;
         
              //always send the email first
              SendAlertMail(time1, objName, "BUY", previousClose);
            
              doBuy(i, time1, objName);
            
              //buy
              ObjectCreate(objName,OBJ_ARROW,0,Time[i+1],previousClose);
              ObjectSet(objName, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
              ObjectSet(objName,OBJPROP_COLOR,Green);
           }
		}
	}

	string foo = "";

	ObjectCreate("LEGEND_NAME", OBJ_LABEL, 0, 0, 0);
	ObjectSet("LEGEND_NAME", OBJPROP_XDISTANCE, 10);
	ObjectSet("LEGEND_NAME", OBJPROP_YDISTANCE, 20);
	foo = "VOLUME DIVERGENCE - indicator";
	ObjectSetText("LEGEND_NAME",foo,10,"Arial",Yellow);

   for(int j = 0; j < Bars-1-IndicatorCounted(); j++)
   {
      vsiMABuffer[j] = iMAOnArray(vsiBuffer, Bars, vsiMAPeriod, 0, vsiMAType, j);      
   }
     
	return(0);
}

void doBuy(int pCandleIndex, datetime pCandleTime, string pObjectToFind)
{
	//string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, 
	//string comment=NULL, int magic=0, datetime expiration=0, color arrow_color=CLR_NONE
	
	if (   pCandleTime >= (TimeCurrent() - 960)  )//seconds
	{
	     if (ObjectFind(pObjectToFind)==-1)//only order this once
		  {
		        //scripts can't send orders
	           //OrderSend(Sym,OP_BUY,0.1,Ask,3,Ask-6*Point,Ask+25*Point,"My order #" + pCandleIndex,0,0,Green);
	     }      
	}  
	return(0);
}

void doSell(int pCandleIndex, datetime pCandleTime, string pObjectToFind)
{
   if (   pCandleTime >= (TimeCurrent() - 960)  )//seconds
	{
	     if (ObjectFind(pObjectToFind)==-1)//only order this once
		  {
		        //scripts can't send orders
	           //OrderSend(Sym,OP_SELL,0.1,Bid,3,Bid+6*Point,Bid-25*Point,"My order #" + pCandleIndex,0,0,Red);
	     }      
	}
	return(0);
}

void SendAlertMail(datetime pCandleTime, string pObjectToFind, string pOrderType, double pPrice)
{   
	if (   pCandleTime >= (TimeCurrent() - 960)  )//seconds
	{
		if (ObjectFind(pObjectToFind)==-1)//only send mail once
		{
			string tmpMessage = StringConcatenate(pOrderType, " ", pPrice);
			SendMail(tmpMessage, "");
		}
	}
}