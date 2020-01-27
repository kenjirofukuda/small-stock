Extension { #name : #TwkStackItem }

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> compareCrossSegment1: a segment2: b [
	| aSeg bSeg |
	(a insideDiamondCross and: [ b insideDiamondCross ])
		ifTrue: [ ^ self compareDiamondSegment1: a segmentK2: b ].

	aSeg := self point2dSegment: a.
	bSeg := self point2dSegment: b.
	self ownerBrick isBeam
		ifTrue: [
			(aSeg isHorizontal and: [bSeg isHorizontal])
				ifTrue: [ 
					^ aSeg asDownDirection start x < bSeg asStandDirection start x ] ].

	^ LineSegment 
		compareCrossSegment1: aSeg 
		segment2: bSeg 

]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> compareDiamondSegment1: a segmentK2: b [
	| signIndexFunc |
	signIndexFunc := [ :seg | 
		| midSign |
		midSign := ((seg valueOfProperty: #span) point2dSegment: seg) midPoint sign.
		{ (1 @ -1) . (-1 @ -1) . (-1 @ 1) . (1 @ 1) } indexOf: midSign ].
	^ (signIndexFunc value: a) < (signIndexFunc value: b)
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> compareRoundSegment1: a segment2: b [
	| as bs aIndex bIndex isPost |
	isPost := self ownerBrick isPost.
	as := self point2dSegment: a.
	bs := self point2dSegment: b.
	aIndex := as roundIndex: isPost.
	bIndex := bs roundIndex: isPost.
	aIndex = bIndex
		ifTrue: [ 
			| symbol |
			symbol := as rectangleAreaSymbol.
			symbol = #left
				ifTrue: [ ^ as asStandDirection start y < bs asStandDirection start y ].
			symbol = #right
				ifTrue: [ ^ as asStandDirection start y > bs asStandDirection start y ].
			symbol = #bottom
				ifTrue: [ ^ as asDownDirection start x > bs asDownDirection start x ].
			symbol = #top
				ifTrue: [ ^ as asDownDirection start x < bs asDownDirection start x ].
			symbol = #other
				ifTrue: [ ^ aIndex < bIndex ] ].
	^ aIndex < bIndex 
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> createStanSegments: aGetSegmentsSelector nodes: aStanNodes type: aTypeString subType: aTypeString2 [
	^ Array
		streamContents: [ :s | 
			(self planeSideCross perform: aGetSegmentsSelector)
				do: [ :seg | 
					| startNode endNode |
					startNode := self findNodeOn: aStanNodes sectionPoint: seg start.
					endNode := self findNodeOn: aStanNodes sectionPoint: seg end.
					(startNode notNil and: [ endNode notNil ])
						ifTrue: [ | newSeg |
							newSeg := self ownerBrick nodeCenter segmentFrom: startNode to: endNode.
							newSeg onceParent: self ownerBrick.
							aTypeString2 ifNotNil: [ newSeg subType: aTypeString2 ].
							newSeg type: aTypeString.
							newSeg addTag: self ownerBrick name.
							newSeg setProperty: #span toValue: self.
							s nextPut: newSeg ]
						ifFalse: [  ] ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> depthSideIndex [
	^ self ownerBrick depthSideIndex

]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> findNodeOn: aStanNodeCollection sectionPoint: aPoint [
	^ aStanNodeCollection
		detect: [ :node | self node: node hasPoint: aPoint ]
		ifNone: [  ]
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> local3dPointFromNode: aTwkStanNode [
	^ aTwkStanNode point3d asArray - self ownerBrick stanOffsetWithGrand.
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> node: node hasPoint: aPoint [ 
	| point3d depthValue bool1 bool2 result |
	point3d := self local3dPointFromNode: node.
	depthValue := point3d at: self depthSideIndex.
	bool1 := self depthIncludes: depthValue.
	bool2 := (self sectionPointFromNode: node) closeTo: aPoint.
	result :=  bool1 and: bool2.
	"result ifFalse: [ self haltIf: [node number >= 44. ]]."
	^ result 
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> point2dSegment: aTwkSegment [
	^ LineSegment 
		from: (self sectionPointFromNode: aTwkSegment from) 
		to: (self sectionPointFromNode: aTwkSegment to)
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> sectionPointFromNode: aTwkStanNode [
	| point2d reversePoint index2d flipScale |
	reversePoint := self local3dPointFromNode: aTwkStanNode.
	index2d := self viewDirection2dIndex collect: [:each | each abs].
	flipScale := self viewDirection2dIndex collect: [:each | each sign].
	flipScale := flipScale first @ flipScale second.
	point2d := (reversePoint at: (index2d at: 1)) @ (reversePoint at: (index2d at: 2)).
	point2d := point2d * flipScale.
	^ point2d fixNegativeZero roundedForStan.
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> sortSegmentsCrossOrdered: aTwkSegmentCollection [
	^ aTwkSegmentCollection sort: [ :a :b |
		self compareCrossSegment1: a segment2: b
	]
	
	
]

{ #category : #'*TowerKit-STAN' }
TwkStackItem >> sortSegmentsRoundOrdered: aTwkSegmentCollection [
	^ aTwkSegmentCollection sort: [ :a :b |
		self compareRoundSegment1: a segment2: b
	]
	
	
]
