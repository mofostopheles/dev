// Arlo Emerson, 10/1/2018
// arloemerson@gmail.com

// duplicates a selected comp, saves two copies with -layer0 and -layer1 appended
// this script does not do anything with tags. 
// if you want tags, use the "__create_comps_from_tagged_layers_and_render.jsx" script

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
               iterateCompsRenderDuplicateLayers();                
            } 
            else 
            {
                alert("Please select at least one comp.");
            }
        }
    } 
}

function iterateCompsRenderDuplicateLayers() 
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

        // dupe the comp and name it "layer0"
        tmpItem = item.duplicate();
        tmpItem.name = tmpItem.name + "-" + "layer0";        
        cleanUpFileName(item, tmpItem);
        sendToRenderQueue(tmpItem);

        // create another dupe comp named "layer1"
        tmpItem = item.duplicate();
        tmpItem.name = tmpItem.name + "-" + "layer1";        
        cleanUpFileName(item, tmpItem);
        sendToRenderQueue(tmpItem);
                  
    }
    app.endUndoGroup();
}

function sendToRenderQueue(tmpItem)
{
    renderQueueItem = app.project.renderQueue.items.add(tmpItem);
    renderOutputModule = renderQueueItem.outputModule(1);
    modifiedFileName = renderOutputModule.file.toString().slice(0, -4); //trim off the file dot file extension
    renderOutputModule.file = new File(modifiedFileName);      
}

function cleanUpFileName(item, tempItem)
{
        // duplicate annoyingly modifies the file name, 
        // so we will check for each file size type and rename accordingly

        if (tmpItem.name.indexOf("320x481") != -1)
        {
            tmpItem.name = tmpItem.name.replace( "320x481", "320x480" );
        }
        else if (item.name.indexOf("300x250") != -1 ) //if original item was 300x250, AE renames as 300x601
        {
            if (tmpItem.name.indexOf("300x601") != -1)
            {
                tmpItem.name = tmpItem.name.replace( "300x601", "300x250" );
            }
        }
        else if (item.name.indexOf("160x600") != -1 )
        {
            if (tmpItem.name.indexOf("160x601") != -1)
            {
                tmpItem.name = tmpItem.name.replace( "160x601", "160x600" );
            }
        }            
        else if (item.name.indexOf("300x600") != -1 )
        {
            if (tmpItem.name.indexOf("300x601") != -1)
            {
                tmpItem.name = tmpItem.name.replace( "300x601", "300x600" );
            }
        }            
        else if (item.name.indexOf("480x320") != -1 )
        {
            if (tmpItem.name.indexOf("480x321") != -1)
            {
                tmpItem.name = tmpItem.name.replace( "480x321", "480x320" );
            }
        }            
        else if (item.name.indexOf("640x480") != -1 )
        {
            if (tmpItem.name.indexOf("640x481") != -1)
            {
                tmpItem.name = tmpItem.name.replace( "640x481", "640x480" );
            }
        }
        else if (item.name.indexOf("120x600") != -1 )
        {
            if (tmpItem.name.indexOf("120x601") != -1)
            {
                tmpItem.name = tmpItem.name.replace( "120x601", "120x600" );
            }
        }
        else if (item.name.indexOf("336x280") != -1 )
        {
            if (tmpItem.name.indexOf("336x281") != -1)
            {
                tmpItem.name = tmpItem.name.replace( "336x281", "336x280" );
            }
        }

        //general clean-up of file name if we have country codes on the end
        if (tmpItem.name.indexOf(" 2-") != -1 )
        {
            tmpItem.name = tmpItem.name.replace( " 2-", "-" );
        }        
}
