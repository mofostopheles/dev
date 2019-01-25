﻿/**********************************************************ARLO EMERSON DESIGN LLC __author__ = "Arlo Emerson <arloemerson@gmail.com>"__version__ = "1.0"__date__ = "10/15/2018"__swap_photo_with_photo.jsxDESCRIPTION Looks for comps in library with "__photo__" in name, these are provided as a list of choices to swap with a layer in a selected comp.Used on PRODUCT_NAME production to quickly swap out group selfie photos.**********************************************************/// Added functionality to Array object as Adobe does implement modern javascriptif(!Array.prototype.indexOf) {    Array.prototype.indexOf = function(obj)     {        for(var i=0; i<this.length; i++)         {            if(obj===this[i])            {                return i;            }        }        return -1;    };}var LABEL_HELP = "1. Enter the layer source name.\n2. Enter the name of a comp to swap with layer.\n3. Select one or more comps.\n4. Click Swap.\n\nYou can undo if you need to.";var LABEL_LAYER_SOURCE_NAME = "The layer source name you want to replace:";var LABEL_COMP_REPLACEMENT_NAME = "The comp name that will replace the above layer:";var LABEL_SWAP_BUTTON = "Swap layer with comp";var MARGIN_LEFT = 50;var SEARCH_STRING = "__photo__";var win = new Window('palette', 'ESSENCE PRODUCTION TOOLS - Swap Photo with Photo', [300,100,800,800]);var w = buildUI();start();function start(){    if (app.project != null)     {        if (app.project.items.length < 1)        {            alert("Please select at least one comp.");        }         else         {                        w.show();                        }    }    }function buildUI(){    if (win != null)    {        win.spacing = 0;        win.margins = 10;                var res =         "group { \            orientation:'column', alignment:['fill','fill'], alignChildren:['left','top'], spacing:5, margins:[0,0,0,0], \            layerRow: Group { \                alignment:['fill','top'], \                lblLayerToSwap: StaticText { text:'" + LABEL_LAYER_SOURCE_NAME + "', alignment:['left','center'] }, \                txtLayerToSwap: DropDownList { text:'', characters:30, alignment:['fill','center'], preferredSize:[100,20] }, \                refreshLayersButton: Button { text:'Refresh', alignment:['right','center'], preferredSize:[100,20] }, \            }, \            compRow: Group { \                alignment:['fill','top'], \                lblCompToSwap: StaticText { text:'" + LABEL_COMP_REPLACEMENT_NAME + "', alignment:['left','center'] }, \                txtCompToSwap: DropDownList { text:'', characters:30, alignment:['fill','center'] }, \            }, \            cmds: Group { \                alignment:['fill','top'], \                cancelButton: Button { text:'Cancel', alignment:['fill','center'] }, \                swapButton: Button { text:'" + LABEL_SWAP_BUTTON + "', alignment:['fill','center'] }, \                helpButton: Button { text:'?', alignment:['right','center'], preferredSize:[25,20] }, \            }, \        }";                //txtCompToSwap: EditText { text:'', characters:20, alignment:['fill','center'] }, \        win.grp = win.add(res);        win.grp.cmds.cancelButton.onClick = function() {win.close(0)};        win.grp.cmds.helpButton.onClick = function() { alert(LABEL_HELP) };        win.grp.cmds.swapButton.onClick = function() { swapItems() };        win.grp.layerRow.refreshLayersButton.onClick = function() { populateLayerList(win.grp.layerRow.txtLayerToSwap) };        win.layout.layout(true);        populateLayerList(win.grp.layerRow.txtLayerToSwap);        populateCompList(win.grp.compRow.txtCompToSwap);    }    return win;}//grab all comps that match a specific naming convention i.e. "UI_"function populateCompList(pList){    if (app.project != null)     {                var allComps = app.project.items;                                                  var selectedComps = 0;        collectionSelectedComps = new Array();        for (var i = allComps.length; i >= 1; i--)         {            item = allComps[i];                        if ( (item instanceof CompItem) && (item.name.toLowerCase().indexOf(SEARCH_STRING) > -1)  )            {                pList.add('item', item.name);               }        }      }}//loop the layers of the first selected comp and use that as our list of layers to choose fromfunction populateLayerList(pList){    if (app.project != null)     {                var allComps = app.project.items;                                                  var selectedComps = 0;        collectionSelectedComps = new Array();        for (var i = allComps.length; i >= 1; i--)         {            item = allComps[i];            if ((item instanceof CompItem) && item.selected)             {                selectedComps++;                collectionSelectedComps[collectionSelectedComps.length] = item;            }        }        if (selectedComps >= 1)        {            var firstComp = collectionSelectedComps[0]; // we're only using one comp, hope it has the layers you want to use                                for (var j=1; j<=firstComp.layers.length; j++)            {                if (firstComp.layers[j].source != null) //layer must have a source                {                    pList.add('item', firstComp.layers[j].source.name);                                        }            }        }            }}function swapItems(){    app.beginUndoGroup("swapitems");    //var strReplacementComp = win.grp.compRow.txtCompToSwap.text;    //var layerNameToReplace = win.grp.layerRow.txtLayerToSwap.text;    var strReplacementComp = win.grp.compRow.txtCompToSwap.selection.text;    var layerNameToReplace = win.grp.layerRow.txtLayerToSwap.selection.text;    statusReport = "";    counter = 0;    if (app.project != null)     {        if (app.project.items.length < 1)         {            alert("Please select at least one comp.");        }         else         {            var allComps = app.project.items;                                                      var selectedComps = 0;            collectionSelectedComps = new Array();            for (var i = allComps.length; i >= 1; i--)             {                item = allComps[i];                if ((item instanceof CompItem) && item.selected)                 {                    selectedComps++;                    collectionSelectedComps[collectionSelectedComps.length] = item;                }            }            if (selectedComps >= 1)            {                for (var k=0; k<collectionSelectedComps.length; k++)                {                                        var replacementComp = getComp(strReplacementComp);                    var strError = "";                    if (layerNameToReplace == "")                    {                        strError = "Please enter a valid layer name.";                    }                    if (strReplacementComp == "")                    {                       strError = "Please enter a comp name.";                    }                    else if (replacementComp == null)                    {                        strError = "Can't find comp " + strReplacementComp;                    }                                        if (strError != "")                    {                        alert(strError);                        return;                    }                    var selectedComp = collectionSelectedComps[k];                                            var ableToReplace = false;                    //try to find the layer by looping the comp's layer collection                    for (var j=1; j<=selectedComp.layers.length; j++)                    {                        if (selectedComp.layers[j].source != null) //layer must have a source                        {                            if (selectedComp.layers[j].source.name.indexOf( layerNameToReplace ) != -1 )                            {                                selectedComp.layers[j].replaceSource(replacementComp,false);                                selectedComp.layers[j].name = replacementComp.name;                                ableToReplace = true;                                counter++;                                selectedComp.label = 9;                            }                              }                    }                    if (ableToReplace == false)                    {                        alert("couldn't find a layer in " + selectedComp.name + " with name '" + layerNameToReplace + "'");                        selectedComp.label = 1;                    }                    else                    {                        statusReport += "\n\n" + selectedComp.name + " - replaced '" + layerNameToReplace + "'' with '" + strReplacementComp + "'";                     }                                    }            }             else             {                alert("Please select at least one comp.");            }        }            }     alert("made " + counter + " replacements. \n" + statusReport);    app.endUndoGroup();}function getComp(pName){    for (var i = 1; i <= app.project.numItems; i++)    {        if ((app.project.item(i) instanceof CompItem) && (app.project.item(i).name == pName))        {            return app.project.item(i);        }    }    return null;}