﻿// Arlo Emerson, 10/2/2018
// arloemerson@gmail.com

// just a very dumb search and replace

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

    var layer1NameToFind = "background #global";

    var layer1NewName = "#intro-winter-ambient";
    var layer2NameToFind = "#outro-holiday-couple";
    var layer2NewName = "#outro-winter-ambient";
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
                selectedComp = allComps[i];
                if ((selectedComp instanceof CompItem) && selectedComp.selected) 
                {
                    selectedComps++;
                    collectionSelectedComps[collectionSelectedComps.length] = selectedComp;
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
                        if (selectedComp.layers[j].name.indexOf( layer1NameToFind ) != -1)
                        {
                            //selectedComp.layers[j].name = layer1NewName;
                            
                            selectedComp.layers[j].scale.setValue( [282, 55] );                                                                
                            //selectedComp.layers[j].property("Position").parentProperty("X Position").setValue(newX);
                            //selectedComp.layers[j].property("Position").parentProperty("Y Position").setValue(newY);

                            ableToUpdate = true;
                            compsChangedCounter++;
                            selectedComp.label = 9;

                        } 

                        /*
                        if (selectedComp.layers[j].name.indexOf( layer2NameToFind ) != -1)
                        {
                            selectedComp.layers[j].name = layer2NewName;
                            ableToUpdate = true;
                            compsChangedCounter++;
                            selectedComp.label = 9;                         
                        }
                        */              
                    }

                    if (!ableToUpdate) //all layers have been checked at this point
                    {
                        alert("I did not change anything in comp \n" + selectedComp.name);
                    } 
                }

                alert(compsChangedCounter + " changes were made ");
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

