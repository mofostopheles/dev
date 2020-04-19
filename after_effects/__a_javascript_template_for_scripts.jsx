/**
 * An After Effects script template. Put description here.
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
 * Description here.
 */
var nameOfFunction = function() {
    return {

        arrSelectedComps: getSelectedComps(),
        main: function(argument) {
            var selectedComp;
            var taskCount = 0;

            for (var k = this.arrSelectedComps.length - 1; k >= 0; k--) {
                selectedComp = this.arrSelectedComps[k];
                var layer;
                // loop layers, find the target layer
                for (var j = 1; j <= selectedComp.layers.length; j++) {
                    if (selectedComp.layers[j].name.indexOf(argument) !== -1) {
                        layer = selectedComp.layers[j];

                        // Code here

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
    key: 'value'
};

/**
 * Runs the script.
 * Calls main and passes args (if any).
 */
nameOfFunction().main(vars.key);

app.endUndoGroup();
