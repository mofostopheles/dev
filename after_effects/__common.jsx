/**
 * Include file for all scripts.
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

var VERBOSE = true; // Set to false to silence alerts.
var NEW_LINE = '\n';

/**
 * polyfill for Array.indexOf
 */
if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function(obj) {
        for (var i = 0; i < this.length; i++) {
            if (obj === this[i]) {
                return i;
            }
        }
        return -1;
    };
}

/**
 * Returns a comp or null.
 */
function getComp(compName) {
    for (var i = 1; i <= app.project.numItems; i++) {
        if ((app.project.item(i) instanceof CompItem) && (app.project.item(i).name === compName)) {
            return app.project.item(i);
        }
    }
    return null;
}

/**
 * Returns an array of selected comps.
 */
var getSelectedComps = function() {
    var arrSelectedComps = [];
    var item;
    for (var i = app.project.items.length; i >= 1; i--) {
        item = app.project.items[i];
        if ((item instanceof CompItem) && item.selected) {
            arrSelectedComps[arrSelectedComps.length] = item;
        }
    }
    if (arrSelectedComps.length < 1) {
        aalert('Please select at least one comp.');
    }
    return arrSelectedComps;
};

function getKeyframesFromProperty(layer, layerProp, keysLength) {
    var targetKeyArray = [];
    for (var ki = 1; ki <= keysLength; ki++) {
        targetKeyArray[ki] = {
            keyValue: layer.property(layerProp).keyValue(ki),
            keyTime: layer.property(layerProp).keyTime(ki),
            keyInInterpolationType: layer.property(layerProp).keyInInterpolationType(ki),
            keyOutInterpolationType: layer.property(layerProp).keyOutInterpolationType(ki),
            keyInSpatialTangent: layer.property(layerProp).keyInSpatialTangent(ki),
            keyOutSpatialTangent: layer.property(layerProp).keyOutSpatialTangent(ki),
            keyInTemporalEase: layer.property(layerProp).keyInTemporalEase(ki),
            keyOutTemporalEase: layer.property(layerProp).keyOutTemporalEase(ki),
            keySpatialAutoBezier: layer.property(layerProp).keySpatialAutoBezier(ki),
            keySpatialContinuous: layer.property(layerProp).keySpatialContinuous(ki),
            keyTemporalAutoBezier: layer.property(layerProp).keyTemporalAutoBezier(ki),
            keyTemporalContinuous: layer.property(layerProp).keyTemporalContinuous(ki),
            keyRoving: layer.property(layerProp).keyRoving(ki)
        };
    }
    return targetKeyArray;
}

function applyKeyframesToProperty(layer, layerProp, keysArray) {
    for (var ki = 1; ki < keysArray.length; ki++) {
        layer.property(layerProp).setValueAtTime(keysArray[ki].keyTime, keysArray[ki].keyValue);
    }
    for (ki = 1; ki < keysArray.length; ki++) {
        keysArray[ki].keyTemporalAutoBezier ? layer.property(layerProp).setTemporalAutoBezierAtKey(ki, keysArray[ki].keySpatialAutoBezier) : false;
        keysArray[ki].keyInSpatialTangent ? layer.property(layerProp).setSpatialTangentsAtKey(ki, keysArray[ki].keyInSpatialTangent, keysArray[ki].keyOutSpatialTangent) : false;
        keysArray[ki].keyInTemporalEase ? layer.property(layerProp).setTemporalEaseAtKey(ki, keysArray[ki].keyInTemporalEase, keysArray[ki].keyOutTemporalEase) : false;
        keysArray[ki].keySpatialContinuous ? layer.property(layerProp).setSpatialContinuousAtKey(ki, keysArray[ki].keySpatialContinuous) : false;
        keysArray[ki].keyRoving ? layer.property(layerProp).setRovingAtKey(ki, keysArray[ki].keyRoving) : false;
        layer.property(layerProp).setInterpolationTypeAtKey(ki, keysArray[ki].keyInInterpolationType, keysArray[ki].keyOutInterpolationType);
    }
}

/**
 * Wraps an alert with verbose flag.
 */
function aalert(message) {
    if (VERBOSE) {
        alert(message);
    }
}
