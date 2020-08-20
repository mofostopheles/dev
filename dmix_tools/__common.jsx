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

/**
 * Returns a random number between two ranges.
 */
function randRange(min, max){ 
    var random = Math.random() * (+max - +min) + +min;
    return random;
}

/**
 * Returns an array of objects, one for each keyframe.
 */
function getKeyframesFromProperty(layer, layerProp, keysLength) {
    var targetKeyArray = [];
    for (var i = 1; i <= keysLength; i++) {
        targetKeyArray[i] = {
            keyValue: layer.property(layerProp).keyValue(i),
            keyTime: layer.property(layerProp).keyTime(i),
            keyInInterpolationType: layer.property(layerProp).keyInInterpolationType(i),
            keyOutInterpolationType: layer.property(layerProp).keyOutInterpolationType(i),
            keyInSpatialTangent: layer.property(layerProp).keyInSpatialTangent(i),
            keyOutSpatialTangent: layer.property(layerProp).keyOutSpatialTangent(i),
            keyInTemporalEase: layer.property(layerProp).keyInTemporalEase(i),
            keyOutTemporalEase: layer.property(layerProp).keyOutTemporalEase(i),
            keySpatialAutoBezier: layer.property(layerProp).keySpatialAutoBezier(i),
            keySpatialContinuous: layer.property(layerProp).keySpatialContinuous(i),
            keyTemporalAutoBezier: layer.property(layerProp).keyTemporalAutoBezier(i),
            keyTemporalContinuous: layer.property(layerProp).keyTemporalContinuous(i),
            keyRoving: layer.property(layerProp).keyRoving(i)
        };
    }
    return targetKeyArray;
}

/**
 * Sets keyframe values to a specific property.
 */
function applyKeyframesToProperty(layer, layerProp, keysArray) {
    for (var i = 1; i < keysArray.length; i++) {
        layer.property(layerProp).setValueAtTime(keysArray[i].keyTime, keysArray[i].keyValue);
    }
    for (i = 1; i < keysArray.length; i++) {
        keysArray[i].keyTemporalAutoBezier ? layer.property(layerProp).setTemporalAutoBezierAtKey(i, keysArray[i].keySpatialAutoBezier) : false;
        keysArray[i].keyInSpatialTangent ? layer.property(layerProp).setSpatialTangentsAtKey(i, keysArray[i].keyInSpatialTangent, keysArray[i].keyOutSpatialTangent) : false;
        keysArray[i].keyInTemporalEase ? layer.property(layerProp).setTemporalEaseAtKey(i, keysArray[i].keyInTemporalEase, keysArray[i].keyOutTemporalEase) : false;
        keysArray[i].keySpatialContinuous ? layer.property(layerProp).setSpatialContinuousAtKey(i, keysArray[i].keySpatialContinuous) : false;
        keysArray[i].keyRoving ? layer.property(layerProp).setRovingAtKey(i, keysArray[i].keyRoving) : false;
        layer.property(layerProp).setInterpolationTypeAtKey(i, keysArray[i].keyInInterpolationType, keysArray[i].keyOutInterpolationType);
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
