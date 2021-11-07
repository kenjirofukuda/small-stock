Class {
	#name : #GdsHatch,
	#superclass : #Object,
	#instVars : [
		'hName',
		'angle',
		'linesPerScreen'
	],
	#category : #'GdsFeel-Developer-Model'
}

{ #category : #accessing }
GdsHatch >> angle [
	^angle
]

{ #category : #defaults }
GdsHatch >> defaultLinesPerScreen [
	^127.
	
]

{ #category : #testing }
GdsHatch >> isGdsReserved [
	^#('A' 'B' 'C' 'D') includes: self name .
]

{ #category : #accessing }
GdsHatch >> letter [
	^self name first 
]

{ #category : #'drawing-support' }
GdsHatch >> lineSegmentsOf: aBoundsRectangle [
	^self lineSegmentsOf: aBoundsRectangle  normalizedPoint: (Point r: 1 degrees: self angle). 
]

{ #category : #'drawing-support' }
GdsHatch >> lineSegmentsOf: aBoundsRectangle from: pt1 to: pt2 [
	^self lineSegmentsOf: aBoundsRectangle  normalizedPoint: (pt2 - pt1) normalized. 
]

{ #category : #'drawing-support' }
GdsHatch >> lineSegmentsOf: aBoundsRectangle normalizedPoint: aNormalizedPoint [
	| cp length atPoint1 atPoint2 step offsetPt screenSize sidesCount destSize |
	^ Array streamContents: [ :s |
		cp := aBoundsRectangle center.
		screenSize := aBoundsRectangle extent r.
		length := screenSize // 2.
		atPoint1 := (aNormalizedPoint * length) + cp.
		atPoint2 := (aNormalizedPoint negated * length) + cp.
		step := (screenSize // self linesPerScreen) + 1.
		offsetPt := (aNormalizedPoint normal  * step).
		sidesCount := self linesPerScreen // 2.
		(sidesCount negated to: sidesCount) do:[:index |
			destSize := (offsetPt * index).
			s nextPut: { (atPoint1 + destSize) . (atPoint2 + destSize)} ] ]

]

{ #category : #accessing }
GdsHatch >> linesPerScreen [
	linesPerScreen ifNil: [linesPerScreen := self defaultLinesPerScreen.].
	 ^linesPerScreen
]

{ #category : #accessing }
GdsHatch >> name [
	^hName
]

{ #category : #printing }
GdsHatch >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	aStream nextPutAll: self name.
	aStream nextPut: $,.
	aStream nextPutAll: self angle greaseString , ' DEG'.
	self linesPerScreen = self defaultLinesPerScreen ifFalse: [ 
		aStream nextPut: $,.
		aStream nextPutAll: self linesPerScreen greaseString ].
	aStream nextPut: $)
]

{ #category : #'initialize-release' }
GdsHatch >> setName: aString angle: aFloat [
	self setName: aString angle: aFloat linesPerScreen: self defaultLinesPerScreen.
	
	
]

{ #category : #'initialize-release' }
GdsHatch >> setName: aString angle: aFloat linesPerScreen: anInteger [
	hName := aString.
	angle := aFloat.
	linesPerScreen := anInteger.
	
]
