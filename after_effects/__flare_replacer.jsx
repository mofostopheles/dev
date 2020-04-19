/**
 * Replaces layers named "FLARE" with a layer considered the master flare.
 * This is used so we can update hundreds of optical flare layers.
 * The master is turned off after we do this.
 */

// Copyright © 2020, Arlo Emerson
// arloemerson@gmail.com

/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#include './__common.jsx'; // includes polyfills and common functions

app.beginUndoGroup('work_undo');

/**
 * Function with inner main function. Invoked at bottom of this file.
 * Loop the comp, add all "FLARE" layers to an array,
 * then loop that array and swap out everybody with a copy of "FLARE_MASTER".
 * Rename and set start time accordingly.
 */
var flareReplacer = function() {
    return {

        arrSelectedComps: getSelectedComps(),
        main: function(layerToFind) {
            var selectedComp;
            var taskCount = 0;

            for (var k = this.arrSelectedComps.length - 1; k >= 0; k--) {
                selectedComp = this.arrSelectedComps[k];

                // IMPORTANT: you must select the master layer to propogate.
                // In this case, "FLARE_MASTER"
                var masterLayer = selectedComp.selectedLayers[0];
                var layer;
                var arrayOfItems = [];

                // loop layers, find the target layer
                for (var j=1; j<=selectedComp.layers.length; j++) {
                    if (selectedComp.layers[j].name == layerToFind) {
                        layer = selectedComp.layers[j];
                        arrayOfItems.push( layer );
                    }
                }

                for (var j=0; j<=arrayOfItems.length-1; j++){
                    var tmpLayer = masterLayer.duplicate();
                    tmpLayer.moveAfter(arrayOfItems[j]);
                    tmpLayer.enabled = true;
                    tmpLayer.name = "FLARE";
                    var tmpStartTime = arrayOfItems[j].startTime;
                    arrayOfItems[j].locked = false;
                    arrayOfItems[j].remove();
                    tmpLayer.startTime = tmpStartTime;
                    tmpLayer.locked = true;
                }

                taskCount++;
            }
            aalert(taskCount + ' items/s were touched.');
        }
    };
};

/**
 * Anything to be passed to the script's main method is set here.
 */
var vars = {
    layerToFind: 'FLARE'
};

/**
 * Runs the script.
 * Calls main and passes args (if any).
 */
flareReplacer().main(vars.layerToFind);

app.endUndoGroup();
