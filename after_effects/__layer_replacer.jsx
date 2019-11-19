// Arlo Emerson, 11/15/2019
// arloemerson@gmail.com

// loop a comp and replace each instance of X with X2
// typical usage would be replacing a bunch of optical flares layers with an updated layer

// important: select the comp, and then select the master layer that will be replacing everything found

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

    var layer1NameToFind = "FLARE";
    var renamedDupeLayer = "FLARE";

    var compsChangedCounter = 0;

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
                    
                    var selectedLayer = selectedComp.selectedLayers[0];

                    if (selectedLayer == null) {
                        alert("Select a Layer");
                    } else {

                        //try to find the layer of interest by looping the comp's layer collection

                        var arrayOfItems = [];

                        for (var j=1; j<=selectedComp.layers.length; j++) {                       
                            if (selectedComp.layers[j].name.indexOf( layer1NameToFind ) != -1){
                                arrayOfItems.push( selectedComp.layers[j] );
                            }                     
                        }

                        for (var j=0; j<=arrayOfItems.length-1; j++){
                            //$.writeln(arrayOfItems[j]);
                            var tmpLayer = selectedLayer.duplicate();
                            tmpLayer.moveAfter(arrayOfItems[j]);
                            tmpLayer.enabled = true;
                            tmpLayer.name = renamedDupeLayer;
                            var tmpStartTime = arrayOfItems[j].startTime;
                            arrayOfItems[j].remove();
                            tmpLayer.startTime = tmpStartTime;
                        }

                        //$.writeln( selectedComp.layers[j].name );

                        //duplicate BEAM_MASTER
                        //selectedLayer.duplicate();

                        //ableToUpdate = true;
                        //compsChangedCounter++;
                        //selectedComp.label = 9;  

                    }

                    /*
                    if (!ableToUpdate) //all layers have been checked at this point
                    {
                        alert("I did not change anything in comp \n" + selectedComp.name);
                    } 
                    */
                }

                //alert(compsChangedCounter + " changes were made ");

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

