// Arlo Emerson, 8/24/2018
// arloemerson@gmail.com

// A script for rendering out separately tagged layers in one/more selected comps.
// Just add "#somevalue" to any layer you want rendered.
// Renders will be appended with that tag name.
// e.g. all layers within a comp tagged "#base" will be rendered together into [comp name][tag name].[file extension]

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
            for (var i = allComps.length; i >= 1; i--) 
            {
                item = allComps[i];
                if ((item instanceof CompItem) && item.selected) 
                {
                    selectedComps++;
                }
            }

            if (selectedComps >= 1)
            {
               iterateCompsRenderTaggedLayers();                
            } 
            else 
            {
                alert("Please select at least one comp.");
            }
        }
    } 
}

function iterateCompsRenderTaggedLayers() 
{
    var allComps = app.project.items;

    collectionSelectedComps = new Array();

    for (var i = allComps.length; i >= 1; i--)
    {
        var individualComp = allComps[i];
        if ((individualComp instanceof CompItem) && individualComp.selected)
        {
            collectionSelectedComps[collectionSelectedComps.length] = individualComp;
        }
    }

    app.beginUndoGroup("dm_render");

    // loop selected comps
    for (var n = (collectionSelectedComps.length-1); n >= 0; n--) 
    {
        item = collectionSelectedComps[n];

        listOfTags = []
        layerSettings = []

        // loop all the layers and scrape a list of tags
        for (var i = 1; i <= item.numLayers; i++) 
        {
            if ( item.layers[i].name.indexOf("#") > -1  )
            {
                tag = item.layers[i].name.slice(  item.layers[i].name.indexOf("#"), item.layers[i].name.length );
                if ( listOfTags.indexOf(tag) == -1 )
                {
                    listOfTags.push( tag );
                }
            }

            // also store the enabled setting of each layer
            // we want to restore the comp to original settings at the end of the entire process
            layer = new Object();
            layer.ref = item.layers[i];
            layer.enabled = item.layers[i].enabled;
            layer.audioEnabled = item.layers[i].audioEnabled;
            layerSettings.push( layer ); 
        }

        if (listOfTags.length == 0)
        {
            alert("There are no tagged layers to render in comp '" + item.name  + "'. Please tag layers with #some_tag.");
        }

        // iterate the tags array and build up the render queue based on these layers
        for (t=0; t<listOfTags.length; t++) 
        {
            for (var i = 1; i <= item.numLayers; i++) 
            {
                // layer name needs to contain hashtag
                if ( item.layers[i].name.indexOf(listOfTags[t]) > -1  )
                {                   
                    //don't turn on visibility aka "enable" for matte channels
                    if (!item.layers[i].isTrackMatte)
                    {
                        item.layers[i].enabled = true;
                    }
                
                    if (item.layers[i].hasAudio == true)
                    {
                        item.layers[i].audioEnabled = true;                    
                    }
                
                }
                else    
                {
                    item.layers[i].enabled = false;
                    if (item.layers[i].audioEnabled == true)
                    {
                        item.layers[i].audioEnabled = false;                    
                    }
                }
            }

            // modify the render name to use the hashtag
            tmpItem = item.duplicate();
            tmpItem.name = tmpItem.name.replace(" 2", "");
            renderQueueItem = app.project.renderQueue.items.add(tmpItem);
            renderOutputModule = renderQueueItem.outputModule(1);
            modifiedFileName = renderOutputModule.file.toString().slice(0, -4); //trim off the file dot file extension
            tagName = listOfTags[t].substring(1) + renderOutputModule.file.toString().slice(-4);
            modifiedFileName += "_" + tagName;
            renderOutputModule.file = new File(modifiedFileName);
            tmpItem.name = tmpItem.name + " -- " + listOfTags[t].substring(1) + " -- remove after render";
        }  

        // reset the layers enabled property to original
        for (i=0; i<layerSettings.length; i++)
        {
            layerSettings[i].ref.enabled = layerSettings[i].enabled;
            if (layerSettings[i].audioEnabled == true)
            {
                layerSettings[i].ref.audioEnabled = layerSettings[i].audioEnabled; 
            }
        }  
    }
    app.endUndoGroup();
}
