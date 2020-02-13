"
A GdsPrimitiveElement is GDS II's primitive element.

Instance Variables
	layer:		<SmallInteger>

layer
	- 0 to 255

"
Class {
	#name : #GdsPrimitiveElement,
	#superclass : #GdsElement,
	#instVars : [
		'layer',
		'datatype',
		'layerNumber'
	],
	#category : #'GdsFeel-Model-Element'
}

{ #category : #testing }
GdsPrimitiveElement class >> hasDataType [
	^true.
]

{ #category : #testing }
GdsPrimitiveElement class >> hasLayer [
	^true.
]

{ #category : #visiting }
GdsPrimitiveElement >> accept: aVisitor [
	^ aVisitor visitPrimitiveElement: self
]

{ #category : #'objects from disk' }
GdsPrimitiveElement >> attributesFrom: aDictionary [
	self datatype: (aDictionary at: 'datatype' ifAbsent: [ self missingDataTypeNumber ]) asNumber.
	self
		layerNumber:
			(aDictionary
				at: 'layerNumber'
				ifAbsent: [ aDictionary at: 'layer' ifAbsent: [ self missingLayerNumber ] ]) asInteger.
	super attributesFrom: aDictionary
]

{ #category : #'objects from disk' }
GdsPrimitiveElement >> attributesOn: aDictionary [
	self datatype ~= self missingDataTypeNumber
		ifTrue: [ aDictionary at: 'datatype' put: self datatype ].
	aDictionary at: 'layerNumber' put: self layerNumber.
	super attributesOn: aDictionary
]

{ #category : #accessing }
GdsPrimitiveElement >> datatype [
	^datatype
]

{ #category : #accessing }
GdsPrimitiveElement >> datatype: aInteger [
	self assert: [aInteger isInteger].
	datatype := aInteger.
	self changed: #datatype.
]

{ #category : #debugging }
GdsPrimitiveElement >> fixGeometryError [
	| newPoints|
	self vertexCount < self requiredVertexCount ifTrue: [^self].
	newPoints := OrderedCollection new.
	GeometryUtils removeDuplicatePoints:  self vertices on: newPoints.
	self privateWipe.
	self vertices: (self validateVertices: newPoints).
	
]

{ #category : #initialization }
GdsPrimitiveElement >> fromItemContext: aGdsItemContext [ 
	self datatype: aGdsItemContext datatype.
	self layerNumber: aGdsItemContext layerNumber.
	super fromItemContext: aGdsItemContext 
]

{ #category : #initialization }
GdsPrimitiveElement >> initialize [
	super initialize.
	layer := 1.
	
]

{ #category : #'as yet unclassified' }
GdsPrimitiveElement >> isVisible [
	^ self structure notNil and: [(self structure layers atNumber: self layerNumber) isVisible]
]

{ #category : #deprecated }
GdsPrimitiveElement >> layer [
	self deprecated: 'use #layerNumber'.
	^layer.
	
]

{ #category : #deprecated }
GdsPrimitiveElement >> layer: aInteger [
	self deprecated: 'use #layerNumber:'.
	self assert: [aInteger isInteger].
	layer := aInteger.
	self changed: #layer.
]

{ #category : #accessing }
GdsPrimitiveElement >> layerNumber [
	^layerNumber.
	
]

{ #category : #accessing }
GdsPrimitiveElement >> layerNumber: aInteger [
	self assert: [aInteger isInteger].
	layerNumber := aInteger.
	self changed: #layerNumber.
]

{ #category : #accessing }
GdsPrimitiveElement >> pathtype [
	^ 0
]

{ #category : #accessing }
GdsPrimitiveElement >> pathtype: aInteger [
	"ignore"
]

{ #category : #accessing }
GdsPrimitiveElement >> xy: aPoint [

	
]
