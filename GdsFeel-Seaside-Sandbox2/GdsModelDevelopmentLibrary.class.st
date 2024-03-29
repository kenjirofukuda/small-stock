Class {
	#name : #GdsModelDevelopmentLibrary,
	#superclass : #WAFileLibrary,
	#category : #'GdsFeel-Seaside-Sandbox2'
}

{ #category : #'as yet unclassified' }
GdsModelDevelopmentLibrary >> gdsJs [
	^ '"use strict";

/* global GEO, GDS */

var GDS = {};

GDS.Element = function (jsonMap) {
  this.hash = jsonMap;
};


GDS.Element.prototype.toString = function () {
  return "Element";
};


GDS.Element.prototype.dataExtent = function () {
  for (var coord in this.hash.vertices) {
    var minX = Math.min(coord[0], minX || Number.MAX_VALUE);
    var maxX = Math.max(coord[0], maxX || Number.MIN_VALUE);
    var minY = Math.min(coord[1], minY || Number.MAX_VALUE);
    var maxY = Math.max(coord[1], maxY || Number.MIN_VALUE);
  }
  return GEO.MakeRect(minX, minY,
          Math.abs(maxX - minX), Math.abs(maxY - minY));

};



GDS.Element.fromObject = function (hash) {
  if (hash.type === "point") {
    return new GDS.Point(hash);
  }
  if (hash.type === "path") {
    return new GDS.Segment(hash);
  }
  if (hash.type === "boxtext") {
    return new GDS.BoxText(hash);
  }
  if (hash.type === "boundary") {
    return new GDS.Boundary(hash);
  }
  return null;
};



GDS.Point = function (hash) {
   GDS.Element.call(this, hash);
};

GDS.Point.prototype = Object.create(GDS.Element.prototype);
GDS.Point.prototype.constructor = GDS.Segment;



GDS.Point.prototype.toString = function () {
  return "Point(" + this.hash.vertices[0] + ")";
};


GDS.Point.prototype.dataExtent = function () {
  return GEO.MakeRect(this.hash.vertices[0][0], this.hash.vertices[0][1]);
};




GDS.Segment = function (hash) {
  GDS.Element.call(this, hash);
};

GDS.Segment.prototype = Object.create(GDS.Element.prototype);
GDS.Segment.prototype.constructor = GDS.Segment;


GDS.Segment.prototype.toString = function () {
  return "Segment(" + this.start + " - " + this.end + ")";
};


GDS.Segment.prototype.dataExtent = function () {
  for (var coord in this.hash.vertices) {
    var minX = Math.min(coord[0], minX || Number.MAX_VALUE);
    var maxX = Math.max(coord[0], maxX || Number.MIN_VALUE);
    var minY = Math.min(coord[1], minY || Number.MAX_VALUE);
    var maxY = Math.max(coord[1], maxY || Number.MIN_VALUE);
  }
  return GEO.MakeRect(minX, minY,
          Math.abs(maxX - minX), Math.abs(maxY - minY));

};


GDS.Boundary = function (hash) {
  GDS.Element.call(this, hash); 
};


GDS.Boundary.prototype = Object.create(GDS.Element.prototype);
GDS.Boundary.prototype.constructor = GDS.Boundary;


GDS.Boundary.prototype.dataExtent = function () {
  for (var coord in this.hash.vertices) {
    var minX = Math.min(coord[0], minX || Number.MAX_VALUE);
    var maxX = Math.max(coord[0], maxX || Number.MIN_VALUE);
    var minY = Math.min(coord[1], minY || Number.MAX_VALUE);
    var maxY = Math.max(coord[1], maxY || Number.MIN_VALUE);
  }
  return GEO.MakeRect(minX, minY,
          Math.abs(maxX - minX), Math.abs(maxY - minY));

};



GDS.BoxText = function (hash) {
  GDS.Element.call(this, hash); 
};


GDS.BoxText.prototype = Object.create(GDS.Element.prototype);
GDS.BoxText.prototype.constructor = GDS.BoxText;



/* global GEO, GDS */


GDS.Structure = function () {
  this._elements = [];
};

GDS.Structure.prototype = {
  constructor: GDS.Structure
};

GDS.Structure.prototype.addElement = function (e) {
  this._elements.push(e);
};

GDS.Structure.prototype.elements = function () {
  return this._elements;
};

GDS.Structure.prototype.dataExtent = function () {
  if (this.elements().length === 0) {
    return GEO.MakeRect(0, 0, 0, 0);
  }
  var points = [];
  this.elements().forEach(function (e) {
    var r = e.dataExtent();
    r.pointArray().forEach(function (p) {
      points.push(p);
    });
  });
  var ext = GEO.calcExtentBounds(points);
  return ext;
};
'
]

{ #category : #'as yet unclassified' }
GdsModelDevelopmentLibrary >> selectorsToInclude [
	^ #(#gdsJs)
]
