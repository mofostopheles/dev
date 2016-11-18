

#property link "http://www.forexfactory.com/"
#property indicator_chart_window

#property indicator_buffers 10

#property indicator_color1 Red // long wick up
#property indicator_width1 1
#property indicator_color2 Maroon // long wick down
#property indicator_width2 1
#property indicator_color3 Red // long body up
#property indicator_width3 1
#property indicator_color4 Maroon // long body down
#property indicator_width4 1

#property indicator_color5 Silver
#property indicator_width5 1
#property indicator_style5 2
#property indicator_color6 Silver
#property indicator_width6 1
#property indicator_style6 2
#property indicator_color7 Silver
#property indicator_width7 1
#property indicator_style7 2

//---- input parameters
extern int		TimeFrame		= 0,		// {1=M1, 5=M5, ..., 60=H1, 240=H4, 1440=D1, ...}
					BarWidth			= 1,
					CandleWidth		= 2;

//---- buffers
double ShortWickUp[],	 ShortCandleUp[],
		 ShortWickDown[],	 ShortCandleDown[];

double EMA_H[];
double EMA_L[];
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

	SetIndexBuffer(4,EMA_H);
	SetIndexBuffer(5,EMA_L);
	SetIndexBuffer(6,EMA_C);

	SetIndexStyle(4,DRAW_LINE);
	SetIndexStyle(5,DRAW_LINE);
	SetIndexStyle(6,DRAW_LINE);

	Sym = Symbol();

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

		if(open<=close && close < EMA_L[i])
		{
			ShortWickUp[shift2] = high;		ShortCandleUp[shift2] = bodyHigh;
			ShortWickDown[shift2] = low;		ShortCandleDown[shift2] = bodyLow;
		}
		else if(open>=close && close < EMA_L[i])
		{
			ShortWickUp[shift2] = low;		ShortCandleUp[shift2] = bodyLow;
			ShortWickDown[shift2] = high;		ShortCandleDown[shift2] = bodyHigh;
		}


		double	candleRightHigh = iHigh(NULL,TimeFrame,i-1),
					candleRightLow		= iLow(NULL,TimeFrame,i-1),
					candleRightOpen		= iOpen(NULL,TimeFrame,i-1),
					candleRightClose		= iClose(NULL,TimeFrame,i-1);

		double	candleLeftOneHigh = iHigh(NULL,TimeFrame,i+1),
					candleLeftOneLow		= iLow(NULL,TimeFrame,i+1),
					candleLeftOneOpen		= iOpen(NULL,TimeFrame,i+1),
					candleLeftOneClose		= iClose(NULL,TimeFrame,i+1);

		double	candleLeftTwoHigh = iHigh(NULL,TimeFrame,i+2),
					candleLeftTwoLow		= iLow(NULL,TimeFrame,i+2),
					candleLeftTwoOpen		= iOpen(NULL,TimeFrame,i+2),
					candleLeftTwoClose		= iClose(NULL,TimeFrame,i+2);

		double	candleLeftThreeHigh = iHigh(NULL,TimeFrame,i+3),
					candleLeftThreeLow		= iLow(NULL,TimeFrame,i+3),
					candleLeftThreeOpen		= iOpen(NULL,TimeFrame,i+3),
					candleLeftThreeClose		= iClose(NULL,TimeFrame,i+3);

		//CCI boundary recross detector
		int cciLow = 100;
		cciLow *= -1;
		int cciPeriod = 14;
		int currentCandle = iCCI(Sym,0,cciPeriod,PRICE_TYPICAL,i);
		int lastClosedCandle = iCCI(Sym,0,cciPeriod,PRICE_TYPICAL,i+1);

		int wins = 0;
		int losses = 0;


		//UPTRENDS
		if( lastClosedCandle < cciLow && currentCandle > cciLow)
		{
			ObjectDelete("label_"+i);
			ObjectCreate("label_"+i, OBJ_TEXT, 0, Time[i], close);
			ObjectSetText("label_"+i,"X",7,"Arial",Lime);

			ObjectCreate("entryPrice"+i,OBJ_ARROW,0,Time[i-1],close);
			ObjectSet("entryPrice"+i, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
			ObjectSet("entryPrice"+i,OBJPROP_COLOR,Lime);

			//mark success-fails
			if (open < iLow(NULL,TimeFrame,i-2) )
			{
				ObjectCreate("success_"+i, OBJ_TEXT, 0, Time[i-1], close);
				ObjectSetText("success_"+i,"O",14,"ZapfDingbats",White);
				wins++;
			}
			else
			{
				losses++;
			}

/* MARK BLACK ZONES - areas where CCI reversals do not occur
			//ObjectCreate(ObjName, OBJ_TREND, 0, SetupSBeginDt, SetupSHiPrice, SetupSEndDt, SetupSHiPrice );
			ObjectCreate("horzLine" + i,OBJ_HLINE,0,NULL,close);
			ObjectSet("horzLine" + i,OBJPROP_COLOR,Orange);
			ObjectSet("horzLine" + i,OBJPROP_STYLE,STYLE_SOLID);
			ObjectSet("horzLine" + i,OBJPROP_WIDTH,1);
			//ObjectSet("horzLine" + i,OBJPROP_BACK,true);
			ObjectSet("horzLine" + i, OBJPROP_RAY,true);
*/
		}

		//DOWNTRENDS
		if( lastClosedCandle > 100 && currentCandle < 100)
		{
			//if a bearish candle, very simply enter the trade a couple pips above close
			if (open > close)
			{
				ObjectDelete("label_"+i);
				ObjectCreate("label_"+i, OBJ_TEXT, 0, Time[i], low);
				ObjectSetText("label_"+i,"X",7,"Arial",Red);

				ObjectCreate("entryPrice"+i,OBJ_ARROW,0,Time[i-1],close);
				ObjectSet("entryPrice"+i, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
				ObjectSet("entryPrice"+i,OBJPROP_COLOR,Red);

				//mark success-fails
				if ( iHigh(NULL,TimeFrame,i-2) < close + (Point*10))
				{
					ObjectCreate("success_"+i, OBJ_TEXT, 0, Time[i-1], high);
					ObjectSetText("success_"+i,"O",14,"ZapfDingbats",White);
					wins++;
				}
				else
				{
					losses++;
				}


/* MARK BLACK ZONES - areas where CCI reversals do not occur
				ObjectCreate("horzLine" + i,OBJ_HLINE,0,NULL,close);
				ObjectSet("horzLine" + i,OBJPROP_COLOR,Orange);
				ObjectSet("horzLine" + i,OBJPROP_STYLE,STYLE_SOLID);
				ObjectSet("horzLine" + i,OBJPROP_WIDTH,1);
				//ObjectSet("horzLine" + i,OBJPROP_BACK,true);
				ObjectSet("horzLine" + i, OBJPROP_RAY,true);
*/
			}
			else //a bullish candle, wait until price sinks to low price, then sell
			{
				string labelNameWait = "waitForPrice_";
				ObjectDelete(labelNameWait+i);
				ObjectCreate(labelNameWait+i, OBJ_TEXT, 0, Time[i], high);
				ObjectSetText(labelNameWait+i,"X",7,"Arial",Orange);


				ObjectCreate(labelNameWait+"Price"+i,OBJ_ARROW,0,Time[i],high);
				ObjectSet(labelNameWait+"Price"+i, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
				ObjectSet(labelNameWait+"Price"+i,OBJPROP_COLOR,Orange);

				//mark success-fails
				if (close > (iHigh(NULL,TimeFrame,i-2)+(Point*10) ))
				{
					ObjectCreate("success_"+i, OBJ_TEXT, 0, Time[i-1], high);
					ObjectSetText("success_"+i,"O",14,"ZapfDingbats",White);
					wins++;
				}
				else
				{
					losses++;
				}


/* MARK BLACK ZONES - areas where CCI reversals do not occur
				ObjectCreate("horzLine" + i,OBJ_HLINE,0,NULL,high);
				ObjectSet("horzLine" + i,OBJPROP_COLOR,Orange);
				ObjectSet("horzLine" + i,OBJPROP_STYLE,STYLE_SOLID);
				ObjectSet("horzLine" + i,OBJPROP_WIDTH,1);
				//ObjectSet("horzLine" + i,OBJPROP_BACK,true);
				ObjectSet("horzLine" + i, OBJPROP_RAY,true);
*/
			}
		}
	}

	return(0);
}