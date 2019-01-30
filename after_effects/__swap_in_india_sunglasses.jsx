// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// swap in india sunglasses UI

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

    var comp1 = "UI__google_lens_sunglasses-APAC-INDIA";
    //var comp2 = "_background-rockcandy";
    //var comp3 = "_background-sand";

    var layerNameToReplace = "UI__google_lens_sunglasses-US-EN";

    var listOfBGComps = [comp1];

    app.beginUndoGroup("dm_render");

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
                    for (var c=0; c<listOfBGComps.length; c++)
                    {
                        var replacementComp = getComp(listOfBGComps[c]);

                        if (replacementComp == null)
                        {
                            alert ("Can't find comp " + listOfBGComps[c]);
                            return;
                        }

                        var selectedComp = collectionSelectedComps[k];
                        

/*
                        
                        var layerToReplace = selectedComp.layers.byName( layerNameToReplace );
                        if (layerToReplace)
                        {
                            layerToReplace.replaceSource(replacementComp,false);
                            layerToReplace.name = replacementComp.name;
                        }
                        else
                        {
                        */
                            var ableToReplace = false;

                            //try to find the layer by looping the comp's layer collection
                            for (var j=1; j<=selectedComp.layers.length; j++)
                            {
                                if (selectedComp.layers[j].source != null) //layer must have a source
                                {
                                    if (selectedComp.layers[j].source.name.indexOf( layerNameToReplace ) != -1 )
                                    {
                                        selectedComp.layers[j].replaceSource(replacementComp,false);
                                        selectedComp.layers[j].name = replacementComp.name;
                                        ableToReplace = true;
                                    }      
                                }
                            }

                            if (ableToReplace == false)
                            {
                                alert("couldn't find a layer in this comp with name " + layerNameToReplace);
                            }
                        //}
                    }
                }
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

