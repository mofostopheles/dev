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

string _sym = Symbol();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   _sym = Symbol();
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
   double maHigh=iMA(_sym,0,MovingPeriod,0,MODE_LWMA,PRICE_HIGH,1);
   double maLow=iMA(_sym,0,MovingPeriod,0,MODE_LWMA,PRICE_LOW,1);
   double maClose = iMA(_sym,0,17,0,MODE_LWMA,PRICE_CLOSE,1);
   
   
   
   double	high		= High[1],
   			low		= Low[1],
   			open		= Open[1],
   			close		= Close[1];
   
   //quick and dirty way to find hammers and wicky candles			
   if(
      1==1
      //&&
      //iCCI(NULL, 0, 21,  PRICE_WEIGHTED, 1) > -100 //removes a little noise
      //high > maHigh
      //&& 
      //high > maClose
      //&&
      //open > maClose
      //&&
      //open > iMA(_sym,0,50,0,MODE_EMA,PRICE_HIGH,1)
      //&&
      //close > iMA(_sym,0,50,0,MODE_EMA,PRICE_HIGH,1)
      )
   {     
      //open new order
      //  _TP=Bid+_takeProfitFactor*10*_point;
      // _SL=Bid-_stopLossFactor*10*_point;               
      // _ticketNumber = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,_SL,_TP,"orderfoo",16384,0,Red); 
         
      //loop back in time, looking for a breakout candle
      int lookbackLimit = 500;
      int lowerLimitLookback = 2; //set to 2 if you want to look at all previous candles
      int filterOutCandlesLessThan = 10;
      int blockingCandleIndex = -1;
            
      for (int i=0;i<lookbackLimit;i++)
      {

         
         //PRIMARY FILTRATION - find a bear candle
         //this candle blocks further lookback
         //TO DO 
         //is this candle the breakout or part of a breakout
         //??
         //you can do this by using CCI/21 and walking forward from the breakout
         //if CCI dips below -100 then your downtrend stuck
         if (         
               high < Open[lowerLimitLookback+i]
               &&
               high > Close[lowerLimitLookback+i]              
         )
         {         
            blockingCandleIndex = lowerLimitLookback+i;
            break;                     
         }         
       }      
            
      double tmpThing1 = iMA(_sym,0,17,0,MODE_LWMA,PRICE_CLOSE,blockingCandleIndex);
      double tmpThing2 = iMA(_sym,0,50,0,MODE_EMA,PRICE_HIGH,blockingCandleIndex);
         
      //SECONDARY FILTER - prove that bear candle is not at the end of a downtrend            
      if (  
            blockingCandleIndex != -1
            //&&          
            //Open[blockingCandleIndex] > iMA(_sym,0,17,0,MODE_LWMA,PRICE_WEIGHTED,blockingCandleIndex)
            //&&
            //Close[blockingCandleIndex] < Low[blockingCandleIndex+1]
            //&&
            //Close[blockingCandleIndex] < Low[blockingCandleIndex+2]
            //&&
            //Close[blockingCandleIndex] < Low[blockingCandleIndex+3]
            //&&
            //iCCI(NULL, 0, 21,  PRICE_WEIGHTED, blockingCandleIndex) >= 0
            
         //Close[lowerLimitLookback+i] < iMA(_sym,0,17,0,MODE_LWMA,PRICE_CLOSE,lowerLimitLookback+i)
         
         
      //(high < Open[lowerLimitLookback+i])
      //&&
      //(Close[lowerLimitLookback+i] < tmpThing1 )
      
      
      //&&
      //(Low[lowerLimitLookback+i] > tmpThing2 )
      
      //(i > filterOutCandlesLessThan)
      )
      {                  
      
      int candidateFound = 0;
      
        //now we take our CCI/21 walk
        //no need to walk farther than where our signal is
        for(int k=1;k<blockingCandleIndex;k++)
        {
            double tmpCCI = iCCI(NULL, 0, 21,  PRICE_WEIGHTED, blockingCandleIndex - k);
            
            if (tmpCCI < -100)
            {
            candidateFound = 1;
            break;
            }            
        }
        
        if (candidateFound == 1)
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
            ObjectCreate("buysellSRLine" + _labelIndex,OBJ_TREND,0, Time[1], high, Time[blockingCandleIndex], high );
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_COLOR,Yellow);
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_WIDTH,1);
            ObjectSet("buysellSRLine" + _labelIndex,OBJPROP_RAY,false);
                 
            _labelIndex += 1; 
         }
      }
            
            
      
      
      //_modifyOrder = OrderModify(_ticketNumber, OrderOpenPrice(), _SL,_TP, 0);             
   }	   
}

