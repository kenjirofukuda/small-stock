Extension { #name : #LineSegment }

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> asDownDirection [
	| points |
	points := self controlPoints sort: [ :a :b | a x < b x ].
	^ LineSegment from: points first to: points last
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> asStandDirection [
	| points |
	points := self controlPoints sort: [ :a :b | a y < b y ].
	^ LineSegment from: points first to: points last
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment class >> intersectSegment1: seg1 segment2: seg2 hasCrossBlock: aCrossPointBlock ifNone: aNoneBlock epsilon: epsilon [
	| crossPoint |
	crossPoint := seg1 intersectionWith: seg2.
	crossPoint
		ifNil: [ 
			| crossPoint2 |
			crossPoint2 := seg1 intersectionWith: seg2 virtualAllowed: true.
			crossPoint2
				ifNotNil: [ 
					(seg1 controlPoints , seg2 controlPoints anySatisfy: [ :p | (p dist: crossPoint2) < epsilon ])
						ifTrue: [ crossPoint := crossPoint2 ] ] ].
	crossPoint ifNotNil: [ aCrossPointBlock value: crossPoint ] ifNil: [ aNoneBlock value ]
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> intersectionWith: anotherSegment virtualAllowed: aBoolean [
	| det deltaPt alpha beta pt1Dir pt2Dir |
	pt1Dir := end - start.
	pt2Dir := anotherSegment end - anotherSegment start.
	det := (pt1Dir x * pt2Dir y) - (pt1Dir y * pt2Dir x).
	deltaPt := anotherSegment start - start.
	alpha := (deltaPt x * pt2Dir y) - (deltaPt y * pt2Dir x).
	beta := (deltaPt x * pt1Dir y) - (deltaPt y * pt1Dir x).
	det = 0 ifTrue:[^nil]. "no intersection"
	aBoolean 
		ifFalse: [
			alpha * det < 0 ifTrue:[^nil].
			beta * det < 0 ifTrue:[^nil].
			det > 0 
				ifTrue:[(alpha > det or:[beta > det]) ifTrue:[^nil]]
				ifFalse:[(alpha < det or:[beta < det]) ifTrue:[^nil]].].
	
	"And compute intersection"
	^start + (alpha * pt1Dir / (det@det))
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> isAxis [
	^ self isHorizontal or: [ self isVertical ]
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> isHorizontal [
	^ self direction y closeTo: 0.0.
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> isVertical [
	^ self direction x closeTo: 0.0.
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> midPoint [
	^ (self start + self end) / 2.0
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> midPointScaled: aFactor [
	| midPoint p1 p2 |
	self assert: (aFactor closeTo: 0.0) not.
	midPoint := self midPoint.
	p1 := self start - midPoint.
	p2 := self end - midPoint.
	^ LineSegment 
		from: (p1 * aFactor / 2) + midPoint
		to: (p2 * aFactor / 2) + midPoint
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> outlinePoints: offsetRadians r: r [
	| slant p1 p2 p3 p4  offP1 offP2 |
	slant := (self end -  self start) theta .
	offP1 := Point r: r radians: (slant - offsetRadians).
	offP2 := Point r: r radians: (slant + offsetRadians).
	p4 := self start - offP2.
	p1 := self end + offP1.
	p2 := self end + offP2.
	p3 := self start - offP1.		
	^{p1 . p2 .p3 . p4 . p1}.
	
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> outlineSegments: offsetRadians r: r [ 
	| col |
	col := OrderedCollection new.
	self outlineSegments: offsetRadians  r: r do: [ :seg |
		col add: seg]. 
	^col asArray
	
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> rightRotatedInModel [
	^ self class from: self start rightRotatedInModel to: self end rightRotatedInModel 
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> sameStandSegment: aLineSgement [
	| seg1 seg2 |
	seg1 := self asStandDirection.
	seg2 := aLineSgement asStandDirection.
	^ (seg1 start closeTo: seg2 start) and: [ seg1 end closeTo: seg2 end ]
	
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> slantSymbol [
	self isHorizontal ifTrue: [ ^ #horizontal ].
	self isVertical ifTrue: [ ^ #vertical ].
	^ #any	
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment class >> splitedSegments: aSegments epsilon: aEpsilon [
	|  crossPoints allSegs |
	crossPoints := OrderedCollection new.
	aSegments
		do: [ :seg1 | 
			aSegments
				do: [ :seg2 | 
					seg1 == seg2
						ifFalse: [ 
							LineSegment
								intersectSegment1: seg1
								segment2: seg2
								hasCrossBlock: [ :crossPoint | crossPoints add: (crossPoint roundTo: 1e-12) ]
								ifNone: [  ]
								epsilon: aEpsilon ] ] ].
	crossPoints := crossPoints asSet asArray.
	allSegs := OrderedCollection new.
	aSegments
		do: [ :seg | allSegs addAll: (GeometryUtils splitSegment: seg crossPoints: crossPoints epsilon: aEpsilon) ].
	allSegs := allSegs reject: [ :seg | seg length < aEpsilon  ].	
	^ allSegs asSet asArray
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> standAngle [
	| standSegment |
	standSegment := self asStandDirection.
	^ standSegment tangentAtStart degrees.
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> startPointTo: aPoint [
	(self start closeTo: aPoint)
		ifTrue: [ ^ self  ].
	(self end closeTo: aPoint)
		ifTrue: [ ^ self reversed  ].
	^ self
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> transposed [
	^ self class from: self start transposed to: self end transposed 
]

{ #category : #'*GdsFeel-Foundation-extension' }
LineSegment >> verticalCenterMirrored [
	| center p1 p2 |
	(self direction x closeTo: 0.0) ifTrue: [ ^ self ].
	center := self midPoint.
	p1 := self start - center.
	p2 := self end - center.
	^ LineSegment from: (p1 verticalMirrored + center) to: (p2 verticalMirrored + center)
]
