Class {
	#name : #DxfLine,
	#superclass : #DxfShape,
	#category : #'KFDxf-Model'
}

{ #category : #conversion }
DxfLine >> asLineSegment [
	^ LineSegment from: (self startX @ self startY) to: (self endX @ self endY) 
]

{ #category : #accessing }
DxfLine >> endX [
	^ self numberByNumber: 11 default: 0.0
]

{ #category : #accessing }
DxfLine >> endX: aNumber [
	self setCode: 11 data: aNumber
]

{ #category : #accessing }
DxfLine >> endY [
	^ self numberByNumber: 21 default: 0.0
]

{ #category : #accessing }
DxfLine >> endY: aNumber [
	self setCode: 21 data: aNumber
]

{ #category : #accessing }
DxfLine >> endZ [
	^ self numberByNumber: 31 default: 0.0
]

{ #category : #accessing }
DxfLine >> endZ: aNumber [
	self setCode: 31 data: aNumber
]

{ #category : #testing }
DxfLine >> isHLine [
	^ self startY = self endY
]

{ #category : #testing }
DxfLine >> isVLine [
	^ self startX = self endX
]

{ #category : #accessing }
DxfLine >> points [
	^ Array streamContents: [ :s |
		s nextPut: (self startX @ self startY).
		s nextPut: (self endX @ self endY).
		 ]
]

{ #category : #'as yet unclassified' }
DxfLine >> printOn: aStream [
	super printOn: aStream. 
	aStream nextPut:$(. 
	self isVLine ifTrue: [ aStream << 'V' ].
	self isHLine ifTrue: [ aStream << 'H' ].	
	aStream nextPut: $).
]

{ #category : #accessing }
DxfLine >> startX [
	^ self firstX
]

{ #category : #accessing }
DxfLine >> startX: aNumber [
	self firstX: aNumber
]

{ #category : #accessing }
DxfLine >> startY [
	^ self firstY
]

{ #category : #accessing }
DxfLine >> startY: aNumber [
	self firstY: aNumber
]

{ #category : #accessing }
DxfLine >> startZ [
	^ self firstZ
]

{ #category : #accessing }
DxfLine >> startZ: aNumber [
	self firstZ: aNumber
]
