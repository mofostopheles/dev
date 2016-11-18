/*
   This module is based on Al Brooks' "Reading Price Charts Bar by Bar"
   There should be no additional indicators or fat other than what is
   prescribed by that book.

   author:  Arlo Emerson
   date:    6/21/2012
*/


#property link "http://www.thedamagereport.com/"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color5 Blue
#property indicator_width5 1
#property indicator_style5 2
#property indicator_color6 Silver
#property indicator_width6 1
#property indicator_style6 2
#property indicator_color7 Blue
#property indicator_width7 1
#property indicator_style7 2


extern int		TimeFrame		= 5,		// {1=M1, 5=M5, ..., 60=H1, 240=H4, 1440=D1, ...}
					BarWidth			= 1,
					CandleWidth		= 2;

//---- buffers
double ShortWickUp[],	 ShortCandleUp[],
		 ShortWickDown[],	 ShortCandleDown[];

//double EMA_H[];
//double EMA_L[];
double EMA_C[];

string Sym = "";


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{

//---- indicators
	IndicatorShortName("MTF Candles ("+TimeFrame+")");
	SetIndexBuffer(0,ShortWickUp);
	SetIndexBuffer(1,ShortWickDown);
	SetIndexBuffer(2,ShortCandleUp);
	SetIndexBuffer(3,ShortCandleDown);
	SetIndexStyle(0,DRAW_HISTOGRAM,0,BarWidth);
	SetIndexStyle(1,DRAW_HISTOGRAM,0,BarWidth);
	SetIndexStyle(2,DRAW_HISTOGRAM,0,CandleWidth);
	SetIndexStyle(3,DRAW_HISTOGRAM,0,CandleWidth);

	//SetIndexBuffer(4,EMA_H);
	//SetIndexBuffer(5,EMA_L);
	SetIndexBuffer(6,EMA_C);

	//SetIndexStyle(4,DRAW_LINE);
	//SetIndexStyle(5,DRAW_LINE);
	SetIndexStyle(6,DRAW_LINE);

	Sym = Symbol();
	
	for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
	{
         string on = ObjectName(iObj);
         if ((StringFind(on, "sell", 0) > -1) || (StringFind(on, "buy", 0) > -1))
         {
            ObjectDelete(on);
         }
   }
        
        

	return(0);
}

int start()
{

	for(int i = Bars-1-IndicatorCounted(); i >= 0; i--)
	{

		//EMA_H[i] = iMA(Sym, TimeFrame, 34, TimeFrame, MODE_EMA, PRICE_HIGH, i );
		//EMA_L[i] = iMA(Sym, TimeFrame, 21, TimeFrame, MODE_EMA, PRICE_CLOSE, i );
		EMA_C[i] = iMA(Sym, TimeFrame, 50, TimeFrame, MODE_EMA, PRICE_CLOSE, i );
		
		int shift1 = iBarShift(NULL,TimeFrame,Time[i]),
			 time1  = iTime    (NULL,TimeFrame,shift1),
			 shift2 = iBarShift(NULL,0,time1);

		double	high		= iHigh(NULL,TimeFrame,shift1),
					low		= iLow(NULL,TimeFrame,shift1),
					open		= iOpen(NULL,TimeFrame,shift1),
					close		= iClose(NULL,TimeFrame,shift1),
			 		bodyHigh	= MathMax(open,close),
					bodyLow	= MathMin(open,close);

		int previousCandleTime = iTime(NULL,TimeFrame,shift1+1);
		int previousCandleIndex = iTime(NULL,TimeFrame,shift1+1);
		double previousCandleOpen = iOpen(NULL,TimeFrame,shift1+1);
		double previousCandleClose = iClose(NULL,TimeFrame,shift1+1);
		double previousCandleLow = iLow(NULL,TimeFrame,shift1+1);
		double previousCandleHigh = iHigh(NULL,TimeFrame,shift1+1);
		
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
      
      double minus12CandleLow = iLow(NULL,TimeFrame,shift1+12);
		double minus12CandleHigh = iHigh(NULL,TimeFrame,shift1+12);
      double minus12CandleClose = iClose(NULL,TimeFrame,shift1+12);
                                    		
		double maSevenCandlesBack = iMA(Sym, TimeFrame, 21, TimeFrame, MODE_EMA, PRICE_CLOSE, i+7 );
		
		string tmpMessage = "";
		
		
		

               
               
               

  //    if (maSevenCandlesBack > EMA_C[i]) //we are in a downtrend
  //    {
            //SHAVED BOTTOMS - STRONG - PAGE 21
            //VISUALLY CONFIRM: THIS NEEDS TO BE IN A RUNAWAY BEAR
            //exceptions: 
            //previous candle can't be a strong bull 50% or more of signal candle
            //previous two candles should not be doji's
            //previous two candle lows should not be trending up
            if   (
				     close < open
				     && close == low
				     && close < minus2CandleLow
				     && open < minus2CandleHigh
				     && previousCandleNotStrongBull(previousCandleOpen, previousCandleClose, previousCandleHigh, previousCandleLow, (open-close)) == 1
				     && low < previousCandleLow
				     && previousCandleLow < minus2CandleLow
				     && open <= previousCandleClose
				     //&& notDoji(minus2CandleOpen, minus2CandleClose, minus2CandleHigh, minus2CandleLow) == 1
				     //&& notDoji(minus3CandleOpen, minus3CandleClose, minus3CandleHigh, minus3CandleLow) == 1
               )
               {
                  ObjectCreate("sellShavedBot"+i,OBJ_ARROW,0,Time[i],low);
                  ObjectSet("sellShavedBot"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("sellShavedBot"+i,OBJPROP_COLOR,Red);
                  
                  drawSellArrow(high, Time[i], i);
               }
               
/*               
               //DOUBLE TWIN BOTTOMS - PAGE 20   
            if   (
				     open > close
				     && previousCandleLow == low
				     && previousCandleClose > close
               )
               {
                  ObjectCreate("sellDubBotTwin"+i,OBJ_ARROW,0,Time[i],close);
                  ObjectSet("sellDubBotTwin"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("sellDubBotTwin"+i,OBJPROP_COLOR,Red);
                  
                  drawSellArrow(high, Time[i], i);
               }
               
            //UP DOWN TWINS - PAGE 21
            if   (
				     open > close
				     && previousCandleClose > close
				     && previousCandleClose > previousCandleOpen
				     //and candles are within 1 pip
				     && testCandlesForRangeSimilarity(high, previousCandleHigh, 1.0) == 1
				     && testCandlesForRangeSimilarity(open, previousCandleClose, 1.0) == 1 
				     && testCandlesForRangeSimilarity(close, previousCandleOpen, 1.0) == 1
				     && testCandlesForRangeSimilarity(low, previousCandleLow, 1.0) == 1
               )
               {
                  ObjectCreate("sellUpDownTwins"+i,OBJ_ARROW,0,Time[i],close);
                  ObjectSet("sellUpDownTwins"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("sellUpDownTwins"+i,OBJPROP_COLOR,Purple);
                  
                  drawSellArrow(high, Time[i], i);
               }
*/               
 //     }
      //TODO: this is not handling a flat-ish looking MA line...
 //     else if (maSevenCandlesBack < EMA_C[i]) //market is uptrending
 //     {
  
      	 //SHAVED TOPS - STRONG - PAGE 21
      	 //TO DO: THIS NEEDS TO BE IN A RUNAWAY bull
      	 //possibly use the 21 MA as a stop
          if   (
				     close > open
				     && close == high
				     && high > previousCandleHigh
				     && high > minus2CandleHigh
				     && high > minus3CandleHigh
				     && high > minus4CandleHigh
				     && high > minus5CandleHigh
				     && high > minus6CandleHigh
				     && high > minus7CandleHigh
				     && high > minus8CandleHigh
				     
				     /*
				     && close > minus2CandleHigh
				     && open > minus2CandleHigh
				     && high < previousCandleHigh
				     
				     && open >= previousCandleClose    
				     */
               )
               {
                  ObjectCreate("buyShavedTop"+i,OBJ_ARROW,0,Time[i],close);
                  ObjectSet("buyShavedTop"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("buyShavedTop"+i,OBJPROP_COLOR,Green);
                  
                  drawBuyArrow(low, Time[i], i);
               }
      /*
            //DOUBLE TWIN TOPS - PAGE 20
            if   (
				     close > open
				     && previousCandleHigh == high
				     && previousCandleClose < close
               )
               {
                  ObjectCreate("buyDubTopTwin"+i,OBJ_ARROW,0,Time[i],close);
                  ObjectSet("buyDubTopTwin"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("buyDubTopTwin"+i,OBJPROP_COLOR,Green);
                  
                  drawBuyArrow(low, Time[i], i);
               }
               
            //DOWN UP TWINS - PAGE 21
            if   (
				     close > open
				     && previousCandleClose < close
				     && previousCandleClose < previousCandleOpen
				     && testCandlesForRangeSimilarity(high, previousCandleHigh, 1.0) == 1
				     && testCandlesForRangeSimilarity(open, previousCandleClose, 1.0) == 1 
				     && testCandlesForRangeSimilarity(close, previousCandleOpen, 1.0) == 1
				     && testCandlesForRangeSimilarity(low, previousCandleLow, 1.0) == 1
               )
               {
                  ObjectCreate("buyDownUpTwins"+i,OBJ_ARROW,0,Time[i],close);
                  ObjectSet("buyDownUpTwins"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
                  ObjectSet("buyDownUpTwins"+i,OBJPROP_COLOR,Orange);
                  
                  drawBuyArrow(low, Time[i], i);
               }
               
               
            //inside bar following exhausted hammer - p. 13, 14, 18, see eurusd :55 6/17 for perfect example
            if (
               close > open
               && close >= previousCandleOpen
               && open <= previousCandleOpen
               //context is previous bar is a bear hammer with an exhausted new low
               && previousCandleOpen >= previousCandleClose
               && getHammerType(previousCandleOpen, previousCandleClose, previousCandleHigh, previousCandleLow)==1
               && previousCandleLow < minus2CandleLow
            )
            {
               ObjectCreate("buyInsideBarAfterHammer"+i,OBJ_ARROW,0,Time[i],high);
               ObjectSet("buyInsideBarAfterHammer"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
               ObjectSet("buyInsideBarAfterHammer"+i,OBJPROP_COLOR,Green);
               
               drawBuyArrow(low, Time[i], i);
            }
            */
            
            
            //ii inside bar - long setup - page 20
            
            
            
  //    }
      
      

      	
	}
	
	

	string foo = "";

	ObjectCreate("LEGEND_NAME", OBJ_LABEL, 0, 0, 0);
	ObjectSet("LEGEND_NAME", OBJPROP_XDISTANCE, 10);
	ObjectSet("LEGEND_NAME", OBJPROP_YDISTANCE, 20);
	foo = "okee dokee";
	ObjectSetText("LEGEND_NAME",foo,7,"Arial",White);
	
	

	return(0);
}

int testCandlesForRangeSimilarity(double pCandleA, double pCandleB, double pPipRange)
{
   double n3 = MathAbs(pCandleA - pCandleB); //removes negative number
   //Alert(((Point*10)*pPipRange));
   if ( n3 <= ((Point*10)*pPipRange) && n3 >= 0)
   {
      return(1);
   }

   return(0);
}

int drawSellArrow(double pPrice, double pTime, int pIndex)
{
   ObjectCreate ("sellArrow"+pIndex,OBJ_ARROW,0,pTime,pPrice+((Point*10)*2));
	ObjectSet("sellArrow"+pIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
	ObjectSet("sellArrow"+pIndex,OBJPROP_COLOR,Red);
}

int drawBuyArrow(double pPrice, double pTime, int pIndex)
{
   ObjectCreate ("buyArrow"+pIndex,OBJ_ARROW,0,pTime,pPrice-((Point*5)*2));
	ObjectSet("buyArrow"+pIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
	ObjectSet("buyArrow"+pIndex,OBJPROP_COLOR,Green);
}

int previousCandleNotStrongBull(double pOpen, double pClose, double pHigh, double pLow, double pCurrentCandleRange)
{
   if (
      (pOpen < pClose) //bull candle
      && ((pClose - pOpen) < ( pCurrentCandleRange/2 ))
      
      )
      {
         return(1);
      }

   return (0);
}

int notDoji(double pOpen, double pClose, double pHigh, double pLow)
{
		int _wickTopPercent;
		int _wickBottomPercent;

		if (pOpen < pClose)//bullish candle
		{
			_wickTopPercent = ((pHigh - pClose)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pOpen - pLow)/(pHigh - pLow)) * 100;
		}
		else //bearish candle
		{
			_wickTopPercent = ((pHigh - pOpen)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pClose - pLow)/(pHigh - pLow)) * 100;
		}


   if (
         _wickTopPercent >= 30
		   && _wickBottomPercent >= 30
      )
      {
         return(0);
      }

   return (1);
}

int getHammerType(double pOpen, double pClose, double pHigh, double pLow)
{

		int _wickTopPercent;
		int _wickBottomPercent;

		if (pOpen < pClose)//bullish candle
		{
			_wickTopPercent = ((pHigh - pClose)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pOpen - pLow)/(pHigh - pLow)) * 100;
		}
		else //bearish candle
		{
			_wickTopPercent = ((pHigh - pOpen)/(pHigh - pLow)) * 100;
			_wickBottomPercent = ((pClose - pLow)/(pHigh - pLow)) * 100;
		}
		
		
   if ( //bear, bull reversal
		   _wickTopPercent <= 5
		   && _wickBottomPercent >= 40
	   ) 
   {
      return(1);
   }
   else if  //bull, bear reversal
   (
   		_wickTopPercent >= 40
		   && _wickBottomPercent <= 5
   )
   {
      return (2);
   }
   
   return(0);
}