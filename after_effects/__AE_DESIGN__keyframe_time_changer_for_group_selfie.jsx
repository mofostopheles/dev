// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// repo keyframes for group selfie

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
    app.beginUndoGroup("repo_keyframes");

    var layerNameToModify = "INDIE_RJ_HikeSelfie_194315_v8_EDIT__photo__";
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

                        // extend each layer to match comp length
                        selectedComp.layers[j].outPoint = selectedComp.duration;

                        if (selectedComp.layers[j].source != null) //layer must have a source
                        {
                            var newYKeyframeValue = 0; // use this to update the layer's Y position

                            if (selectedComp.layers[j].source.name.indexOf( layerNameToModify ) != -1)
                            {
                                var fps = 12;
                                var key1Time = selectedComp.layers[j].position.keyTime(1);
                                var key2Time = selectedComp.layers[j].position.keyTime(2);
                                var key1Value = selectedComp.layers[j].position.keyValue(1);
                                var key2Value = selectedComp.layers[j].position.keyValue(2);

                                var scaleKey1Value = selectedComp.layers[j].scale.keyValue(1);
                                var scaleKey2Value = selectedComp.layers[j].scale.keyValue(2);

                                //this is used to identify which item in the position array to use
                                var indexOfPosition = 1; //use 0,1,2 for X,Y or Z

                                $.writeln(scaleKey1Value); 

                                var key1FrameNumber = Math.round(key1Time*fps);
                                var key2FrameNumber = Math.round(key2Time*fps);

                                // this is the way to update keyframes if the property is not split
                                /*
                                var key1inInterp = selectedComp.layers[j].position.keyInInterpolationType(1);
                                var key1outInterp = selectedComp.layers[j].position.keyOutInterpolationType(1);

                                var key2inInterp = selectedComp.layers[j].position.keyInInterpolationType(2);
                                var key2outInterp = selectedComp.layers[j].position.keyOutInterpolationType(2);

                                var key3inInterp = selectedComp.layers[j].position.keyInInterpolationType(3);
                                var key3outInterp = selectedComp.layers[j].position.keyOutInterpolationType(3);
                                */

                                // the position prop was split into two, so Y Position must be accessed via parentProperty:
                                var key1inInterp = selectedComp.layers[j].property("Position").parentProperty("Y Position").keyInInterpolationType(1);
                                var key1outInterp = selectedComp.layers[j].property("Position").parentProperty("Y Position").keyOutInterpolationType(1);

                                var key2inInterp = selectedComp.layers[j].property("Position").parentProperty("Y Position").keyInInterpolationType(2);
                                var key2outInterp = selectedComp.layers[j].property("Position").parentProperty("Y Position").keyOutInterpolationType(2);

                                //do the same for scale
                                var scaleKey1inInterp = selectedComp.layers[j].property("Scale").keyInInterpolationType(1);
                                var scaleKey1outInterp = selectedComp.layers[j].property("Scale").keyOutInterpolationType(1);

                                var scaleKey2inInterp = selectedComp.layers[j].property("Scale").keyInInterpolationType(2);
                                var scaleKey2outInterp = selectedComp.layers[j].property("Scale").keyOutInterpolationType(2);


                                //remove in reverse 
                                selectedComp.layers[j].position.removeKey(2); 
                                selectedComp.layers[j].position.removeKey(1); 

                                selectedComp.layers[j].scale.removeKey(2); 
                                selectedComp.layers[j].scale.removeKey(1); 


                                //set the destination frames here
                                //12, 17, 29

                                var kf1 = 2;
                                var kf2 = 6;
                                key1NewTime = kf1*selectedComp.frameDuration;
                                key2NewTime = kf2*selectedComp.frameDuration;


                                // the position prop was split into two, so Y Position must be accessed via parentProperty:
                                selectedComp.layers[j].property("Position").parentProperty("Y Position").setValueAtTime(key1NewTime, key1Value[indexOfPosition]);
                                selectedComp.layers[j].property("Position").parentProperty("Y Position").setValueAtTime(key2NewTime, key2Value[indexOfPosition]);
                               
                                selectedComp.layers[j].property("Position").parentProperty("Y Position").setInterpolationTypeAtKey(1, key1inInterp, key1outInterp);
                                selectedComp.layers[j].property("Position").parentProperty("Y Position").setInterpolationTypeAtKey(2, key2inInterp, key2outInterp);

                                //do the same for scale
                                selectedComp.layers[j].property("Scale").setValueAtTime(key1NewTime, scaleKey1Value);
                                selectedComp.layers[j].property("Scale").setValueAtTime(key2NewTime, scaleKey2Value);
                               
                                selectedComp.layers[j].property("Scale").setInterpolationTypeAtKey(1, scaleKey1inInterp, scaleKey1outInterp);
                                selectedComp.layers[j].property("Scale").setInterpolationTypeAtKey(2, scaleKey2inInterp, scaleKey2outInterp);


                                /* this is the way to update keyframes if the property is not split
                                selectedComp.layers[j].position.setValueAtTime(key1NewTime, key1Value[indexOfPosition]);
                                selectedComp.layers[j].position.setValueAtTime(key2NewTime, key2Value[indexOfPosition]);
                                selectedComp.layers[j].position.setValueAtTime(key3NewTime, key3Value[indexOfPosition]);
                                
                                selectedComp.layers[j].position.setInterpolationTypeAtKey(1, key1inInterp, key1outInterp);
                                selectedComp.layers[j].position.setInterpolationTypeAtKey(2, key2inInterp, key2outInterp);
                                selectedComp.layers[j].position.setInterpolationTypeAtKey(3, key3inInterp, key3outInterp);
                                */

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

