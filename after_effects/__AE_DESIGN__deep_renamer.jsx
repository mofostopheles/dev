/**
 * An After Effects script to rename comps.
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
 */
var compRenamer = function() {
    return {
        arrSelectedComps: getSelectedComps(),
        main: function(searchAndReplaceBundle) {
            var taskCount = 0;

            for (var k = this.arrSelectedComps.length - 1; k >= 0; k--) {
                selectedComp = this.arrSelectedComps[k];

                if (selectedComp.name.indexOf(searchAndReplaceBundle.findString) > -1) {
                    selectedComp.name = selectedComp.name.replace(searchAndReplaceBundle.findString, searchAndReplaceBundle.replaceString);
                    taskCount++;
                }
            }

            alert(taskCount + ' selectedComp/s were renamed.');
        }
    };
};

/**
 * Anything to be passed to the script's main method is set here.
 */
var vars = {
    searchAndReplaceBundle: {
        findString: 'asdf',
        replaceString: 'productname'
    }
};

/**
 * Runs the script.
 * Calls main and passes args (if any).
 */
compRenamer().main(vars.searchAndReplaceBundle);

app.endUndoGroup();
