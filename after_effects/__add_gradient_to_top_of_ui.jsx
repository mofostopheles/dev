// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// add ui_gradient_overlay to the comp
// then scale and position it
// set the transfer function to multiply


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
    app.beginUndoGroup("add_gradient");

    var compToPlace = "ui_gradient_overlay";
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

                    var newLayer = selectedComp.layers.add( getComp(  compToPlace  ) );
                    newLayer.threeDLayer = false;
                    newLayer.blendingMode = BlendingMode.MULTIPLY;
                    newLayer.label = 5;

                    var newX = 0;
                    var newY = 0;
                    var newScale = 0;

                    //determine what ad size we are in 
                    if (selectedComp.name.indexOf("120x600") > -1)
                    {
                        newX = 120;
                        newY = 622.75;
                        newScale = 20.4687;
                    }
                    else if (selectedComp.name.indexOf("160x600") > -1)
                    {
                        newX = 162;
                        newY = 626;
                        newScale = 23.75;
                    }
                    else if (selectedComp.name.indexOf("300x250") > -1)
                    {
                        newX = 300;
                        newY = 241;
                        newScale = 16.875;
                    }
                    else if (selectedComp.name.indexOf("300x600") > -1)
                    {
                        newX = 301;
                        newY = 595.375;
                        newScale = 39.5833;
                    }
                    else if (selectedComp.name.indexOf("320x480") > -1)
                    {
                        newX = 319;
                        newY = 470.5;
                        newScale = 30.3125;
                    }
                    else if (selectedComp.name.indexOf("336x280") > -1)
                    {
                        newX = 335;
                        newY = 270.625;
                        newScale = 19.1146;
                    }
                    else if (selectedComp.name.indexOf("480x320") > -1)
                    {
                        newX = 478.25;
                        newY = 329;
                        newScale = 23.125;
                    }
                    else if (selectedComp.name.indexOf("640x480") > -1)
                    {
                        newX = 639.5;
                        newY = 461.0639;
                        newScale = 35.6794;
                    }

                    // update the newly added layer...
                    newLayer.position.setValue( [newX, newY]  );
                    newLayer.scale.setValue( [newScale, newScale] ); 
 
                    ableToUpdate = true;
                    compsChangedCounter++;
                    selectedComp.label = 9;                         

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

