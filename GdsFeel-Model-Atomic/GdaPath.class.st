Class {
	#name : #GdaPath,
	#superclass : #GdaPrimitiveElement,
	#instVars : [
		'wire'
	],
	#category : #'GdsFeel-Model-Atomic'
}

{ #category : #testing }
GdaPath class >> hasPathType [

	^ true
]

{ #category : #testing }
GdaPath class >> hasWidth [

	^ true
]

{ #category : #testing }
GdaPath class >> isGdsOriginalClass [

	^ true
]

{ #category : #validation }
GdaPath class >> requiredVertexCount [

	^ 2
]

{ #category : #accessing }
GdaPath class >> type [

	^ #path
]

{ #category : #copying }
GdaPath >> copy [

	| newElement |
	newElement := super copy.
	newElement copyWireContext.
	(newElement instVarNamed: 'wire') element: newElement.
	^ newElement
]

{ #category : #copying }
GdaPath >> copyWireContext [

	wire := wire copy
]

{ #category : #accessing }
GdaPath >> dataOutlinePoints [

	^ wire boundaryPoints
]

{ #category : #private }
GdaPath >> firstSegment [

	^ LineSegment from: self vertices first to: self vertices second
]

{ #category : #accessing }
GdaPath >> halfWidth [

	^ self width / 2.0
]

{ #category : #initialization }
GdaPath >> initialize [

	super initialize.
	wire := GdaWireContext new element: self
]

{ #category : #testing }
GdaPath >> isSingle [

	^ self vertices size = 2
]

{ #category : #testing }
GdaPath >> isSingleHorizontal [

	^ self isSingle and: [ 
		  self vertices first y = self vertices second y ]
]

{ #category : #testing }
GdaPath >> isSingleVertical [

	^ self isSingle and: [ 
		  self vertices first x = self vertices second x ]
]

{ #category : #outline }
GdaPath >> outlineSegmentsOf: aLineSegment offsetRadians: radians r: r [

	^ wire outlineSegmentsOf: aLineSegment offsetRadians: radians r: r
]

{ #category : #'accessing - basic' }
GdaPath >> pathtype [

	^ wire pathtype
]

{ #category : #'accessing - basic' }
GdaPath >> pathtype: aInteger [

	wire pathtype: aInteger
]

{ #category : #other }
GdaPath >> removeGeometryCache [

	wire removeGeometryCache
]

{ #category : #validation }
GdaPath >> validateVertices: aPointArray editorContext: aGdsEditorContext [

	^ self validateVertices: aPointArray
]

{ #category : #'accessing - basic' }
GdaPath >> width [

	^ wire width
]

{ #category : #'accessing - basic' }
GdaPath >> width: aNumber [

	wire width: aNumber
]
