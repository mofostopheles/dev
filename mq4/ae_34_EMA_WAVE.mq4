

#property link "http://www.forexfactory.com/"
#property indicator_chart_window

#property indicator_buffers 10



#property indicator_color5 Blue
#property indicator_width5 1
#property indicator_style5 2
#property indicator_color6 Blue
#property indicator_width6 1
#property indicator_style6 2
#property indicator_color7 Blue
#property indicator_width7 1
#property indicator_style7 2

//---- input parameters
extern int		TimeFrame		= 0,		// {1=M1, 5=M5, ..., 60=H1, 240=H4, 1440=D1, ...}
					BarWidth			= 1,
					CandleWidth		= 2;

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
	}

	return(0);
}