"
A GdsPath is GDS II's PATH.

Instance Variables
	boundaryPoints:		<Array<Point>>
	outlineSegMap:		<Object>
	width:		<Float>

boundaryPoints
	- xxxxx

outlineSegMap
	- xxxxx

width
	- xxxxx

"
Class {
	#name : #GdsPath,
	#superclass : #GdsPrimitiveElement,
	#instVars : [
		'wire'
	],
	#category : #'GdsFeel-Model-Element'
}

{ #category : #testing }
GdsPath class >> hasPathType [
	^true.
]

{ #category : #testing }
GdsPath class >> hasWidth [
	^true.
]

{ #category : #testing }
GdsPath class >> isGdsOriginalClass [
	^ true
]

{ #category : #accessing }
GdsPath class >> requiredVertexCount [
	^2.
]

{ #category : #accessing }
GdsPath class >> type [
	^#path
]

{ #category : #'objects from disk' }
GdsPath >> attributesFrom: aDictionary [
	self width: (aDictionary at: 'width' ifAbsent: [ self missingWidthNumber ]) asNumber.
	self pathtype: (aDictionary at: 'pathtype' ifAbsent: [ self missingPathTypeNumber ]) asNumber.
	super attributesFrom: aDictionary
]

{ #category : #'objects from disk' }
GdsPath >> attributesOn: aDictionary [
	self width ~= self missingWidthNumber
		ifTrue: [ aDictionary at: 'width' put: self width ].
	self pathtype ~= self missingPathTypeNumber
		ifTrue: [ aDictionary at: 'pathtype' put: self pathtype ].
	super attributesOn: aDictionary
]

{ #category : #copying }
GdsPath >> copy [
	| newElement |
	newElement := super copy.
	newElement copyWireContext.
	(newElement instVarNamed: 'wire') element: newElement.
	^newElement
]

{ #category : #copying }
GdsPath >> copyWireContext [
	wire := wire copy.
]

{ #category : #accessing }
GdsPath >> dataOutlinePoints [
	^ wire boundaryPoints
]

{ #category : #private }
GdsPath >> firstSegment [
	^ LineSegment from: self vertices first to: self vertices second
]

{ #category : #initialization }
GdsPath >> fromItemContext: aGdsItemContext [ 
	self pathtype: aGdsItemContext pathtype.
	self width: aGdsItemContext width.
	super fromItemContext: aGdsItemContext
]

{ #category : #accessing }
GdsPath >> halfWidth [
	^self width / 2.0.
]

{ #category : #initialization }
GdsPath >> initialize [
	super initialize.
	wire := GdsWireContext new element: self.

]

{ #category : #testing }
GdsPath >> isSingle [
	^ self vertices size = 2
]

{ #category : #testing }
GdsPath >> isSingleHorizontal [
	^ self isSingle and: [ self vertices first y = self vertices second y ]
]

{ #category : #testing }
GdsPath >> isSingleVertical [
	^ self isSingle and: [ self vertices first x = self vertices second x ]
]

{ #category : #testing }
GdsPath >> isVisible [
	^ super isVisible
		and: [ (self structure kinds atKey: 'PB') isVisible
				or: [ (self structure kinds atKey: 'PC') isVisible ] ]
]

{ #category : #outline }
GdsPath >> outlineSegmentsOf: aLineSegment offsetRadians: radians r: r [
	^wire outlineSegmentsOf: aLineSegment offsetRadians: radians r: r
	
]

{ #category : #accessing }
GdsPath >> pathtype [
	^wire pathtype
]

{ #category : #accessing }
GdsPath >> pathtype: aInteger [
	wire pathtype: aInteger.
	self changed: #pathtype.
]

{ #category : #other }
GdsPath >> removeGeometryCache [
	wire removeGeometryCache.
]

{ #category : #accessing }
GdsPath >> validateVertices: aPointArray editorContext: aGdsEditorContext [
	| |
	^self validateVertices: aPointArray.

]

{ #category : #accessing }
GdsPath >> width [
	^wire width
]

{ #category : #accessing }
GdsPath >> width: aNumber [
	wire width: aNumber.
	self changed: #width.	
]
