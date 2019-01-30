/*********************************************************
dumb test
**********************************************************/


// Added functionality to Array object as Adobe does implement modern javascript
if(!Array.prototype.indexOf) 
{
    Array.prototype.indexOf = function(obj) 
    {
        for(var i=0; i<this.length; i++) 
        {
            if(obj===this[i])
            {
                return i;
            }
        }
        return -1;
    };
}

var LABEL_HELP = "1. Enter the layer source name.\n2. Enter the name of a comp to swap with layer.\n3. Select one or more comps.\n4. Click Swap.\n\nYou can undo if you need to.";
var LABEL_LAYER_SOURCE_NAME = "ASFSDAFSDF:";
var LABEL_COMP_REPLACEMENT_NAME = "SADFSADFD:";
var LABEL_SWAP_BUTTON = "Swap layer with comp";
var LABEL_SWAP_UI_BUTTON = "Swap UI";
var LABEL_SWAP_PHOTO_BUTTON = "Swap Photo";
var MARGIN_LEFT = 50;
var SEARCH_STRING_UI = "_ui_";
var SEARCH_STRING_PHOTO = "__photo__";

var win = new Window('palette', 'ESSENCE PRODUCTION TOOLS - Pixel 3 Launch', [300,100,800,800]);
var w = buildUI();

start();

function start()
{
    $.writeln('start');
    w.show();                                  
}

function buildUI()
{
    if (win != null)
    {
        win.spacing = 0;
        win.margins = 10;
                
        //------------------------- PHOTO SWAPPING SECTION  

        var strPhotoSwapping = 
        "panel { orientation:'row', text:'__photo__ swapper', spacing:5, margins:10, \
            foo: Group { orientation:'column', \
                cmds: Group { alignment:['left','top'], \
                    lblLayerToSwap: StaticText { text:'label 1', alignment:['left','center'] }, \
                    swapButton: DropDownList { preferredSize:[200,20], text:'thing 1',  }, \
                }, \
                cmds: Group { alignment:['left','top'], \
                    lblLayerToSwap: StaticText { text:'label 1', alignment:['left','center'] }, \
                    swapButton: DropDownList { text:'thing 1',  }, \
                }, \
            } \
            cmds: Group { alignment:['fill','fill'], swapButton: Button { text:'thing 3', alignment:['fill','fill'] }, }, \
        }";
        
        win.objPhotoSwapping = win.add(strPhotoSwapping);
        
        win.layout.layout(true);                      
    }
    return win;
}


/*
layerRow: Group { alignment:['fill','top'], \
                    lblLayerToSwap: StaticText { text:'" + LABEL_LAYER_SOURCE_NAME + "', alignment:['left','center'] }, \
                    txtLayerToSwap: DropDownList { text:'', characters:30, alignment:['fill','center'], preferredSize:[100,20] }, \
                }, \
                compRow: Group { alignment:['fill','top'], preferredSize:[200,100], \
                    lblCompToSwap: StaticText { text:'" + LABEL_COMP_REPLACEMENT_NAME + "', alignment:['left','center'] }, \
                    txtCompToSwap: DropDownList { text:'', characters:30, alignment:['fill','center'] }, \
                }, \
                */
