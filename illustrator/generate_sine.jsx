/**
 * Generates a sine wave with high-to-low frequency
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

var amplitude = 100;
var xOffset = 10;
var yOffset = -500;
var rangeLow = 0;
var handleOffset = 20;
var numberOfNodes = 50;
var rangeHigh = rangeLow + 100;
var numericRangeArray = constructNumericRange(rangeLow, rangeHigh, numberOfNodes);

// Create path1 object
var path1 = activeDocument.activeLayer.pathItems.add();

// Set some props on the path1
with(path1){
  closed = false;
  filled = false;
  stroked = true;
  strokeWidth = 1.0;
  strokeColor = new GrayColor();
  strokeColor.gray = 100;
}

function constructNumericRange(startValue, stopValue, cardinality) {
  var array = [];
  var step = (stopValue - startValue) / ((cardinality - 1));
  // use step if you want even distribution
  // for (var i = 1; i <= cardinality; i++) {
  //   array.push(startValue + (step * i)*1.62 );
  // }

  // use this for log like curve
  for (var i=1; i <= cardinality; i++) {
    array.push( (startValue + (step*i)) * i );
  }

  // return [0, 10, 15, 36, 100, 200, 300];
  return array;
}

for (var i=1; i <= numericRangeArray.length; i++){
  var anchorLocation = numericRangeArray[i] + xOffset;
  var yNeg=1;

  if (i % 2 == 0){
    yNeg = 1;
  } else {
    yNeg = -1;
  }

  with(path1.pathPoints.add()){
      anchor = [anchorLocation, yOffset + (amplitude * yNeg)];
      rightDirection = [anchorLocation + handleOffset * (i/7), yOffset + (amplitude * yNeg)];
      leftDirection = [anchorLocation - handleOffset*(i/7), yOffset + (amplitude * yNeg)];
  }
}
