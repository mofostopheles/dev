/*
   

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

string Sym = "";


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
	Sym = Symbol();
	ObjectsDeleteAll();
	return(0);
}

int start()
{
   string _toPrint = "";

   //Bars-1-IndicatorCounted()
	for(int i = 500; i >= 0; i--)
	{
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

/*
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
*/                                    		
		
		bool _trendImminent = false;
		string _trendDirection = "";
		
		//find a candle that begins a massive trend
		
		int _pipMove = 10;
	
		if (close - minus12CandleClose > ((Point*10)*_pipMove) )
		{
         ObjectCreate("bigUptrend"+i,OBJ_ARROW,0,Time[i+12],minus12CandleLow);
         ObjectSet("bigUptrend"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
         ObjectSet("bigUptrend"+i,OBJPROP_COLOR,Green);
         
         _trendImminent = true;
         _trendDirection = "\"bull\", ";
		}
		
	
		if (minus12CandleClose - close > ((Point*10)*_pipMove) )
		{
         ObjectCreate("bigDowntrend"+i,OBJ_ARROW,0,Time[i+12],minus12CandleHigh);
         ObjectSet("bigDowntrend"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
         ObjectSet("bigDowntrend"+i,OBJPROP_COLOR,Red);
         
         _trendImminent = true;
         _trendDirection = "\"bear\", ";
		}
		
		string _signalMatrix = "";
		string _signalPriceAttributes = ""; //12 back
		string _minus13PriceAttributes = "";
		string _minus14PriceAttributes = "";
		string _minus15PriceAttributes = "";
		
		if (_trendImminent == true)
		{
		
		    /*
		    * MINUS 12 CANDLE PRICE ATTRIBUTES
		    */
		
		    //HIGHS AND LOWS
		    //higher minus12CandleHigh "hh"
		    if (minus12CandleHigh > minus13CandleHigh)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"hh|");
		    }
		
		    //lower minus12CandleHigh "lh"
		    if (minus12CandleHigh < minus13CandleHigh)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"lh|");
		    }
		
		    //lower minus12CandleLow "ll"
		    if (minus12CandleLow < minus13CandleLow)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"ll|");
		    }
		
		    //higher minus12CandleLow "hl"
		    if (minus12CandleLow > minus13CandleLow)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"hl|");
		    }
				
		    //same minus12CandleHigh "sh"
		    if (minus12CandleHigh == minus13CandleHigh)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"sh|");
		    }
		
		    //same minus12CandleLow "sl"
		    if (minus12CandleLow == minus13CandleLow)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"sl|");
		    }
		
		    //OPENS AND CLOSE
		    //higher minus12CandleClose "hc"
		    if (minus12CandleClose > minus13CandleClose)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"hc|");
		    }		
		
		    //lower minus12CandleClose "lc"
		    if (minus12CandleClose < minus13CandleClose)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"lc|");
		    }
				
		    //lower minus12CandleOpen "lo"
		    if (minus12CandleOpen < minus13CandleOpen)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"lo|");
		    }
				
		    //higher minus12CandleOpen "ho"
		    if (minus12CandleOpen > minus13CandleOpen)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"ho|");
		    }
				
		    //same minus12CandleOpen "so"
		    if (minus12CandleOpen == minus13CandleOpen)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"so|");
		    }		
		
		    //same minus12CandleClose "sc"
		    if (minus12CandleClose == minus13CandleClose)
		    {
             _signalPriceAttributes = StringConcatenate(_signalPriceAttributes,"sc|");
		    }
		    
		    
		    _signalMatrix = StringConcatenate(_trendDirection , " ", _signalMatrix, "\"", _signalPriceAttributes, "\", ");
		    
	
	
/*
* MINUS 13 CANDLE PRICE ATTRIBUTES
*/
		
		    //HIGHS AND LOWS
		    //higher minus13CandleHigh "hh"
		    if (minus13CandleHigh > minus14CandleHigh)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"hh|");
		    }
		
		    //lower minus13CandleHigh "lh"
		    if (minus13CandleHigh < minus14CandleHigh)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"lh|");
		    }
		
		    //lower minus13CandleLow "ll"
		    if (minus13CandleLow < minus14CandleLow)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"ll|");
		    }
		
		    //higher minus13CandleLow "hl"
		    if (minus13CandleLow > minus14CandleLow)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"hl|");
		    }
				
		    //same minus13CandleHigh "sh"
		    if (minus13CandleHigh == minus14CandleHigh)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"sh|");
		    }
		
		    //same minus13CandleLow "sl"
		    if (minus13CandleLow == minus14CandleLow)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"sl|");
		    }
		
		    //OPENS AND CLOSE
		    //higher minus13CandleClose "hc"
		    if (minus13CandleClose > minus14CandleClose)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"hc|");
		    }		
		
		    //lower minus13CandleClose "lc"
		    if (minus13CandleClose < minus14CandleClose)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"lc|");
		    }
				
		    //lower minus13CandleOpen "lo"
		    if (minus13CandleOpen < minus14CandleOpen)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"lo|");
		    }
				
		    //higher minus13CandleOpen "ho"
		    if (minus13CandleOpen > minus14CandleOpen)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"ho|");
		    }
				
		    //same minus13CandleOpen "so"
		    if (minus13CandleOpen == minus14CandleOpen)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"so|");
		    }		
		
		    //same minus13CandleClose "sc"
		    if (minus13CandleClose == minus14CandleClose)
		    {
             _minus13PriceAttributes = StringConcatenate(_minus13PriceAttributes,"sc|");
		    }	

         _signalMatrix = StringConcatenate(_signalMatrix,"\"", _minus13PriceAttributes, "\", ");
/*
* MINUS 14 CANDLE PRICE ATTRIBUTES
*/
		
		    //HIGHS AND LOWS
		    //higher minus14CandleHigh "hh"
		    if (minus14CandleHigh > minus15CandleHigh)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"hh|");
		    }
		
		    //lower minus14CandleHigh "lh"
		    if (minus14CandleHigh < minus15CandleHigh)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"lh|");
		    }
		
		    //lower minus14CandleLow "ll"
		    if (minus14CandleLow < minus15CandleLow)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"ll|");
		    }
		
		    //higher minus14CandleLow "hl"
		    if (minus14CandleLow > minus15CandleLow)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"hl|");
		    }
				
		    //same minus14CandleHigh "sh"
		    if (minus14CandleHigh == minus15CandleHigh)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"sh|");
		    }
		
		    //same minus14CandleLow "sl"
		    if (minus14CandleLow == minus15CandleLow)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"sl|");
		    }
		
		    //OPENS AND CLOSE
		    //higher minus14CandleClose "hc"
		    if (minus14CandleClose > minus15CandleClose)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"hc|");
		    }		
		
		    //lower minus14CandleClose "lc"
		    if (minus14CandleClose < minus15CandleClose)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"lc|");
		    }
				
		    //lower minus14CandleOpen "lo"
		    if (minus14CandleOpen < minus15CandleOpen)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"lo|");
		    }
				
		    //higher minus14CandleOpen "ho"
		    if (minus14CandleOpen > minus15CandleOpen)
		    {
		       //_minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,minus14CandleOpen, "_a_", minus15CandleOpen );
		       
		       
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"ho|");
		    }
				
		    //same minus14CandleOpen "so"
		    if (minus14CandleOpen == minus15CandleOpen)
		    {
		    
		       //_minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,minus14CandleOpen, "_b_", minus15CandleOpen );
		    
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"so|");
		    }		
		
		    //same minus14CandleClose "sc"
		    if (minus14CandleClose == minus15CandleClose)
		    {
             _minus14PriceAttributes = StringConcatenate(_minus14PriceAttributes,"sc|");
		    }	
		    	    	
         _signalMatrix = StringConcatenate( _signalMatrix, "\"", _minus14PriceAttributes, "\",");
         
         
         _toPrint = StringConcatenate(_toPrint, "\n", _signalMatrix);
         
      } 	
	}

	   int handle;
   datetime orderOpen=OrderOpenTime();
   handle=FileOpen("500_sample_size_USDJPY_10pips.txt", FILE_CSV|FILE_WRITE, ';');
   if(handle>0)
   {
      FileWrite(handle, _toPrint);
      FileClose(handle);
   }

	return(0);
}