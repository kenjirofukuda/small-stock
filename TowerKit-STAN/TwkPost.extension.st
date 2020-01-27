Extension { #name : #TwkPost }

{ #category : #'*TowerKit-STAN' }
TwkPost >> compareSegment1: a segment2: b [
	| as bs |
	(a insideCrossK and: [ b insideCrossK ])
		ifTrue: [ ^ self compareSegmentK1: a segmentK2: b ].
	a spanIndex = b spanIndex ifFalse: [ ^ a spanIndex > b spanIndex ].
	a faceIndex = b faceIndex ifFalse: [ ^ a faceIndex < b faceIndex ].
	as := a point2dSegment.
	bs := b point2dSegment.
	^ (as standAngle closeTo: bs standAngle)
		ifTrue: [ as asStandDirection start y > bs asStandDirection start y ]
		ifFalse: [ as standAngle < bs standAngle ].

]

{ #category : #'*TowerKit-STAN' }
TwkPost >> compareSegmentK1: a segmentK2: b [
	a indexStep1 = b indexStep1 ifFalse: [ ^ a indexStep1 < b indexStep1 ].
	a indexStep2 = b indexStep2 ifFalse: [ ^ a indexStep2 < b indexStep2 ].
	a faceIndex = b faceIndex ifFalse: [ ^ a faceIndex < b faceIndex ].
	^ a segmentIndexInK < b segmentIndexInK 
]

{ #category : #'*TowerKit-STAN' }
TwkPost >> realSectionSpans [
	^ super realSectionSpans reversed
]

{ #category : #'*TowerKit-STAN' }
TwkPost >> stanGrandSkipDepth [
	| skipDepth |
	skipDepth := 0.
	self grandSpanSize >= 1
		ifTrue: [
			skipDepth := (self  spanValues copyFrom: 1 to: self grandSpanSize) sum].
	^ skipDepth
]

{ #category : #'*TowerKit-STAN' }
TwkPost >> stanLocal3DPointsForSlope [
	| frontSelector sideSelector col1 col2   d3points |
	frontSelector := self stanFrontSelector.
	sideSelector := self stanSideSelector.
	col1 := (self faceAt: frontSelector) stanHalfPoints.
	col2 := (self faceAt: sideSelector) stanHalfPoints.
	d3points := TwkTowerKit stanLocal3DPointsForVerticalFrontPoints: col1 sidePoints: col2.
	^ d3points
]

{ #category : #'*TowerKit-STAN' }
TwkPost >> stanSkipDepthOffset2d [
	| skipDepth |
	skipDepth := self stanGrandSkipDepth.
	^ 0 @ (skipDepth negated)

]

{ #category : #'*TowerKit-STAN' }
TwkPost >> stanSkipDepthOffset3d [
	| skipDepth |
	skipDepth := self stanGrandSkipDepth.
	^ Array with: 0 with: 0 with: skipDepth negated.

]

{ #category : #'*TowerKit-STAN' }
TwkPost class >> stanSlopeRoundSignMap [
	| signMap |
	signMap := Dictionary new.
	signMap at: (1 @ 1) put: 4.	"Leg: D"
	signMap at: (1 @ -1) put: 1.	"Leg: A"
	signMap at: (-1 @ -1) put: 2."Leg: B"
	signMap at: (-1 @ 1) put: 3.	"Leg: C"
	signMap at: (0 @ 0) put: 0.	"Leg: ALL"
	^ signMap
]

{ #category : #'*TowerKit-STAN' }
TwkPost >> stanXOffset [
	| total |
	total := 0.
	self parent posts
		do: [ :each | 
			each number <= self number
				ifTrue: [ each fromBeam
						ifNotNil: [ :leftBeam | 
							total := total + each jointHalfWidth.
							total := total + leftBeam jointLength.
							leftBeam from
								ifNotNil: [ :prevPost | total := total + prevPost jointHalfWidth ] ] ]
				ifFalse: [ ^ total ] ].
	^ total
]
