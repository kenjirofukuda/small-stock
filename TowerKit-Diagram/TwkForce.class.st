Class {
	#name : #TwkForce,
	#superclass : #TwkNode,
	#instVars : [
		'loadValue',
		'angleDegress'
	],
	#category : #'TowerKit-Diagram'
}

{ #category : #'instance creation' }
TwkForce class >> angleDegress: aNumber [
	^ self new angleDegress: aNumber
]

{ #category : #'as yet unclassified' }
TwkForce >> + aTwkForce [
	^ self add: aTwkForce
]

{ #category : #'as yet unclassified' }
TwkForce >> - aTwkForce [
	^ self sub: aTwkForce
]

{ #category : #'as yet unclassified' }
TwkForce >> add: aTwkForce [
	| sizedVec |
	sizedVec := (self loadValueVector + aTwkForce loadValueVector) fixNegativeZero.
	^ (TwkForce new 
		loadValue: sizedVec r;
		angleDegress: (sizedVec angleDegress);
		yourself) reversed
]

{ #category : #accessing }
TwkForce >> angleDegress [
	^ angleDegress
	
]

{ #category : #accessing }
TwkForce >> angleDegress: aNumber [
	angleDegress := aNumber degressNormalized
]

{ #category : #accessing }
TwkForce >> anglePoint [
	^ (Point r: 1.0 degrees: self angleDegress) roundTo: 1e-6
]

{ #category : #accessing }
TwkForce >> direction [
	^ self vector
]

{ #category : #'as yet unclassified' }
TwkForce >> directionMarker [
	"→←↑↓"
	self direction = (1 @ 0)
		ifTrue: [ ^ '→' ].
	self direction = (-1 @ 0)
		ifTrue: [ ^ '←' ].
	self direction = (0 @ 1)
		ifTrue: [ ^ '↑' ].
	self direction = (0 @ -1)
		ifTrue: [ ^ '↓' ].
	^ '●'
	
]

{ #category : #'as yet unclassified' }
TwkForce >> directionSymbol [
	"→←↑↓"
	self direction = (1 @ 0)
		ifTrue: [ ^ '→' ].
	self direction = (-1 @ 0)
		ifTrue: [ ^ '←' ].
	self direction = (0 @ 1)
		ifTrue: [ ^ '↑' ].
	self direction = (0 @ -1)
		ifTrue: [ ^ '↓' ].
	^ '●'
	
]

{ #category : #accessing }
TwkForce >> directionToBottom [
	self direction: (0 @ -1).
	
]

{ #category : #accessing }
TwkForce >> directionToLeft [
	self direction: (-1 @ 0).
	
]

{ #category : #accessing }
TwkForce >> directionToRight [
	self direction: (1 @ 0).
	
]

{ #category : #accessing }
TwkForce >> directionToTop [
	self direction: (0 @ 1).
	
]

{ #category : #accessing }
TwkForce >> hvSymbol [
	self isHorizontal ifTrue: [ ^ #horizontal ].
	^ #vertical
]

{ #category : #initialization }
TwkForce >> initialize [
	angleDegress := 0.0.
	loadValue := 1.0.
]

{ #category : #testing }
TwkForce >> isHorizontal [
	^ self direction x abs = 1
]

{ #category : #testing }
TwkForce >> isVertical [
	^ self direction y abs = 1
]

{ #category : #accessing }
TwkForce >> loadValue [
	^ loadValue
]

{ #category : #accessing }
TwkForce >> loadValue: aNumber [
	loadValue := aNumber
	
]

{ #category : #accessing }
TwkForce >> loadValueOfHorizontal [
	^ (self loadValue * self unitX) fixNegativeZero 
]

{ #category : #accessing }
TwkForce >> loadValueOfSide: aSymbol [
	aSymbol = #vertical
		ifTrue: [ ^ self loadValueOfVertical  ].
	aSymbol = #horizontal
		ifTrue: [ ^ self loadValueOfHorizontal  ].
	^ self error: 'only specify #horizontal, #vertical'		
]

{ #category : #accessing }
TwkForce >> loadValueOfVertical [
	^ (self loadValue * self unitY) fixNegativeZero 
]

{ #category : #accessing }
TwkForce >> loadValueVector [
	^ (self loadValue * self vector) fixNegativeZero 
]

{ #category : #printing }
TwkForce >> printOn: aStream [
	self angleDegress printOn: aStream.
	aStream nextPutAll: '°'.
	self loadValue printOn: aStream.
	aStream nextPutAll: 'N'.
	
	
]

{ #category : #'as yet unclassified' }
TwkForce >> reversed [
	^ (TwkForce new 
		angleDegress: self angleDegress + 180.0;
		loadValue: self loadValue;
		yourself) 
]

{ #category : #'as yet unclassified' }
TwkForce >> sub: aTwkForce [
	| sizedVec |
	sizedVec := (self loadValueVector - aTwkForce loadValueVector) fixNegativeZero.
	^ (TwkForce new 
		loadValue: sizedVec r;
		angleDegress: (sizedVec angleDegress);
		yourself) reversed
]

{ #category : #accessing }
TwkForce >> unitX [
	^ self vector x
]

{ #category : #accessing }
TwkForce >> unitY [
	^ self vector y
]

{ #category : #accessing }
TwkForce >> vector [
	^ self anglePoint negated fixNegativeZero
]

{ #category : #accessing }
TwkForce >> vectorHorizontal [
	^ self vector * (1 @ 0)
]

{ #category : #accessing }
TwkForce >> vectorSign [
	^ self vector sign
]

{ #category : #accessing }
TwkForce >> vectorVertical [
	^ self vector * (0 @ 1)
]
