//+------------------------------------------------------------------+
//|                                              ae_water_damage.mq4 |
//|                                                     Arlo Emerson |
//|                                          www.thedamagereport.com |
//+------------------------------------------------------------------+
#property copyright "Arlo Emerson"
#property link      "www.thedamagereport.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
  
 int _labelIndex = 0;
 int minus1CandleIndex = 0;
 
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   _labelIndex += 1;
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(open,false);

   
   ObjectCreate("leftWallCandidateLine",OBJ_ARROW,0,minus1CandleIndex, close);
	ObjectSet("leftWallCandidateLine", OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
	ObjectSet("leftWallCandidateLine",OBJPROP_COLOR,0x333333);
					
					
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
