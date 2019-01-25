/*
Queue_Comp_Sections.jsx
version 1.3 (.2 adds auto-numbering of duplicate names)
            (.3 changes the script considerably: Now, layers are no longer required to have "render"
            at the start of the layer name, and in fact the layer name, not the first marker comment, is used for the basename.
            This is more efficient since, to put a fine point on it,
            the automating of marker comments does not exist -- for example renaming, duplicating -- whereas layer name automation does exist)
            
By the guy who runs crgreen.com

This is like having multiple Work Area settings for a comp.
You must create Guide Layers to use as "faux work area markers".
Then you set the ins and outs of these layers to act as separate render starts and ends.
Then you select at least one of those layers and run the script, which will
read each selected layer's in point and out point and use those to add a new render queue item.
Also, if you DO NOT have an underscore ("_") at the beginning of the layer name of a "render layer", the layer name will
be used as the new queue item's output base name (e.g., "basename".mov, or "basename"_[#####].xxx if it is a file sequence).
If there IS an underscore at the beginning of the layer name, the comp name will be used for the queued item (the default behavior).
*/


//MODIFIED by arlo emerson 9/15/2017
//use the string "[frame]" in the comp name and that will be replaced with the guide layer name

var mainErr = "For this script to work, you need to have selected "
+ "Guide Layers whose layer names will be used for the basenames of the render files' names. "
+ "(To use the comp name, put an underscore at the beginning of the layer name.)"
// make sure a comp is selected
var activeItem = app.project.activeItem;
var nogoFlag = false;
if (activeItem == null || !(activeItem instanceof CompItem)){
    alert(mainErr);
} else {
    var s = activeItem.selectedLayers;
    var selNum = s.length;
    if (selNum == 0) {
        alert(mainErr);
    } else {
        /////FIRST, LOOP TO CHECK IF all are guide layers
        for (var x = 0; x <= (selNum-1); x++) {
            if ( s[x].guideLayer != true ) {
                nogoFlag = true;
                break;
            };
        }
        
        ///////////////////////
        //loop for each RL
        origWAS = activeItem.workAreaStart;
        origWAD = activeItem.workAreaDuration;
        
        if (nogoFlag) {
            alert(mainErr);
        } else {
            app.beginUndoGroup("Queue Comp Sections");
            var uniqueNamesArray = new Array();
            
            for (var n = 0; n <= (selNum-1); n++) {
                la = s[n];
                if (la.name.indexOf("_") != 0) {
                    // if there is not underscore at beginning
                    baseName = activeItem.name.replace("[frame]", la.name);
                } else {
                    // otherwise we just use default queue action
                    baseName = activeItem.name;
                }
                ;// get in and out, temporarily set workarea start and end, queue comp for these settings
                renderIn = la.inPoint;
                renderOut = la.outPoint;
                thisRQItem = app.project.renderQueue.items.add(activeItem);
                
                curOM = thisRQItem.outputModule(1);
                
                fileOut = curOM.file;
                fileOutStr = curOM.file.toString();
                fileOutStrLen = fileOutStr.length;
                
                fileOutNameStr = fileOut.name.toString();
                nameLen = fileOutNameStr.length;
                
                foEnd = fileOutNameStr.slice((nameLen - 4), nameLen);
                foHead  = fileOutStr.slice(0, (fileOutStrLen - nameLen));
                
                // use function to see if it's a file sequence
                itsASeq = testForSequence(fileOutNameStr);
                
                thisRQItem.timeSpanStart = renderIn;
                thisRQItem.timeSpanDuration = (renderOut - renderIn);
                
                pathMid = "";
                if (itsASeq) {pathMid = "_%5B#####%5D";}
                
                uName = buildUniqueName(uniqueNamesArray, baseName);
                if (uName != baseName) {
                    baseName = uName;
                    uniqueNamesArray[uniqueNamesArray.length] = baseName;
                } else {
                    uniqueNamesArray[uniqueNamesArray.length] = uName;
                }
                
                curOM.file = new File(foHead + baseName + pathMid + foEnd);
            }
            // reset work area to original settings
            activeItem.workAreaStart = origWAS;
            activeItem.workAreaDuration = origWAD;
            
            app.endUndoGroup();
        }
    }
}

function buildUniqueName(ar, newItem){
    // though not ideal because it is not smart enough to parse number-ended strings,
    // this is good enough -- so if the same basename is given more than once (by
    // marker comment or by defaulting to comp name), this will form number-endings fine.
    // basenames given with "_number" will have add'l "_number"s added to them.
    bestItem = newItem;
    endNum = 1;
    wasArray = (ar.join("\r") + "\r");
    while ( wasArray.indexOf( (bestItem + "\r") ) != -1 ) {
        bestItem = newItem;
        bestItem = (newItem + "_" + endNum.toString());
        endNum++;
    }
    //alert(bestItem); //replace "[frame]" with the guide layer name
    return bestItem;
}

function testForSequence(fileOutEndString){
    //  regular expressions:
    //  looks for various movie file extensions, beginning with '.'
    var movieREx = new RegExp (/[:.:]mov|MOV|avi|AVI|mpg|MPG|wmv|WMV$/);
    
    //  looks for [(#, ... )]-type afx numbering scheme in file name ( where (#, ... ) is any number of #s between [ and ] )
    //  (URL equivalents of [ and ] are used)
    var seqREx = new RegExp (/%5B#+%5D/);
    
    var returnedBoolean = movieREx.exec(fileOutEndString);
    if (returnedBoolean == null) {returnedBoolean = true;}
    
    var returnedBoolean = seqREx.exec(fileOutEndString);
    if (returnedBoolean == null) {returnedBoolean = false;}
    
    return returnedBoolean;
}

