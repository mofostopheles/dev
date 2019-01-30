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
                            var newXKeyframeValue = 0; 

                            if (selectedComp.layers[j].source.name.indexOf( layerNameToModify ) != -1) // this must be a UI
                            {
                                $.writeln(selectedComp.name);
                                //$.writeln("newX = " + selectedComp.layers[j].property("Position").parentProperty("X Position").value + ";");
                                $.writeln("newXKeyframeValue = " + selectedComp.layers[j].position.keyValue(1)[0] + ";");
                                $.writeln("newYKeyframeValue = " + selectedComp.layers[j].position.keyValue(1)[1] + ";");
                                //$.writeln("newScale = " + selectedComp.layers[j].scale.value[0] + ";");

                                //determine what ad size we are in 
                                if (selectedComp.name.indexOf("120x600") > -1)
                                {
                                    newXKeyframeValue = 723.426330566406;
newYKeyframeValue = 2102.23071289063;
                                }
                                else if (selectedComp.name.indexOf("160x600") > -1)
                                {
                                   newXKeyframeValue = 162.802169799805;
newYKeyframeValue = 786;
                                }
                                else if (selectedComp.name.indexOf("300x250") > -1)
                                {
                                   newXKeyframeValue = 300.5;
newYKeyframeValue = 352;
                                }
                                else if (selectedComp.name.indexOf("300x600") > -1)
                                {
                                   newXKeyframeValue = 302;
newYKeyframeValue = 853.95703125;
                                }
                                else if (selectedComp.name.indexOf("320x480") > -1)
                                {
                                  newXKeyframeValue = 320;
newYKeyframeValue = 675;
                                }
                                else if (selectedComp.name.indexOf("336x280") > -1)
                                {
                                    newXKeyframeValue = 723.426330566406;
newYKeyframeValue = 2109.71569824219;
                                }
                                else if (selectedComp.name.indexOf("480x320") > -1)
                                {
                                    newXKeyframeValue = 479;
newYKeyframeValue = 479.5;
                                }
                                else if (selectedComp.name.indexOf("640x480") > -1)
                                {
                                    newXKeyframeValue = 640;
newYKeyframeValue = 692;
                                }

                                // do the update
                                if (newYKeyframeValue > 0)
                                {
                                    var origX =  selectedComp.layers[j].position.value[0];
                                    var origY =  selectedComp.layers[j].position.value[1];

                                    

                                    var keyframeNumber = 1; //keys are a 1-based array
                                    selectedComp.layers[j].position.setValueAtKey(keyframeNumber, [ newXKeyframeValue, newYKeyframeValue ] );
                                    //selectedComp.layers[j].position.setValueAtKey(keyframeNumber, [ origX, origY ] );
                                    ableToUpdate = true;
                                    compsChangedCounter++;
                                    //alert("update complete");
                                }                                
                            } 
 
                            /* other useful props...
                                var tmpLayer = selectedComp.layers[j];
                                alert(tmpLayer.property("Masks").property("Mask 1"));
                                if (tmpLayer.property("Masks").property("Mask 1") != null)
                                {
                                    tmpLayer.property("Masks").property("Mask 1").remove();
                                }
                                                            
                                tmpLayer.property("Position").setValueAtKey( 1, (0, 100) );
                                tmpLayer.property("Scale").setValue( (50, 50) );
                            */    
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

