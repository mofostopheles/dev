// Arlo Emerson, 11/27/2019
// arloemerson@gmail.com

$.level = 2;

// loop a comp and hide the text layers

// see: https://buildmedia.readthedocs.org/media/pdf/after-effects-scripting-guide/latest/after-effects-scripting-guide.pdf

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

start();

function start() {
    app.beginUndoGroup("work_undo");

    var layer1NameToFind = "asdf";
    var compsChangedCounter = 0;
    var frameTime = 0.033333; //1 frame at 30 FPS

    if (app.project != null) 
    {
        if (app.project.items.length < 1) {
            alert("Please select at least one comp.");
        } else {
            var allComps = app.project.items;                                          
            var selectedComps = 0;
            collectionSelectedComps = new Array();

            for (var i = allComps.length; i >= 1; i--) {
                item = allComps[i];
                if ((item instanceof CompItem) && item.selected) 
                {
                    selectedComps++;
                    collectionSelectedComps[collectionSelectedComps.length] = item;
                }
            }

            if (selectedComps >= 1) {
                for (var k=0; k<collectionSelectedComps.length; k++) {                                
                    var selectedComp = collectionSelectedComps[k];                    
                    var ableToUpdate = false;
                    
                    //try to find the layer of interest by looping the comp's layer collection

                    var arrayOfItems = [];

                    for (var j=1; j<=selectedComp.layers.length; j++) { 
                        // use this block if searching by name                    
                        // if (selectedComp.layers[j].name.indexOf( layer1NameToFind ) != -1){
                        //     arrayOfItems.push( selectedComp.layers[j] );
                        // }
                        // use this block if searching by type 
                        selectedComp.layers[j].matchName
                        if (selectedComp.layers[j].matchName == "ADBE Text Layer"){
                            arrayOfItems.push( selectedComp.layers[j] );
                        }                     
                    }

                    for (var j=0; j<=arrayOfItems.length-1; j++){
                        var tmpLayer = arrayOfItems[j];
                        tmpLayer.enabled = false
                        // var tmpStartTime = arrayOfItems[j].startTime;
                        // tmpLayer.startTime = tmpStartTime + (frameTime*j); 
                    }
     
                }

            } else {
                alert("Please select at least one comp.");
            }
        }        
    } 

    app.endUndoGroup();
}


function getComp(theName)
{
    for (var i = 1; i <= app.project.numItems; i++)
    {
        if ((app.project.item(i) instanceof CompItem) && (app.project.item(i).name == theName))
        {
            return app.project.item(i);
        }
    }
    return null;
}

