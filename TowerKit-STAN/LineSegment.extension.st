Extension { #name : #LineSegment }

{ #category : #'*TowerKit-STAN' }
LineSegment >> asItermJTerm [
	(self start closeTo: 0.0 @ 0.0)
		ifTrue: [ ^ self reversed ].
	^ self
]

{ #category : #'*TowerKit-STAN' }
LineSegment class >> compareCrossSegment1: a segment2: b [
	^ (a standAngle closeTo: b standAngle)
			ifTrue: [ a asStandDirection start y > b asStandDirection start y ]
			ifFalse: [ a standAngle < b standAngle ] 			
]

{ #category : #'*TowerKit-STAN' }
LineSegment >> rankOfStan [
	"7  1  5"
	"4  0  3"
	"6  2  8"
	| signPoint |
	self isVertical
		ifTrue: [
			self start y > 0.0 ifTrue: [ ^ 1 ].
			self start y < 0.0 ifTrue: [ ^ 2 ] ].
	self isHorizontal
		ifTrue: [
			self start x > 0.0 ifTrue: [ ^ 3 ].
			self start x < 0.0 ifTrue: [ ^ 4 ] ].
	signPoint := self start sign.
	signPoint = (1 @ 1)
		ifTrue: [ ^ 5 ].
	signPoint = (-1 @ -1)
		ifTrue: [ ^ 6 ].
	signPoint = (-1 @ 1)
		ifTrue: [ ^ 7 ].
	signPoint = (1 @ -1)
		ifTrue: [ ^ 8 ].	
	^ 0
]

{ #category : #'*TowerKit-STAN' }
LineSegment >> rectangleAreaSymbol [
	(self isHorizontal and: [self controlPoints allSatisfy: [ :p | p y sign < 0.0 ]])
		ifTrue: [ ^ #bottom ].
	(self isVertical and: [self controlPoints allSatisfy: [ :p | p x sign < 0.0 ]])
		ifTrue: [ ^ #left ].
	(self isHorizontal and: [self controlPoints allSatisfy: [ :p | p y sign > 0.0 ]])
		ifTrue: [ ^ #top ].
	(self isVertical and: [self controlPoints allSatisfy: [ :p | p x sign > 0.0 ]])
		ifTrue: [ ^ #right ].
	('#other occured: ', self asString) traceCr.
	^ #other
	
]

{ #category : #'*TowerKit-STAN' }
LineSegment >> roundIndex: aPostBoolean [
	^ aPostBoolean ifTrue: [ self roundIndexOfPost  ] ifFalse: [ self roundIndexOfBeam ]
]

{ #category : #'*TowerKit-STAN' }
LineSegment >> roundIndexOfBeam [
	^ #(#right #bottom #left #top #other) indexOf: self rectangleAreaSymbol
]

{ #category : #'*TowerKit-STAN' }
LineSegment >> roundIndexOfPost [
	^ #(#bottom #left #top #right #other) indexOf: self rectangleAreaSymbol
]

{ #category : #'*TowerKit-STAN' }
LineSegment >> roundedForStan [
	^ LineSegment from: self start roundedForStan to: self end roundedForStan 
]
