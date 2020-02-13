"
A GdsBoxText is not GDSII's real font.

Adhook Squeak's TrueType rendering.

Instance Variables

"
Class {
	#name : #GdsBoxText,
	#superclass : #GdsPrimitiveElement,
	#instVars : [
		'contents',
		'angle'
	],
	#category : #'GdsFeel-Model-Element'
}

{ #category : #accessing }
GdsBoxText class >> type [
	^#boxtext
]

{ #category : #visiting }
GdsBoxText >> accept: aVisitor [
	^ aVisitor visitBoxText: self
]

{ #category : #accessing }
GdsBoxText >> angle [
	^ angle
]

{ #category : #accessing }
GdsBoxText >> angle: aNumber [
	angle := aNumber
]

{ #category : #accessing }
GdsBoxText >> angleDegress [
	^ self angle
]

{ #category : #accessing }
GdsBoxText >> angleRadian [
	^ self angleDegress degreesToRadians 
]

{ #category : #'objects from disk' }
GdsBoxText >> attributesFrom: aDictionary [
	super attributesFrom: aDictionary.
	self contents: (aDictionary at: 'string' ifAbsent: ['UNTITLED']) asString.
	self angle: (aDictionary at: 'angle' ifAbsent: ['0.0']) asNumber	
]

{ #category : #'objects from disk' }
GdsBoxText >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'string' put: self contents asString.
	aDictionary at: 'angle' put: self angle asString.	
]

{ #category : #accessing }
GdsBoxText >> contents [
	^contents
]

{ #category : #accessing }
GdsBoxText >> contents: aByteString [
	contents := aByteString.
	
]

{ #category : #accessing }
GdsBoxText >> dataOutlinePoints [
	"self dataBounds"
	^GeometryUtils verticesFromBounds: (Rectangle encompassing: self vertices).

]

{ #category : #other }
GdsBoxText >> fixGeometryError [
]

{ #category : #accessing }
GdsBoxText >> fromItemContext: aGdsItemContext [ 
	super fromItemContext: aGdsItemContext.
	self contents: aGdsItemContext text.
	self angle: aGdsItemContext angle.
	
]

{ #category : #initialization }
GdsBoxText >> initialize [
	super initialize.
	self contents: 'UNTITLED'.
	
]

{ #category : #testing }
GdsBoxText >> isStrictGds [
	^false
]

{ #category : #testing }
GdsBoxText >> isVisible [
	^super isVisible and: [(self structure kinds atKey: 'TX') isVisible or:  [(self structure kinds atKey: 'TO') isVisible]].
]

{ #category : #printing }
GdsBoxText >> printSelfOn: aStream [
	aStream nextPut: $,.
	aStream nextPutAll: self contents.
]

{ #category : #accessing }
GdsBoxText >> safeContents [
	^self contents select: [ :c | c asciiValue > 255 or: [ c shouldBePrintedAsLiteral  ] ].
]

{ #category : #accessing }
GdsBoxText >> textHeight [
	^ ((self vertices at: 2) y - (self vertices at: 1) y) abs
	
]
