//+------------------------------------------------------------------+
//|                                         cloud_castle_lake_v1.mq4 |
//|                                     Copyright 2016, Arlo Emerson |
//|                                                          fuckyou |
//+------------------------------------------------------------------+

//this is an expert, peoples.

#property copyright "Copyright 2016, Arlo Emerson"
#property link      "fuckyou"
#property version   "1.00"
#property strict


input int    MovingPeriod=3;
input double TakeProfit    =50;
input double Lots          =0.1;

int _ticketNumber;
double _TP, _SL;
double _point;//Request for Point   
bool _modifyOrder = false;


//globally adjust tp/sl
double _stopLossFactor = 15;
double _takeProfitFactor = 30;

int _labelIndex = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
   double maHigh=iMA(Symbol(),0,MovingPeriod,0,MODE_LWMA,PRICE_HIGH,1);
   double maLow=iMA(Symbol(),0,MovingPeriod,0,MODE_LWMA,PRICE_LOW,1);
   double maClose = iMA(Symbol(),0,17,0,MODE_LWMA,PRICE_CLOSE,1);
   
   double	high		= High[1],
   			low		= Low[1],
   			open		= Open[1],
   			close		= Close[1];
   				
   if(high > maHigh && high > maClose)
   {     
      //open new order
      //  _TP=Bid+_takeProfitFactor*10*_point;
      // _SL=Bid-_stopLossFactor*10*_point;               
      // _ticketNumber = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,_SL,_TP,"orderfoo",16384,0,Red); 
         
      //loop back in time, looking for a breakout candle
      int lookbackLimit = 1000;
      int lowerLimitLookback = 4; //set to 2 if you want to look at all previous candles
      for (int i=0;i<lookbackLimit;i++)
      {
         if ((high < Open[lowerLimitLookback+i]) && (Close[lowerLimitLookback+i] < iMA(Symbol(),0,17,0,MODE_LWMA,PRICE_CLOSE,lowerLimitLookback+i) )
            &&
            (open > maClose)
         )
         {
            string _labelName1 = "asdf";
            ObjectCreate(_labelName1+_labelIndex,OBJ_ARROW,0,Time[1],high);
            ObjectSet(_labelName1+_labelIndex, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
            ObjectSet(_labelName1+_labelIndex,OBJPROP_COLOR,Orange);             
            
            _TP=Bid-0.30;
            _SL=Bid+0.15;  
            
            //Print(_SL," ", _TP);                        
            //_ticketNumber = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",16384,0,Red);            
            //_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);
            
            //draw a line from our signal to the breakout
            ObjectCreate("buysellSRLine" + _labelIndex,OBJ_TREND,0,Time[1], high,Time[i+lowerLimitLookback], high );
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_COLOR,Yellow);
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_WIDTH,1);
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_RAY,false);
                       
            _labelIndex += 1; 
            break;
         }    
      }
      
      //_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);             
   }	   
}

