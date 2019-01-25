// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// change image position and/or scale

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

    var layerNameToModify = "TC_Musician_Street_Portrait2_IMG_20180811_185657_EDIT__photo__";
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
                            var newX = 0;
                            var newY = 0;
                            var newScale = 0;

                            if (selectedComp.layers[j].source.name.indexOf( layerNameToModify ) != -1)
                            {
                                $.writeln(selectedComp.name);
                                $.writeln("newX = " + selectedComp.layers[j].property("Position").parentProperty("X Position").value + ";");
                                $.writeln("newY = " + selectedComp.layers[j].property("Position").parentProperty("Y Position").value + ";");
                                $.writeln("newScale = " + selectedComp.layers[j].scale.value[0] + ";");

                                //determine what ad size we are in 
                                if (selectedComp.name.indexOf("120x600") > -1)
                                {
                                    newX = 124.928701519966;
                                    newY = 384.729705810547;
                                    newScale = 14.3298740740741;
                                }
                                else if (selectedComp.name.indexOf("160x600") > -1)
                                {
                                    newX = 177.928701519966;
                                    newY = 388.041687011719;
                                    newScale = 15.1567434055513;
                                }
                                else if (selectedComp.name.indexOf("300x250") > -1)
                                {
                                    newX = 305.468026638031;
                                    newY = 62.0417022705078;
                                    newScale = 11.3746293222802;
                                }
                                else if (selectedComp.name.indexOf("300x600") > -1)
                                {
                                    newX = 348.626816034317;
                                    newY = 259.720825195313;
                                    newScale = 22.351888232761;
                                }
                                else if (selectedComp.name.indexOf("320x480") > -1)
                                {
                                    newX = 338;
                                    newY = 168.041687011719;
                                    newScale = 19.2250229762151;
                                }
                                else if (selectedComp.name.indexOf("336x280") > -1)
                                {
                                    newX = 341.468026638031;
                                    newY = 69.0417022705078;
                                    newScale = 13.0384615384615;
                                }
                                else if (selectedComp.name.indexOf("480x320") > -1)
                                {
                                    newX = 474.468026638031;
                                    newY = 101.041702270508;
                                    newScale = 18.0279194649808;
                                }
                                else if (selectedComp.name.indexOf("640x480") > -1)
                                {
                                    newX = 654;
                                    newY = 285.0417;
                                    newScale = 24.3;
                                }

                                // do the update
                                selectedComp.layers[j].scale.setValue( [newScale, newScale] );                                                                
                                selectedComp.layers[j].property("Position").parentProperty("X Position").setValue(newX);
                                selectedComp.layers[j].property("Position").parentProperty("Y Position").setValue(newY);

                                /*
                                for (var foo in selectedComp.layers[j].property("Position"))
                                {
                                    $.writeln(foo, 1);
                                }
                                */
                                //selectedComp.layers[j].property.position.setValue( [newX, newY]  );
                                //$.writeln( selectedComp.layers[j].position.value );
                                
                                ableToUpdate = true;
                                compsChangedCounter++;
                                //alert("update complete");
                                selectedComp.label = 9;                         
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

