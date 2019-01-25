// Arlo Emerson, 10/22/2018
// arloemerson@gmail.com

// set a specific layer's inpoint to zero

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

    var layerNameToModify = "lens-specific-TC_Musician_Street_Portrait2_IMG_20180811_185657_EDIT__photo__";
    var layerNameToModify2 = "VC_Danicing_GStore2_MVIMG_20180808_182635_1";
    var layerNameToModify3 = "INDIE_RJ_Glasses_154104_v4_fnl_rgb_output_v3_GRACOL";
    var layerNameToModify4 = "TC_Musician_In_The_Streets_Biking2_IMG_20180811_184555_1";
    var layerNameToModify5 = "MVIMG_20181007_191159__photo__";

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
                var changedErrorMessage = "";

                for (var k=0; k<collectionSelectedComps.length; k++)
                {                                
                    var selectedComp = collectionSelectedComps[k];                    
                    var ableToUpdate = false;
                    
                    //try to find the layer by looping the comp's layer collection
                    for (var j=1; j<=selectedComp.layers.length; j++)
                    {
                        if (selectedComp.layers[j].source != null) //layer must have a source
                        {
                            if ( selectedComp.layers[j].source.name.indexOf( layerNameToModify ) != -1 ||
                            selectedComp.layers[j].source.name.indexOf( layerNameToModify2 ) != -1 ||
                            selectedComp.layers[j].source.name.indexOf( layerNameToModify3 ) != -1 ||
                            selectedComp.layers[j].source.name.indexOf( layerNameToModify4 ) != -1 ||
                            selectedComp.layers[j].source.name.indexOf( layerNameToModify5 ) != -1
                            )
                            {                                
                                $.writeln(selectedComp.layers[j].startTime);
                                
                                selectedComp.layers[j].startTime = 0;
                                selectedComp.layers[j].inPoint = 0;
                                
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
                        changedErrorMessage += selectedComp.name + "\n";
                    } 
                }


                alert("I did not change anything in comp \n" + changedErrorMessage + "\n" + compsChangedCounter + " of " + collectionSelectedComps.length + " comps were changed.");
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

