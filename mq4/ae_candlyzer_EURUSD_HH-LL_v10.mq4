/*
   //display h1s and h2s
   //P. 118, h1 and h2s
   author:  Arlo Emerson
   date:    6/21/2012
*/


#property link "http://www.thedamagereport.com/"

#property indicator_separate_window
#property indicator_minimum -5
#property indicator_maximum 5
#property indicator_buffers 2
#property indicator_color1  Red
#property indicator_color2  Green
#property indicator_color3  DodgerBlue

extern int		TimeFrame		= 5,		// {1=M1, 5=M5, ..., 60=H1, 240=H4, 1440=D1, ...}
					BarWidth			= 1,
					CandleWidth		= 2;


double EMA_C[];

extern int vsiMAPeriod = 5;
double vsiBearBuffer[];
double vsiBullBuffer[];
double vsiMABuffer[];

string Sym = "";

string _labelName = "hhll_";
string _previousLabel = "";
int _hhIndex = 1;
int _llIndex = 1;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{

   string vsiTitle = "v.10 - hh and ll";
   
   
   SetIndexBuffer(0, vsiBearBuffer);
   SetIndexBuffer(1, vsiBullBuffer);
   SetIndexStyle(0,DRAW_HISTOGRAM,1,4);
   SetIndexStyle(1,DRAW_HISTOGRAM,1,4);
   
   //SetIndexBuffer(2, vsiMABuffer);
   
   
   IndicatorShortName(vsiTitle);
   SetIndexLabel(0, vsiTitle);
   SetIndexLabel(1, "oatmeal thing");

   SetLevelValue(0, 0.0);

	Sym = Symbol();
	
	//ObjectsDeleteAll();
	
	for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
	{
         string on = ObjectName(iObj);
         if (StringFind(on, _labelName, 0) > -1)
         {
            ObjectDelete(on);
         }
   }
   
   string foo = "";
   ObjectCreate("label_object", OBJ_LABEL, 0, 0, 0);
	ObjectSet("label_object", OBJPROP_XDISTANCE, 850);
	ObjectSet("label_object", OBJPROP_YDISTANCE, 10);
	foo = "Trade with trend. Trade conviction. ";
	ObjectSetText("label_object",foo,7,"Arial",CornflowerBlue);
      
	return(0);
}

int start()
{
   //
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
                                    		
      string _signalPriceAttributes = ""; //CURRENT
      string _minus1PriceAttributes = "";
      string _minus2PriceAttributes = "";
      string _minus3PriceAttributes = "";
      
/*
		       * CURRENT CANDLE PRICE ATTRIBUTES
		       */
		
		       //HIGHS AND LOWS
		       //higher high "hh"
		       if (high > minus1CandleHigh)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"hh|");
		       }
		 
		       //lower high "lh"
		       if (high < minus1CandleHigh)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"lh|");
		       }
		
		       //lower low "ll"
		       if (low < minus1CandleLow)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"ll|");
		       }
		
		       //higher low "hl"
		       if (low > minus1CandleLow)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"hl|");
		       }
				
		       //same high "sh"
		       if (high == minus1CandleHigh)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"sh|");
		       }
		
		       //same low "sl"
		       if (low == minus1CandleLow)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"sl|");
		       }
/*		
		       //OPENS AND CLOSE
		       //higher close "hc"
		       if (close > minus1CandleClose)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"hc|");
		       }		
		
		       //lower close "lc"
		       if (close < minus1CandleClose)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"lc|");
		       }
				
		       //lower open "lo"
		       if (open < minus1CandleOpen)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"lo|");
		       }
				
		       //higher open "ho"
		       if (open > minus1CandleOpen)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"ho|");
		       }
				
		       //same open "so"
		       if (open == minus1CandleOpen)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"so|");
		       }		
		
		       //same close "sc"
		       if (close == minus1CandleClose)
		       {
                _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"sc|");
		       }
*/		    
/*
      * MINUS 1 CANDLE PRICE ATTRIBUTES
      */
		
		          //HIGHS AND LOWS
		          //higher minus1CandleHigh "hh"
		          if (minus1CandleHigh > minus2CandleHigh)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"hh|");
		          }
		
		          //lower minus1CandleHigh "lh"
		          if (minus1CandleHigh < minus2CandleHigh)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"lh|");
		          }
		
		          //lower minus1CandleLow "ll"
		          if (minus1CandleLow < minus2CandleLow)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"ll|");
		          }
		
		          //higher minus1CandleLow "hl"
		          if (minus1CandleLow > minus2CandleLow)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"hl|");
		          }
				
		          //same minus1CandleHigh "sh"
		          if (minus1CandleHigh == minus2CandleHigh)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"sh|");
		          }
		
		          //same minus1CandleLow "sl"
		          if (minus1CandleLow == minus2CandleLow)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"sl|");
		          }
/*		
		          //OPENS AND CLOSE
		          //higher minus1CandleClose "hc"
		          if (minus1CandleClose > minus2CandleClose)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"hc|");
		          }		
		
		          //lower minus1CandleClose "lc"
		          if (minus1CandleClose < minus2CandleClose)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"lc|");
		          }
				
		          //lower minus1CandleOpen "lo"
		          if (minus1CandleOpen < minus2CandleOpen)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"lo|");
		          }
				
		          //higher minus1CandleOpen "ho"
		          if (minus1CandleOpen > minus2CandleOpen)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"ho|");
		          }
				
		          //same minus1CandleOpen "so"
		          if (minus1CandleOpen == minus2CandleOpen)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"so|");
		          }		
		
		          //same minus1CandleClose "sc"
		          if (minus1CandleClose == minus2CandleClose)
		          {
                   _minus1PriceAttributes = StringConcatenate(_minus1PriceAttributes,"sc|");
		          }	
*/
		             
		   /*
   * MINUS 2 CANDLE PRICE ATTRIBUTES
   */

		
		       //HIGHS AND LOWS
		       //higher minus2CandleHigh "hh"
		       if (minus2CandleHigh > minus3CandleHigh)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"hh|");
		       }
		
		       //lower minus2CandleHigh "lh"
		       if (minus2CandleHigh < minus3CandleHigh)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"lh|");
		       }
		
		       //lower minus2CandleLow "ll"
		       if (minus2CandleLow < minus3CandleLow)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"ll|");
		       }
		
		       //higher minus2CandleLow "hl"
		       if (minus2CandleLow > minus3CandleLow)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"hl|");
		       }
				
		       //same minus2CandleHigh "sh"
		       if (minus2CandleHigh == minus3CandleHigh)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"sh|");
		       }
		
		       //same minus2CandleLow "sl"
		       if (minus2CandleLow == minus3CandleLow)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"sl|");
		       }
/*		
		       //OPENS AND CLOSE
		       //higher minus2CandleClose "hc"
		       if (minus2CandleClose > minus3CandleClose)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"hc|");
		       }		
		
		       //lower minus2CandleClose "lc"
		       if (minus2CandleClose < minus3CandleClose)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"lc|");
		       }
				
		       //lower minus2CandleOpen "lo"
		       if (minus2CandleOpen < minus3CandleOpen)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"lo|");
		       }
				
		       //higher minus2CandleOpen "ho"
		       if (minus2CandleOpen > minus3CandleOpen)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"ho|");
		       }
				
		       //same minus2CandleOpen "so"
		       if (minus2CandleOpen == minus3CandleOpen)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"so|");
		       }		
		
		       //same minus2CandleClose "sc"
		       if (minus2CandleClose == minus3CandleClose)
		       {
                _minus2PriceAttributes = StringConcatenate(_minus2PriceAttributes,"sc|");
		       }	
*/

      //P. 118, h1 and h2s
      
      //TODO: 
      /*
         if previous label is L1 and current label is L1, increment to L2. ETC.
         if previous label is h1 and current label is l1, continue 
         if previous label is h1 and current label is h1, increment to h2. ETC.
         if previous label is l1 and current label is h1, continue 
         if previous label is L1,2,etc, and current label is h1, reset L1,2,ETC index to 1
         if previous label is H1,2,etc, and current label is L1, reset H1,2,ETC index to 1
      
      */
          
	  double _tempBullVolume = 0;
	  double _tempBearVolume = 0;


	  	
     if (StringFind(_signalPriceAttributes, "hh|", 0) > -1)//higher high
     {
        if (StringFind(_minus1PriceAttributes, "lh|", 0) > -1)//lower high 
        {
           //in a pullback during a bull trend, this is a buy signal
          
           
           //check what previous label was
           if ( _previousLabel == "HH" )
           {
               _hhIndex += 1;
           }
           else if ( _previousLabel == "LL" )
           {
               _hhIndex = 1;
           }
           
           _tempBullVolume += _hhIndex;
            
           ObjectCreate(_labelName+i,OBJ_TEXT,0,Time[i],low);
           ObjectSet(_labelName+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
           //ObjectSet(_labelName+i,OBJPROP_COLOR,Green);    
           ObjectSetText(_labelName+i,"H"+_hhIndex,7,"Arial",Green);
           
           _previousLabel = "HH";
        }
     }
     else if(StringFind(_signalPriceAttributes, "ll|", 0) > -1)//lower low
     {
        if (StringFind(_minus1PriceAttributes, "hl|", 0) > -1)//higher low
        {
           //in a pullback during a bear trend, this is a sell signal
           
           
           //check what previous label was
           if ( _previousLabel == "LL" )
           {
               _llIndex += 1;
           }
           else if ( _previousLabel == "HH" )
           {
               _llIndex = 1;
           }           
           
           _tempBearVolume -= _llIndex;
           
                                              
           ObjectCreate(_labelName+i,OBJ_TEXT,0,Time[i],high+((Point*10)*2));
           ObjectSet(_labelName+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
           //ObjectSet(_labelName+i,OBJPROP_COLOR,Red);   
           ObjectSetText(_labelName+i,"L"+_llIndex,7,"Arial",Red);
           
           _previousLabel = "LL";
        }
     }
      
      //update volume density window
      vsiBearBuffer[i] = _tempBearVolume;
      vsiBullBuffer[i] = _tempBullVolume;

  	//end outer chart array    	
	}


	return(0);
}

