Extension { #name : #TwkFace }

{ #category : #'*TowerKit-STAN' }
TwkFace >> facePointFromNode: aTwkStanNode [
	^ self facePointFromNode: aTwkStanNode index2d: nil 
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> facePointFromNode: aTwkStanNode index2d: anIndex2d [
	| point2d reversePoint index2d flipScale |
	reversePoint := aTwkStanNode point3d asArray - self parent stanOffsetWithGrand.
	index2d := anIndex2d ifNil: [self viewDirection2dIndex] ifNotNil: [anIndex2d].
	flipScale := self parent isPost
		ifTrue: [ (index2d at: 3) @ 1.0 ]
		ifFalse: [ 1.0 @ (index2d at: 3) ].
	point2d := (reversePoint at: (index2d at: 1)) @ (reversePoint at: (index2d at: 2)).
	point2d := point2d * flipScale.
	^ point2d fixNegativeZero roundedForStan.
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanHalfPoints [
	^ self parent isPost
		ifTrue: [ self stanHalfPointsVertical ]
		ifFalse: [ self stanHalfPointsHorizontal ]
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanHalfPointsHorizontal [
	| points  |
	points := (self stanHalfPointsOffset: 0 @ 0) reversed collect: [:p | p rightRotatedInModel ].	
	^ points
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanHalfPointsOffset: offset [
	| points |
	points := self brickStack splitedHalfPoints.
	points := (points collect: [ :p | p + offset roundTo: TwkTowerKit stanRoundValue ]) asSet asArray.
	points := points sort: [ :a :b | a y > b y ].
	points := points select: [ :p | p y >= 0 ].
	^ points
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanHalfPointsVertical [
	|  offset |
	offset := self parent stanSkipDepthOffset2d.
	^ self stanHalfPointsOffset: offset
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanOrderedSpans [
	^ self parent isPost
		ifTrue: [ self brickStack spans reversed ]
		ifFalse: [ self brickStack spans ]
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanSegmentsForPanel [
	^ self stanSegmentsForPanel: self parent stanNodes withRound: true.
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanSegmentsForPanel: aNodes [
	^ self stanSegmentsForPanel: aNodes withRound: false 
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanSegmentsForPanel: aNodes sourceSegments: aLineSegmentArray [
	| d2toNodeMap |
	^ Array
		streamContents: [ :s | 
			d2toNodeMap := self viewPointToNodeMapFrom: aNodes.
			aLineSegmentArray
				do: [ :seg | 
					| startNode endNode |
					startNode := d2toNodeMap at: seg start ifAbsent: [  ].
					startNode ifNil: [ self traceCr: ('startNode not found: <1p>' expandMacrosWith: seg)	" self halt." ].
					endNode := d2toNodeMap at: seg end ifAbsent: [  ].
					endNode ifNil: [ self traceCr: ('endNode not found: <1p>' expandMacrosWith: seg)	"self halt" ].
					(startNode notNil and: endNode notNil)
						ifTrue: [ | sSeg |
							sSeg := self parent nodeCenter segmentFrom: startNode to: endNode.
							sSeg type
								ifNil: [ sSeg
										parent: self;
										addTag: self parent name;
										face: self;
										type: 'panel';
										subType: 'face' ].
							s nextPut: sSeg ] ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> stanSegmentsForPanel: aNodes withRound: withRound [
	| items |
	items := self stanSegmentsForPanel: aNodes sourceSegments: self splitedSpanCrossSegments.
	^ withRound
		ifTrue: [ items ]
		ifFalse: [ items select: [ :each | each type sameAs: 'panel' ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> viewPointToNodeMap [
	^ self viewPointToNodeMapFrom: self parent stanNodes
]

{ #category : #'*TowerKit-STAN' }
TwkFace >> viewPointToNodeMapFrom: aNodeCollection [
	| d2toNodeMap arr depthIndex sign |
	arr := self depthIndexAndSign.
	depthIndex := arr first.
	sign := arr second.
	d2toNodeMap := Dictionary new.	"collect nodes by view direction. size 1 or 2"
	aNodeCollection
		do: [ :node | 
			| point2d |
			point2d := self facePointFromNode: node.
			d2toNodeMap at: point2d ifAbsentPut: [ OrderedCollection new ].
			(d2toNodeMap at: point2d) add: node ].
		"self haltIf: [ parent name = 'B1'].  parent name = 'B1' ifTrue: [ d2toNodeMap explore ]."
	d2toNodeMap
		keysAndValuesDo: [ :point :nodes2 | 
			| newNodes "find shallow depth side Node" |
			nodes2 size >= 2
				ifTrue: [ 
					newNodes := nodes2 asArray
						sort: [ :a :b | (a point3d at: depthIndex) * sign < ((b point3d at: depthIndex) * sign) ] ]
				ifFalse: [ newNodes := Array with: nodes2 first ].
			d2toNodeMap at: point put: newNodes first ].
	^ d2toNodeMap
]
