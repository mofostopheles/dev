// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// this is used to build all the fan variations

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
    var black_phone = "_black_phone";
    var pink_phone = "_pink_phone";
    var white_phone = "_white_phone";
    var GARBAGE = "GARBAGE_PLACEHOLDER_phone";
    var GARBAGE2 = "GARBAGE_PLACEHOLDER-2_phone";

    // work these variables and run - this is a manual recursive process

    var layerToReplace = pink_phone;
    var listOfReplacementComps = [white_phone];

    //

    app.beginUndoGroup("dm_render");

    statusReport = "";
    counter = 0;

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
                    for (var c=0; c<listOfReplacementComps.length; c++)
                    {
                        var replacementComp = getComp(listOfReplacementComps[c]);

                        if (replacementComp == null)
                        {
                            alert ("Can't find comp " + listOfReplacementComps[c]);
                            return;
                        }

                        var selectedComp = collectionSelectedComps[k];
                        
                        var ableToReplace = false;

                        //try to find the layer by looping the comp's layer collection
                        for (var j=1; j<=selectedComp.layers.length; j++)
                        {
                            if (selectedComp.layers[j].source != null) //layer must have a source
                            {
                                if (selectedComp.layers[j].source.name.indexOf( layerToReplace ) != -1 )
                                {
                                    selectedComp.layers[j].replaceSource(replacementComp,false);
                                    selectedComp.layers[j].name = replacementComp.name;
                                    ableToReplace = true;
                                    selectedComp.label = 6;
                                    counter++;
                                }      
                            }
                        }

                        if (ableToReplace == false)
                        {
                            alert("couldn't find a layer in " + selectedComp.name + " with name '" + layerToReplace + "'");
                        }
                        else
                        {
                            statusReport += "\n\n" + selectedComp.name + " - replaced '" + layerToReplace + "'' with '" + black_phone + "'"; 
                        }

                    }
                }
            } 
            else 
            {
                alert("Please select at least one comp.");
            }
        }        
    } 

    alert("made " + counter + " replacements. \n" + statusReport);
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

