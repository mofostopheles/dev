// Arlo Emerson, 10/1/2018
// arloemerson@gmail.com

// rename any object throughout the entire object tree

var SEARCH_STRING = "PRODUCT_NAME";
var NEW_STRING = "productname";

// added functionality to Array object as Adobe does implement modern javascript
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
    app.beginUndoGroup("deep_renamer");
    
    if (app.project != null) 
    {        
        var allComps = app.project.items;                                          
        var taskCount = 0;

        for (var i = allComps.length; i >= 1; i--) 
        {
            item = allComps[i];
            if (item.selected) 
            {
                if ( item.name.indexOf(SEARCH_STRING) > -1 )
                {
                    item.name = item.name.replace(SEARCH_STRING,  NEW_STRING); 

/*
                    item.name = item.name.replace("sand",  "colorcode1"); 
                    item.name = item.name.replace("rockcandy",  "colorcode2"); 
                    item.name = item.name.replace("licorice",  "colorcode3"); 

                    item.name = item.name.replace("group-selfie",  "featurename1"); 
                    item.name = item.name.replace("top-shot",  "featurename2"); 
                    item.name = item.name.replace("lens",  "featurename3"); 
                    item.name = item.name.replace("battery",  "featurename4"); 
                    item.name = item.name.replace("low-light",  "featurename5"); 
                    item.name = item.name.replace("night-sight",  "featurename6"); 
*/
                    taskCount++;
                }
            }
            //need to loop children here and rename layers
        }

        alert(taskCount + " item/s were removed. You can undo if needed.");
    }
    app.endUndoGroup(); 
}