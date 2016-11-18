

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

		//CCI boundary recross detector
		int cciLow = 100;
		cciLow *= -1;
		int cciActual = iCCI(Sym,0,14,PRICE_TYPICAL,i);
		int cciActualTwoCandlesToRight = iCCI(Sym,0,14,PRICE_TYPICAL,i-2);


		//uptrend
		if( cciActual < cciLow && low < EMA_C[i] && cciActualTwoCandlesToRight > cciLow)
		{
			//ObjectDelete("V-Line" + i);
			/*
			ObjectCreate("V-Line" + i,OBJ_VLINE,0,Time[i],0);
			ObjectSet("V-Line" + i,OBJPROP_COLOR,Orange);
			ObjectSet("V-Line" + i,OBJPROP_STYLE,1);
			ObjectSet("V-Line" + i,OBJPROP_WIDTH,1);
			ObjectSet("V-Line" + i,OBJPROP_BACK,true);
			*/
			ObjectCreate("label_"+i, OBJ_TEXT, 0, Time[i-2], low);
			ObjectSetText("label_"+i,"BUY",8,"Arial",Yellow);
		}

		//dowtrend
		if( cciActual > 100 && high > EMA_C[i]  && cciActualTwoCandlesToRight < 100)
		{
			//Alert(i);
			//ObjectDelete("V-Line" + i);
			/*
			ObjectCreate("V-Line" + i,OBJ_VLINE,0,Time[i],0);
			ObjectSet("V-Line" + i,OBJPROP_COLOR,Orange);
			ObjectSet("V-Line" + i,OBJPROP_STYLE,1);
			ObjectSet("V-Line" + i,OBJPROP_WIDTH,1);
			ObjectSet("V-Line" + i,OBJPROP_BACK,true);
			*/
			ObjectCreate("label_"+i, OBJ_TEXT, 0, Time[i-2], low);
			ObjectSetText("label_"+i,"SELL",8,"Arial",Green);
		}
	}

	return(0);
}