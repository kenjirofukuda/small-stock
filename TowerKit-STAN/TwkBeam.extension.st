Extension { #name : #TwkBeam }

{ #category : #'*TowerKit-STAN' }
TwkBeam >> compareSegment1: a segment2: b [
	a spanIndex = b spanIndex ifFalse: [ ^ a spanIndex < b spanIndex ].
	a faceIndex = b faceIndex ifFalse: [ ^ a faceIndex < b faceIndex ].
	^ LineSegment compareCrossSegment1: a point2dSegment segment2: b point2dSegment		 
	
	
]

{ #category : #'*TowerKit-STAN' }
TwkBeam >> renumberNodesForSlope [
	| nodes fierstNumber postNodes newNum |
	nodes := super stanNodesForSlope.
	fierstNumber := nodes first number.
	"postNodes := self parent stanNodesForPostSlope."
	postNodes := self parent nodeCenter stanNodes.
	newNum := fierstNumber - 1.
	^ nodes
		collect: [ :node | 
			(postNodes
				detect: [ :postNode | postNode point3d = node point3d ]
				ifNone: [  ])
				ifNotNil: [ :foundNode | foundNode ]
				ifNil: [ newNum := newNum + 1.
					node
						number: newNum;
						yourself ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkBeam >> stanFrontSelector [
	^ #bottom
]

{ #category : #'*TowerKit-STAN' }
TwkBeam >> stanLocal3DPointsForSlope [
	| frontSelector sideSelector col1 col2   d3points |
	frontSelector := self stanFrontSelector.
	sideSelector := self stanSideSelector.
	col1 := (self faceAt: frontSelector) stanHalfPoints.
	col2 := (self faceAt: sideSelector) stanHalfPoints.
	d3points := TwkTowerKit stanLocal3DPointsForHorizontalFrontPoints: col1 sidePoints: col2.
	^ d3points
]

{ #category : #'*TowerKit-STAN' }
TwkBeam >> stanSideSelector [
	^ #front
]

{ #category : #'*TowerKit-STAN' }
TwkBeam class >> stanSlopeRoundSignMap [
	| signMap |
	signMap := Dictionary new.
	signMap at: (1 @ 1) put: 1.	"FRONT - TOP      or TOP    - BOTTOM"
	signMap at: (1 @ -1) put: 2.	"FRONT - BOTTOM   or BOTTOM - BOTTOM"
	signMap at: (-1 @ -1) put: 3."BACK  - BOTTOM   or TOP    - TOP"
	signMap at: (-1 @ 1) put: 4.	"BACK  - TOP      or TOP    - TOP"
	signMap at: (0 @ 0) put: 0.	"AXIS CENTER"
	^ signMap
]

{ #category : #'*TowerKit-STAN' }
TwkBeam >> stanXOffset [
	| total |
	total := 0.
	self parent beams
		do: [ :each | 
			each number <= self number
				ifTrue: [ each from
						ifNotNil: [ :leftPost | 
							total := total + leftPost jointHalfWidth.
							leftPost fromBeam
								ifNotNil:
									[ :prevBeam | total := total + prevBeam jointLength + leftPost jointHalfWidth ] ] ]
				ifFalse: [ ^ total ] ].
	^ total
]

{ #category : #'*TowerKit-STAN' }
TwkBeam >> stanZOffset [
	self from ifNotNil: [ :leftPost | ^ leftPost stanBeamMountOffset ].
	self to ifNotNil: [ :rightPost | ^ rightPost stanBeamMountOffset ].
	^ super stanZOffset
]
