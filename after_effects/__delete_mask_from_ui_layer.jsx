// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

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

    var layerNameToReplace = "google_lens_sunglasses-EMEA-FR__ui__"; // <---- this is the SOURCE name of the layer you want to find

    app.beginUndoGroup("dm_render");

    var changeCount = 0;
    var listOfErrors = "";
    var errorCount = 0;

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
                    
                    //try to find the layer by looping the comp's layer collection
                    for (var j=1; j<=selectedComp.layers.length; j++)
                    {
                        if (selectedComp.layers[j].source != null) //layer must have a source
                        {
                            if (selectedComp.layers[j].source.name.indexOf( layerNameToReplace ) != -1 )
                            {
                                var tmpLayer = selectedComp.layers[j];
                                //alert(tmpLayer.property("Masks").property("Mask 1"));
                                if (tmpLayer.property("Masks").property("Mask 1") != null)
                                {
                                    tmpLayer.property("Masks").property("Mask 1").remove();
                                    changeCount++;
                                }
                                else
                                {
                                    errorCount++;
                                    listOfErrors += "\n" + selectedComp.name;
                                    //alert("could not find a layer with name " + layerNameToReplace + "\n" + listOfErrors );
                                }    
                            }                    
                        }
                    }
                }
            } 
            else 
            {
                alert("Please select at least one comp.");
            }

            if (errorCount>0)
            {
                alert(errorCount + " errors found. \nCould not find a layer to change in " + listOfErrors)
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

