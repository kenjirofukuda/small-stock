Class {
	#name : #GdaBoxText,
	#superclass : #GdaPrimitiveElement,
	#instVars : [
		'contents',
		'angle'
	],
	#category : #'GdsFeel-Model-Atomic'
}

{ #category : #accessing }
GdaBoxText class >> type [

	^ #boxtext
]

{ #category : #visiting }
GdaBoxText >> accept: aVisitor [

	^ aVisitor visitBoxText: self
]

{ #category : #'accessing - basic' }
GdaBoxText >> angle [

	^ angle
]

{ #category : #'accessing - basic' }
GdaBoxText >> angle: aNumber [

	angle := aNumber
]

{ #category : #accessing }
GdaBoxText >> angleDegress [

	^ self angle
]

{ #category : #accessing }
GdaBoxText >> angleRadian [

	^ self angleDegress degreesToRadians
]

{ #category : #'accessing - basic' }
GdaBoxText >> contents [

	^ contents
]

{ #category : #'accessing - basic' }
GdaBoxText >> contents: aByteString [

	contents := aByteString
]

{ #category : #'accessing - points' }
GdaBoxText >> dataOutlinePoints [

	"self dataBounds"

	^ GeometryUtils verticesFromBounds:
		  (Rectangle encompassing: self vertices)
]

{ #category : #other }
GdaBoxText >> fixGeometryError [

	
]

{ #category : #initialization }
GdaBoxText >> initialize [

	super initialize.
	self contents: 'UNTITLED'
]

{ #category : #testing }
GdaBoxText >> isStrictGds [

	^ false
]

{ #category : #testing }
GdaBoxText >> isVisible [

	^ super isVisible and: [ 
		  (self structure kinds atKey: 'TX') isVisible or: [ 
			  (self structure kinds atKey: 'TO') isVisible ] ]
]

{ #category : #printing }
GdaBoxText >> printSelfOn: aStream [

	aStream nextPut: $,.
	aStream nextPutAll: self contents
]

{ #category : #accessing }
GdaBoxText >> safeContents [

	^ self contents select: [ :c | 
		  c asciiValue > 255 or: [ c shouldBePrintedAsLiteral ] ]
]

{ #category : #accessing }
GdaBoxText >> textHeight [

	^ ((self vertices at: 2) y - (self vertices at: 1) y) abs
]
