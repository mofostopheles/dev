/*
   mark high volume reversal and h1/h2 etc turns
   this is fine tuned for a 5-minute EURUSD chart
   author:  Arlo Emerson
   date:    7/15/2012
*/


#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 2
#property indicator_color1  DodgerBlue
#property indicator_color2  Red

#define    SECINMIN         60  //Number of seconds in a minute

extern int  TimeFrame		= 5;

extern int vsiMAPeriod    = 21;  //Period for the moving average.
extern int vsiMAType      = 0;  //Moving average type. 0 = SMA, 1 = EMA, 2 = SMMA, 3 = LWMA
extern int showPerPeriod  = 0;  //0 = volume per second, 1 = volume per chart period
                                /* Volume per second allows you to compare values for different
                                   chart periods. Otherwise the values it will show will only be
                                   valid for the chart period you are viewing. The graph will
                                   look exactly the same but the values will be different. */

double vsiBuffer[];
double vsiMABuffer[];

string Sym = "";

string _labelName1 = "volumeArrow";

string _labelName2 = "hhll_";

string _previousLabel = "";
int _hhIndex = 1;
int _llIndex = 1;

//bool _reversalVolumeFound = false;
//bool _hhHighVolumeFound = false;
 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{

   string vsiTitle = "volume and price - imminent trends - v3";
   Sym = Symbol();
   
   SetIndexStyle(0,DRAW_HISTOGRAM,1,4);
   SetIndexStyle(1,DRAW_LINE,1,4);

   SetIndexBuffer(0, vsiBuffer);
   SetIndexBuffer(1, vsiMABuffer);
   IndicatorShortName(vsiTitle);
   SetIndexLabel(0, vsiTitle);
   SetIndexLabel(1, "vsiMA(" + vsiMAPeriod + ")");
   SetIndexDrawBegin(1, vsiMAPeriod);

	//ObjectsDeleteAll();
	
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

int start()
{
   int i, limit, timeDiff;
   int counted_bars = IndicatorCounted();

   if(counted_bars >= 0) {

      //If counted bars is greater than zero we must subtract 1 so we get in the right position
      if(counted_bars > 0) {
         counted_bars--;
      }

      //Only count bars we haven't already drawn
      limit = Bars - counted_bars;

      for(i = 0; i < limit; i++)
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
      double minus5CandleOpen = iOpen(NULL,TimeFrame,shift1+5);
      
      double minus6CandleLow = iLow(NULL,TimeFrame,shift1+6);
		double minus6CandleHigh = iHigh(NULL,TimeFrame,shift1+6);
      double minus6CandleClose = iClose(NULL,TimeFrame,shift1+6);
      double minus6CandleOpen = iOpen(NULL,TimeFrame,shift1+6);	
      
      string _signalPriceAttributes = ""; //CURRENT
      string _minus1PriceAttributes = "";
      string _minus2PriceAttributes = "";
      string _minus3PriceAttributes = "";				

//***************** BEGIN VSI ENGINE ******************//					    
			//Difference between the current time and the bar start
         timeDiff = CurTime() - Time[i];

         //If we are in the current bar and the tick doesn't fall exactly on the '00:00' min & sec
         if(i == 0 && timeDiff > 0) {
            vsiBuffer[i] = Volume[i] / timeDiff;
         } else {
            //Otherwise calculate the total bar volume divided by the total bar seconds
            vsiBuffer[i] = Volume[i] / (Time[i - 1] - Time[i]);
         }

         if(showPerPeriod == 1) {
            vsiBuffer[i] = vsiBuffer[i] * Period() * SECINMIN;
         }

         vsiMABuffer[i] = iMAOnArray(vsiBuffer, Bars, vsiMAPeriod, 0, vsiMAType, i);
//***************** END VSI ENGINE ******************//


            
//***************** BEGIN HH/LL DATA CAPTURE ******************//
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
//***************** END HH/LL DATA CAPTURE ******************//		       
		       
		       
      
      double _volume = vsiBuffer[shift1];
		double minus1Volume = vsiBuffer[shift1+1];
      double minus2Volume = vsiBuffer[shift1+2];
      double minus3Volume = vsiBuffer[shift1+3];
		double minus4Volume = vsiBuffer[shift1+4];
      double minus5Volume = vsiBuffer[shift1+5];
      double minus6Volume = vsiBuffer[shift1+6];
      double minus7Volume = vsiBuffer[shift1+7];

      double _volumeLimit = 0.95;
      int _lineLength = 50;
      color _tmpColor = Orange; 
      
      /*
         pseudo rules:
         - if candle 1 and 2 are both same direction, and volume is up, paint a directional arrow (prices may surge)
         - if previous candle is different direction than current candle, paint a stop sign (prices may reverse)
      
      
      */


      if (  _volume >= _volumeLimit
            && minus1Volume >= _volumeLimit
         )
         { 
            if (
               open < close
               && minus1CandleOpen < minus1CandleClose
            )
            {
               //bullish volume
               ObjectCreate (_labelName1+i,OBJ_ARROW,0,Time[i],low);
               ObjectSet(_labelName1+i, OBJPROP_ARROWCODE, SYMBOL_ARROWUP);
               ObjectSet(_labelName1+i,OBJPROP_COLOR,Green);               
            }
            else if (
               open > close
               && minus1CandleOpen > minus1CandleClose
            )
            {
               //bearish volume
               ObjectCreate (_labelName1+i,OBJ_ARROW,0,Time[i],high);
               ObjectSet(_labelName1+i, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
               ObjectSet(_labelName1+i,OBJPROP_COLOR,Red);               
            }
            //reversal imminent
            else if ( 
               open > close 
               && minus1CandleOpen < minus1CandleClose
            )
            {
               //bear following a bull
               ObjectCreate (_labelName1+i,OBJ_ARROW,0,Time[i],high);
               ObjectSet(_labelName1+i, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
               ObjectSet(_labelName1+i,OBJPROP_COLOR,Orange);   
                      
            }
            else if (
               open < close
               && minus1CandleOpen > minus1CandleClose
            )
            {
               //bull following a bear
               ObjectCreate (_labelName1+i,OBJ_ARROW,0,Time[i],low);
               ObjectSet(_labelName1+i, OBJPROP_ARROWCODE, SYMBOL_STOPSIGN);
               ObjectSet(_labelName1+i,OBJPROP_COLOR,Orange);    
                       
            }
         }  
         
      ///BEGIN MARKUP OF HH/LL
         
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
              
           ObjectCreate(_labelName2+i,OBJ_TEXT,0,Time[i],low);
           //ObjectSet(_labelName2+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
           //ObjectSet(_labelName+i,OBJPROP_COLOR,Green);
           
            _tmpColor = Green;           
            if (  _volume < _volumeLimit && minus1Volume < _volumeLimit ){  _tmpColor = LightGray;}
            ObjectSetText(_labelName2+i,"H"+_hhIndex,7,"Arial",_tmpColor);
               
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
                                            
           ObjectCreate(_labelName2+i,OBJ_TEXT,0,Time[i],high+((Point*10)*2));
           //ObjectSet(_labelName2+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
           //ObjectSet(_labelName+i,OBJPROP_COLOR,Red);   
           
            _tmpColor = Red;           
            if (  _volume < _volumeLimit && minus1Volume < _volumeLimit ){  _tmpColor = LightGray;}
            ObjectSetText(_labelName2+i,"L"+_llIndex,7,"Arial",_tmpColor);
            
           _previousLabel = "LL";
        }
     }
    
	
  	   //end outer chart array    	
      }
	
	}//end outer if statement


	return(0);
}

