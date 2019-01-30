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

    var comp1 = "UI__google_lens_sunglasses-JP";
    //var comp2 = "_background-rockcandy";
    //var comp3 = "_background-sand";

    var layerNameToReplace = "UI__google_lens_sunglasses-JP"; // <---- this is the SOURCE name of the layer you want to find

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
                        
                        var ableToReplace = false;
                        //alert(selectedComp.layers.length);
                        //try to find the layer by looping the comp's layer collection
                        for (var j=1; j<=selectedComp.layers.length; j++)
                        {
                            if (selectedComp.layers[j].source != null) //layer must have a source
                            {
                                if (selectedComp.layers[j].source.name.indexOf( layerNameToReplace ) != -1 )
                                {
                                    alert("found a match");
                                    var tmpLayer = selectedComp.layers[j];
                                    //tmpLayer.inPoint = .1; // in seconds
                                    var frameRate = 12;
                                    var frameNumber = 2;
                                    tmpLayer.inPoint = frameRate/(1000/frameNumber);
                                    
                                     var origY = 2242.1945;
                                     //alert(tmpLayer.position);
                                     var origX =  tmpLayer.position.value[0];
                                     tmpLayer.position.setValueAtKey(1, [ origX, origY - 150 ] );
                                     
                                    
                                    
                                        //this will print a shitload of stuff
                                        /*
                                    for (foo in tmpLayer.position)
                                    {
                                            alert(foo);
                                    }
                                    */
                                
                                    //tmpLayer.property("Position").setValueAtKey( 1, (0, 100) );
                                    //tmpLayer.property("Scale").setValue( (50, 50) );

                                    //tmpLayer.property("Position").setValue( (0, 100) );
                                    //tmpLayer.property("Scale").setValue( (50, 50) );

                                  

                                    //selectedComp.layers[j] = 1;
                                    //selectedComp.layers[j].replaceSource(replacementComp,false);
                                    //selectedComp.layers[j].name = replacementComp.name;
                                    //ableToReplace = true;
                                } 
                                else
                                {
                                    //alert("could not find a layer with name " + layerNameToReplace );
                                    var foo = 1;
                                }    
                            }
                            else
                            {
                                alert("wha?");
                            }
                        }

                        if (ableToReplace == false)
                        {
                            alert("couldn't find a layer in this comp with name " + layerNameToReplace);
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

