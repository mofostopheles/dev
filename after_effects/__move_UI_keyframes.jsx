// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// change keyframe values of specific sizes

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

function start()
{
    app.beginUndoGroup("dm_render");

    var layerNameToModify = "__ui__";
    var compsChangedCounter = 0;

    if (app.project != null) 
    {
        if (app.project.items.length < 1) 
        {
            alert("Please select at least one comp.");
        } 
        else 
        {
            var allComps = app.project.items;                                          
            var selectedComps = 0;
            collectionSelectedComps = new Array();

            for (var i = allComps.length; i >= 1; i--) 
            {
                item = allComps[i];
                if ((item instanceof CompItem) && item.selected) 
                {
                    selectedComps++;
                    collectionSelectedComps[collectionSelectedComps.length] = item;
                    item.label = 1; 
                }
            }

            if (selectedComps >= 1)
            {
                for (var k=0; k<collectionSelectedComps.length; k++)
                {                                
                    var selectedComp = collectionSelectedComps[k];                    
                    var ableToUpdate = false;
                    
                    //try to find the layer by looping the comp's layer collection
                    for (var j=1; j<=selectedComp.layers.length; j++)
                    {
                        if (selectedComp.layers[j].source != null) //layer must have a source
                        {
                            var newYKeyframeValue = 0; // use this to update the layer's Y position

                            if (selectedComp.layers[j].source.name.indexOf( layerNameToModify ) != -1) // this must be a UI
                            {
                                var fps = 12;
                                var key1Time = selectedComp.layers[j].position.keyTime(1);
                                var key2Time = selectedComp.layers[j].position.keyTime(2);
                                var key1Value = selectedComp.layers[j].position.keyValue(1);
                                var key2Value = selectedComp.layers[j].position.keyValue(2);
                                var key1FrameNumber = Math.round(key1Time*fps);
                                var key2FrameNumber = Math.round(key2Time*fps);

                                var key1inInterp = selectedComp.layers[j].position.keyInInterpolationType(1);
                                var key1outInterp = selectedComp.layers[j].position.keyOutInterpolationType(1);

                                var key2inInterp = selectedComp.layers[j].position.keyInInterpolationType(2);
                                var key2outInterp = selectedComp.layers[j].position.keyOutInterpolationType(2);

                                selectedComp.layers[j].position.removeKey(2); //remove in reverse 
                                selectedComp.layers[j].position.removeKey(1); 

                                //set the destination frames here
                                var newIn = 10;
                                var newOut = 18;
                                key1NewTime = newIn*selectedComp.frameDuration;
                                key2NewTime = newOut*selectedComp.frameDuration;

                                selectedComp.layers[j].position.setValueAtTime(key1NewTime, key1Value);
                                selectedComp.layers[j].position.setValueAtTime(key2NewTime, key2Value);

                                selectedComp.layers[j].position.setInterpolationTypeAtKey(1, key1inInterp, key1outInterp);
                                selectedComp.layers[j].position.setInterpolationTypeAtKey(2, key2inInterp, key2outInterp);

                                ableToUpdate = true;

                                selectedComp.label = 9; //change the label color to green

                                compsChangedCounter++;                            
                            }    
                        }
                        else
                        {
                            //alert("layer doesn't have a source.");
                        }
                    }

                    if (!ableToUpdate) //all layers have been checked at this point
                    {
                        alert("I did not change anything in comp \n" + selectedComp.name);
                    } 
                }

                alert(compsChangedCounter + " of " + collectionSelectedComps.length + " comps were changed.");
            } 
            else 
            {
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

