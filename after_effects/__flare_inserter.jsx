/**
 * Add flares above each "connection" null. Flare is taken from FLARE_MASTER layer.
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
 * Add flares above each "connection" null. Flare is taken from FLARE_MASTER layer.
 */
var flareInserter = function() {
    return {

        arrSelectedComps: getSelectedComps(),
        main: function(layerToFind) {
            var selectedComp;
            var taskCount = 0;

            for (var k = this.arrSelectedComps.length - 1; k >= 0; k--) {
                selectedComp = this.arrSelectedComps[k];

                var tmpSelectedLayers = selectedComp.selectedLayers;
                var masterLayer = selectedComp.layers[4]; // hard-coding for now

                // loop in reverse, clone and place a FLARE_MASTER above each one.
                for (var j=tmpSelectedLayers.length-1; j>=0; j--) {
                    if (tmpSelectedLayers[j].name.indexOf('connection') != -1) {
                        var tmpLayer = masterLayer.duplicate();
                        tmpLayer.moveBefore(tmpSelectedLayers[j]);
                        tmpLayer.enabled = true;
                        tmpLayer.name = "FLARE";
                        var tmpInPoint = tmpSelectedLayers[j].inPoint;
                        tmpLayer.inPoint = tmpInPoint;
                        tmpLayer.locked = true;
                        taskCount++;
                    }
                }
            }
            aalert(taskCount + ' items/s were touched.');
        }
    };
};

/**
 * Anything to be passed to the script's main method is set here.
 */
var vars = {
    layerToFind: 'FLARE_MASTER'
};

/**
 * Runs the script.
 * Calls main and passes args (if any).
 */
flareInserter().main(vars.layerToFind);

app.endUndoGroup();
