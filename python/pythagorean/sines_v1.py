import math
import datetime
from matplotlib.pyplot import figure, show
from numpy import arange, sin, pi

#http://matplotlib.org/api/pyplot_api.html

'''

arlo emerson
arloemerson@gmail.com

november 2016, deep into the night

we're trying to figure out the interference pattern for 3:2 pythagorean frequency series
i.e. the notes on the piano

it must be made of several oscillations

this script aims to determine if this is true

'''

class Plotter(object):

    def __init__(self, name, experiment):
        self.name = name
        self.experiment = experiment
        
        
            
        
    def plotSomeStuff(self):      

        # copied from
        # http://matplotlib.org/examples/pylab_examples/pythonic_matplotlib.html
        """
        Some people prefer to write more pythonic, object-oriented code
        rather than use the pyplot interface to matplotlib.  This example shows
        you how.

        Unless you are an application developer, I recommend using part of the
        pyplot interface, particularly the figure, close, subplot, axes, and
        show commands.  These hide a lot of complexity from you that you don't
        need to see in normal figure creation, like instantiating DPI
        instances, managing the bounding boxes of the figure elements,
        creating and reaslizing GUI windows and embedding figures in them.


        If you are an application developer and want to embed matplotlib in
        your application, follow the lead of examples/embedding_in_wx.py,
        examples/embedding_in_gtk.py or examples/embedding_in_tk.py.  In this
        case you will want to control the creation of all your figures,
        embedding them in application windows, etc.

        If you are a web application developer, you may want to use the
        example in webapp_demo.py, which shows how to use the backend agg
        figure canvase directly, with none of the globals (current figure,
        current axes) that are present in the pyplot interface.  Note that
        there is no reason why the pyplot interface won't work for web
        application developers, however.

        If you see an example in the examples dir written in pyplot interface,
        and you want to emulate that using the true python method calls, there
        is an easy mapping.  Many of those examples use 'set' to control
        figure properties.  Here's how to map those commands onto instance
        methods

        The syntax of set is

          plt.setp(object or sequence, somestring, attribute)

        if called with an object, set calls

          object.set_somestring(attribute)

        if called with a sequence, set does

          for object in sequence:
               object.set_somestring(attribute)

        So for your example, if a is your axes object, you can do

          a.set_xticklabels([])
          a.set_yticklabels([])
          a.set_xticks([])
          a.set_yticks([])
        """

        t = arange(0.0, 12.0, 0.01)

        fig = figure(1)

        ax1 = fig.add_subplot(211)
        ax1.plot(t, sin(2*pi*t))
        ax1.plot(t, sin(3*pi*t))
        ax1.grid(True)
        ax1.set_ylim((-2, 2))
        ax1.set_ylabel('1 Hz')
        ax1.set_title('A sine wave or two')

        for label in ax1.get_xticklabels():
            label.set_color('r')


        ax2 = fig.add_subplot(212)
        ax2.plot(t, sin(2*2*pi*t))
        ax2.grid(True)
        ax2.set_ylim((-2, 2))
        l = ax2.set_xlabel('Hi mom')
        l.set_color('g')
        l.set_fontsize('large')

        show()


##142.0  213.9  319.5  479.3
##-----
##    71.0  106.5  159.8
##          -----
##        35.5   53.3                 x2      x3
##        ----   ----                   \    /
##           17.75                       \  /
##           -----
##         5.92   8.88
##         ----   ----                   /  \
##    1.97    2.96   4.44               /    \
##    ----    ----   ----             /2      /3
##  0.66   0.99   1.48   2.22
##  ----   ----   ----
##0.22  0.33  0.49   0.74  1.11
##      ----  ----   ----  ----
      

        
foo = Plotter("plot something", 1)
foo.plotSomeStuff()
