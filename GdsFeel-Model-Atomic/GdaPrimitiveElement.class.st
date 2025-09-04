Class {
	#name : #GdaPrimitiveElement,
	#superclass : #GdaElement,
	#instVars : [
		'datatype',
		'layerNumber'
	],
	#category : #'GdsFeel-Model-Atomic'
}

{ #category : #testing }
GdaPrimitiveElement class >> hasDataType [

	^ true
]

{ #category : #testing }
GdaPrimitiveElement class >> hasLayer [

	^ true
]

{ #category : #'accessing - basic' }
GdaPrimitiveElement >> datatype [

	^ datatype
]

{ #category : #'accessing - basic' }
GdaPrimitiveElement >> datatype: aInteger [

	self assert: [ aInteger isInteger ].
	datatype := aInteger
]

{ #category : #validation }
GdaPrimitiveElement >> fixGeometryError [

	| newPoints |
	self vertexCount < self requiredVertexCount ifTrue: [ ^ self ].
	newPoints := OrderedCollection new.
	GeometryUtils removeDuplicatePoints: self vertices on: newPoints.
	self privateWipe.
	self vertices: (self validateVertices: newPoints)
]

{ #category : #initialization }
GdaPrimitiveElement >> initialize [

	super initialize.
	layerNumber := 0.
	datatype := 0
]

{ #category : #testing }
GdaPrimitiveElement >> isVisible [

	^ self structure notNil and: [ 
		  (self structure layers atNumber: self layerNumber) isVisible ]
]

{ #category : #'accessing - basic' }
GdaPrimitiveElement >> layerNumber [

	^ layerNumber
]

{ #category : #'accessing - basic' }
GdaPrimitiveElement >> layerNumber: aInteger [

	self assert: [ aInteger isInteger ].
	layerNumber := aInteger
]

{ #category : #'accessing - basic' }
GdaPrimitiveElement >> pathtype [

	^ 0
]

{ #category : #'accessing - basic' }
GdaPrimitiveElement >> pathtype: aInteger [

	"ignore"

	
]

{ #category : #'accessing - basic' }
GdaPrimitiveElement >> xy: aPoint [

	
]
