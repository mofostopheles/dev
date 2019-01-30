// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// Make duplicate comps from selected comps and replace the background with other background colors

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

    var comp1 = "_background-licorice";
    var comp2 = "_background-rockcandy";
    var comp3 = "_background-sand";

    var listOfBGComps = [comp1, comp2];

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
                        tmpItem = selectedComp.duplicate();

                        tmpItem.name = selectedComp.name.replace( "sand", replacementComp.name.substring( replacementComp.name.indexOf("-")+1  ) );
                        var layerToReplace = tmpItem.layer( tmpItem.layers.length );
                        layerToReplace.replaceSource(replacementComp,false);

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

