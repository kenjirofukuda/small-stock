Class {
	#name : #GdoElement,
	#superclass : #Object,
	#instVars : [
		'layerNumber',
		'datatype',
		'vertices',
		'structureName',
		'strans',
		'angle',
		'columnCount',
		'rowCount',
		'pathtype',
		'width',
		'type',
		'xy',
		'ashape'
	],
	#category : #'GdsFeel-SF-Inform-Core'
}

{ #category : #accessing }
GdoElement class >> classForType: aString [ 
	^ self
]

{ #category : #testing }
GdoElement class >> installedElementType: aString [ 
	^ true
]

{ #category : #'accessing - sref' }
GdoElement >> angle [

	^ self strans angle
]

{ #category : #'accessing - sref' }
GdoElement >> angle: aDegees [
	self strans angle: aDegees.
]

{ #category : #'accessing - aref' }
GdoElement >> ashape [
	^ ashape ifNil: [ ashape := GdoAShapeContext new ]
	
]

{ #category : #'accessing - aref' }
GdoElement >> columnCount [
	^ self ashape columnCount
]

{ #category : #'accessing - aref' }
GdoElement >> columnCount: anInteger [ 
	self ashape columnCount: anInteger
]

{ #category : #accessing }
GdoElement >> datatype [

	^ datatype
]

{ #category : #accessing }
GdoElement >> datatype: anInteger [ 
	datatype := anInteger
]

{ #category : #initialization }
GdoElement >> initialize [ 
	super initialize.
]

{ #category : #'accessing - path' }
GdoElement >> layerNumber [

	^ layerNumber
]

{ #category : #'accessing - path' }
GdoElement >> layerNumber: anInteger [ 
	layerNumber := anInteger
]

{ #category : #'accessing - sref' }
GdoElement >> mag [

	^ strans mag
]

{ #category : #'accessing - sref' }
GdoElement >> mag: aFactor [
	strans mag: aFactor.
]

{ #category : #'accessing - aref' }
GdoElement >> offsets [
	^ self ashape offsets
]

{ #category : #'accessing - path' }
GdoElement >> pathtype [

	^ pathtype
]

{ #category : #'accessing - path' }
GdoElement >> pathtype: anInteger [ 
	pathtype := anInteger
]

{ #category : #'accessing - aref' }
GdoElement >> relativeTransforms [
	^ self ashape relativeTransforms
]

{ #category : #'accessing - aref' }
GdoElement >> rowCount [
	^ self ashape rowCount
]

{ #category : #'accessing - aref' }
GdoElement >> rowCount: anInteger [ 
	self ashape rowCount: anInteger
]

{ #category : #'accessing - sref' }
GdoElement >> strans [
	^ strans ifNil: [ strans := GdoStrans new ]
	
]

{ #category : #'accessing - sref' }
GdoElement >> strans: anObject [

	strans := anObject
]

{ #category : #'accessing - sref' }
GdoElement >> structureName [

	^ structureName
]

{ #category : #'accessing - sref' }
GdoElement >> structureName: aString [ 
	structureName := aString
]

{ #category : #'accessing - sref' }
GdoElement >> transform [
	^ strans asMatrix2x3

]

{ #category : #accessing }
GdoElement >> type [
	^ type
]

{ #category : #accessing }
GdoElement >> type: aSymbol [
	type := aSymbol
]

{ #category : #accessing }
GdoElement >> vertices [

	^ vertices
]

{ #category : #accessing }
GdoElement >> vertices: aCollection [ 
	vertices := aCollection.
]

{ #category : #'accessing - path' }
GdoElement >> width [

	^ width
]

{ #category : #'accessing - path' }
GdoElement >> width: aNumber [ 
	width := aNumber
]

{ #category : #'accessing - aref' }
GdoElement >> xStep [
	^ self ashape xStep
]

{ #category : #'accessing - aref' }
GdoElement >> xStep: aFloat [ 
	self ashape xStep: aFloat.
]

{ #category : #accessing }
GdoElement >> xy: aPoint [ 
	xy := aPoint
]

{ #category : #'accessing - aref' }
GdoElement >> yStep [
	^ self ashape yStep
]

{ #category : #'accessing - aref' }
GdoElement >> yStep: aFloat [ 
	self ashape yStep: aFloat.
]
