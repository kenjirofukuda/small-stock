Extension { #name : #TwkAbstractBrick }

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> compareSegment1: a segment2: b [
	^ self subclassResponsibility
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick class >> initialize [
	SectionMethodMap := nil.
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick class >> lookupSectionMethodMap [
	| map |
	map := IdentityDictionary new.
	map at: #sectionRound put: (Array with: #splitedRoundSegments with: 'sectionRound').
	map at: #sectionSlant put: (Array with: #splitedSlantSegments with: 'sectionSlant').
	map at: #sectionVertical put: (Array with: #splitedVerticalSegments with: 'sectionVertical').
	map at: #sectionHorizontal put: (Array with: #splitedHorizontalSegments with: 'sectionHorizontal').
	^ map
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> lookupSpanToSectionFaceNodeMap [
	| nodes spanToNodeMap |
	nodes := self stanNodesForSectionFace.
	spanToNodeMap := Dictionary new.
	nodes
		do: [ :node | 
			| reversePoint depthValue |
			reversePoint := node point3d asArray - self stanOffsetWithGrand.
			depthValue := reversePoint at: self depthSideIndex.
			self realMaterialSpans 
				do: [ :span | 
					| map targetDepth |
					map := span naverMap.
					targetDepth := span sectionHeight.
					span isPlane
						ifTrue: [ 
							(depthValue closeTo: targetDepth)
								ifTrue: [ 
									(spanToNodeMap at: span ifAbsentPut: [ Set new ])
										 add: node ] ]
						ifFalse: [ 
							map
								valuesDo: [ :face | 
									(face closeToMidRangeDepth:  depthValue)
										ifTrue: [ 
											(spanToNodeMap at: span ifAbsentPut: [ Set new ]) 
												add: node ] ] ] ] ].
	^ spanToNodeMap
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> lookupStanNodes [
	^ Array
		streamContents: [ :s | 
			s nextPutAll: self stanNodesForSlope.
			s nextPutAll: self stanNodesForFacePoint.
			s nextPutAll: self stanNodesForSectionRoundInsert.
			s nextPutAll: self stanNodesForSectionCenter ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> lookupStanOffsetWithGrand [
	| offset |
	offset := self stanOffset.
	offset := offset + self stanSkipDepthOffset3d.
	^ offset.

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> lookupStanSegments [
	^ Array
		streamContents: [ :s | 
			s nextPutAll: self stanSegmentsForSlope.
			s nextPutAll: self stanSegmentsForSectionRound.
			s nextPutAll: self stanSegmentsForSectionSlant.
			s nextPutAll: self stanSegmentsForSectionVertical.
			s nextPutAll: self stanSegmentsForSectionHorizontal.
			s nextPutAll: self stanSegmentsForPanel ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> lookupStanSegmentsForPanel [
	| stanSegments roundSegments |
	stanSegments := self stanSegmentsForPanelWithoutNumber.
	roundSegments := self stanSegmentsForSectionRound.
	stanSegments := stanSegments reject: [ :each | roundSegments includes: each ].
	stanSegments := stanSegments sort: [ :a :b | self compareSegment1: a segment2: b ].
	^ TwkStan fillNumbers: stanSegments start: self stanTopNumberForFaceSegment.
	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> lookupStanSegmentsForSectionRound [
	| stanSegments spanToSegmentsMap spanOrdered sortedSegments |
	stanSegments := self stanSegmentsForSectionRoundWithoutNumber.
	spanToSegmentsMap := self spanToStanSegmentsMap: stanSegments.	

	sortedSegments := OrderedCollection new.
	spanOrdered := spanToSegmentsMap keys sort: self sortBlockSpanOrdered.
	spanOrdered do: [ :span | 
		sortedSegments addAll: (span sortSegmentsRoundOrdered: (spanToSegmentsMap at: span)) ].	
	^ TwkStan fillNumbers: sortedSegments start: self stanTopNumberForSectionRoundSegment 

	"1. sort  depth  order."
	"1.1 post  z > "
	"1.2 beam  y < "

	"2. same section"
	"2.1 post face (front, left back, right)   2D (bottom, left, top, right) "
	"2.2 beam face (front, bottom, back, top)  2D (right, bottom, left, top) "
	
	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> offsetNumberForFace [
	^ 50
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> offsetNumberForSection [
	^ 90
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick class >> sectionMethodMap [
	^ SectionMethodMap ifNil: [ SectionMethodMap := self lookupSectionMethodMap  ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> slopeRoundSigns [
	^ ((self stanSlopeRoundSignMap associations 
		sort: [ :a :b | a value < b value ]) allButFirst)
			collect: [ :assoc | assoc key ].
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> sortBlockSpanOrdered [
	^ self isPost
		ifTrue: [ [ :a :b | a index > b index ] ]
		ifFalse: [ [ :a :b | a index < b index ] ].

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> spanToSectionFaceNodeMap [
	^ self valueOfProperty: #spanToSectionFaceNodeMap ifAbsentPut: [ self lookupSpanToSectionFaceNodeMap ] 
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> spanToStanSegmentsMap: aStanSegments [
	| map |
	map := Dictionary new. 
	self realMaterialSpans
		do: [ :slice | 
			| sliceSegments |
			sliceSegments := aStanSegments select: [ :each | 
				(each valueOfProperty: #span ifAbsent: [  ]) == slice ]. 
			map at: slice put: sliceSegments ].
	^ map
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanEdgeNumbers [
	^ Array streamContents: [ :s |
		s nextPutAll: self stanEdgeNumbersForSlope.
		s nextPutAll: self stanEdgeNumbersForSlice.
		s nextPutAll: self stanEdgeNumbersForFace.		
	]

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanEdgeNumbersForFace [
	^ self stanSegmentsForPanel collect: [ :segment | { segment from number . segment to number } ]	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanEdgeNumbersForSlice [
	^ self stanSegmentsForSectionRound collect: [ :segment | { segment from number . segment to number } ]	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanEdgeNumbersForSlope [
	^ self stanSegmentsForSlope collect: [ :segment | { segment from number . segment to number } ]	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanFacePointCsvString [
	^ String streamContents: [ :s |
		self writeStanFacePointCsvOutputTo: s withHeader: true
		 ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanFacePointDo: aBlock [
	| nodeTopNumber  allRecords offset |
	nodeTopNumber := self stanTopNumberForFaceNode.
	allRecords := self local3DPointsForFace.
	offset := self stanOffsetWithGrand.
	allRecords := TwkTowerKit offsetPoints: allRecords offset: offset .
	"allRecords := allRecords reject: [ :p3 | p3 third <= 0.0 ]".
	allRecords := allRecords roundedForStan.
	aBlock value: allRecords value: nodeTopNumber.

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanFillNodeNumbers [
	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanFrontSelector [
	^ #front
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanIndexOfParent [
	^ self stanOrderedParentCollection indexOf: self
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodeNumberAllocKeys [
	^ nodeNumberAllocMap keys

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodes [
	^ self valueOfProperty: #stanNodes ifAbsentPut: [ self lookupStanNodes  ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodesArrayByLegs [
	| colLegs allNodes sortBlock |
	colLegs := self stanNodesArrayByLegsWithoutNumber.
	colLegs := colLegs
		collect: [ :leg | 
			| newCol |
			newCol := OrderedCollection new.
			leg
				do: [ :node | 
					(newCol includes: node)
						ifFalse: [ newCol add: node ] ].
			newCol ].
	allNodes := OrderedCollection new.
	colLegs do: [ :leg | allNodes addAll: leg ].
	allNodes := allNodes asSet asArray.
	allNodes := allNodes select: [ :each | each number < 0 ].
	sortBlock := self isPost
		ifTrue: [ [ :a :b | 
			(a z closeTo: b z)
				ifTrue: [ a legIndex < b legIndex ]
				ifFalse: [ a z > b z ] ] ]
		ifFalse: [ [ :a :b | 
			(a x closeTo: b x)
				ifTrue: [ a legIndex < b legIndex ]
				ifFalse: [ a x < b x ] ] ].
	allNodes := allNodes sort: sortBlock.
	self
		stanSlopeDo: [ :d3points :nodeTopNumber | 
			| number |
			number := nodeTopNumber.
			allNodes
				do: [ :node | 
					node number: number.
					number := number + 1 ] ].
	^ colLegs
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodesArrayByLegsWithoutNumber [
	| signMap colLegs  |
	signMap := self stanSlopeRoundSignMap.
	colLegs := OrderedCollection new.
	4 timesRepeat: [ colLegs add: OrderedCollection new ].
	self
		stanSlopeDo: [ :d3points :nodeTopNumber | 
			d3points
				doWithIndex: [ :p :index | 
					| signPoint legIndex legs |
					signPoint := (self slicePointFromPoint3d: p) sign.
					legIndex := [signMap at: signPoint] 
						on: Error 
						do: [ :ex |
							ex logCr. 
							{
							'point3d' -> p .
							'localPoint' -> (self slicePointFromPoint3d: p) .							
							} logCr.
							ex return: 0].
					legs := legIndex = 0
						ifTrue: [ colLegs ]
						ifFalse: [ Array with: (colLegs at: legIndex) ].
					legs
						do: [ :leg | 
							| node |
							node := self nodeCenter forPoint3d: p.
							node onceParent: self .
							node addTag: self name.
							node legIndex: legIndex.
							node setProperty: #index toValue: index.
							leg add: node ] ] ].
	^ colLegs asArray
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodesForFacePoint [
	self
		stanFacePointDo: [ :allRecords :nodeTopNumber | 
			^ self nodeCenter
				nodesFromPoints: allRecords
				nodeTopNmber: nodeTopNumber
				parent: self
				type: 'panel'
				subType: 'face' ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodesForSectionCenter [
	self
		stanSectionCenterDo: [ :allRecords :nodeTopNumber | 
			^ self nodeCenter
				nodesFromPoints: allRecords
				nodeTopNmber: nodeTopNumber
				parent: self
				type: 'section'
				subType: 'sectionCenter' ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodesForSectionFace [
	| nodes |
	nodes := self stanNodesForFacePoint.
	^ Array
		streamContents: [ :s | 
			self
				stanSectionFaceDo: [ :d3points :number | 
					d3points
						do: [ :point3 | 
							| foundNodes |
							foundNodes := nodes select: [ :node | node point3d = point3 ].
							foundNodes ifNotEmpty: [ s nextPut: foundNodes first ] ] ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodesForSectionRoundInsert [
	self
		stanSectionRoundInsertDo: [ :allRecords :nodeTopNumber | 
			^ self nodeCenter
				nodesFromPoints: allRecords
				nodeTopNmber: nodeTopNumber
				parent: self
				type: 'section'
				subType: 'sectionRoundInsert' ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanNodesForSlope [
	self
		stanSlopeDo: [ :allRecords :nodeTopNumber | 
			^ self nodeCenter
				nodesFromPoints: allRecords
				nodeTopNmber: nodeTopNumber
				parent: self
				type: 'slope'
				subType: 'slope' ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanOffset [
	^ Array with: self stanXOffset with: self stanYOffset with: self stanZOffset 
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanOffsetWithGrand [
	^ stanOffsetWithGrand ifNil: [ stanOffsetWithGrand := self lookupStanOffsetWithGrand  ]

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanOrderedParentCollection [
	^ self parent allBricks
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanPointsAsJson [
	^ NeoJSONWriter toStringPretty: (self stanNodes collect: [ :node | node point3d ])
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSectionCenterCsvString [
	^ String streamContents: [ :s |
		self writeStanSectionCenterCsvOutputTo: s withHeader: true
		 ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSectionCenterDo: aBlock [
	| nodeTopNumber allRecords offset |
	nodeTopNumber := self stanTopNumberForSectionCenterNode.
	allRecords := self local3DPointsForSectionCenter.
	self isPost ifTrue: [ allRecords := allRecords reversed ].
	offset := self stanOffsetWithGrand .
	allRecords := TwkTowerKit offsetPoints: allRecords offset: offset .
	"allRecords := allRecords reject: [ :p3 | p3 third <= 0.0 ]".
	allRecords := allRecords roundedForStan.
	aBlock value: allRecords value: nodeTopNumber
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSectionFaceDo: aBlock [
	| nodeTopNumber allRecords offset |
	nodeTopNumber := self stanTopNumberForFaceNode.
	allRecords := self local3DPointsForFace: (self facePointRoundMapsSpanFilter: [ :span | span hasSection ]).
	offset := self stanOffsetWithGrand.
	allRecords := TwkTowerKit offsetPoints: allRecords offset: offset .
	"allRecords := allRecords reject: [ :p3 | p3 third <= 0.0 ]".
	allRecords := allRecords roundedForStan.
	aBlock value: allRecords value: nodeTopNumber
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSectionRoundInsertDo: aBlock [
	| nodeTopNumber allRecords offset |
	nodeTopNumber := self stanTopNumberForSectionRoundInsertNode.
	allRecords := self local3DPointsForSectionRoundInsert .
	offset := self stanOffsetWithGrand .
	allRecords := TwkTowerKit offsetPoints: allRecords offset: offset .
	"allRecords := allRecords reject: [ :p3 | p3 third <= 0.0 ]".
	allRecords := allRecords roundedForStan.
	aBlock value: allRecords value: nodeTopNumber
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentNumberAllocKeys [
	^ segmentNumberAllocMap keys

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegments [
	^ self valueOfProperty: #stanSegments ifAbsentPut: [ self lookupStanSegments  ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForPanel [
	^ self valueOfProperty: #stanSegmentsForPanel ifAbsentPut: [ self lookupStanSegmentsForPanel ] 
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForPanelWithoutNumber [
	| nodes |
	nodes := self stanNodes.
	^ (Array
		streamContents: [ :s | 
			self faces do: [ :face | 
				(face stanSegmentsForPanel: nodes) 
					ifNotEmpty: [ :segments | 
						s nextPutAll: segments ] ] ])
		asSet asArray
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionCategoryNamed: aSymbol [
	| stanSegments spanToSegmentsMap spanOrdered sortedSegments |
	self assert: (self class sectionMethodMap keys includes: aSymbol).
	stanSegments := self stanSegmentsForSectionWithoutNumberCategoryNamed: aSymbol.
	spanToSegmentsMap := self spanToStanSegmentsMap: stanSegments.	

	sortedSegments := OrderedCollection new.
	spanOrdered := spanToSegmentsMap keys sort: self sortBlockSpanOrdered.
	spanOrdered do: [ :span | 
		sortedSegments addAll: (span sortSegmentsCrossOrdered: (spanToSegmentsMap at: span)) ].
	
	^ TwkStan fillNumbers: sortedSegments start: (self stanTopNumberForSegmentCategoryNamed: aSymbol)
	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionCrossWithoutNumber [
	^ self stanSegmentsForSectionWithoutNumberCategoryNamed: #sectionCross
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionHorizontal [
	^ self stanSegmentsForSectionCategoryNamed: #sectionHorizontal
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionRound [
	^ self valueOfProperty: #stanSegmentsForSectionRound ifAbsentPut: [ self lookupStanSegmentsForSectionRound ] 

	"1. sort  depth  order."
	"1.1 post  z > "
	"1.2 beam  y < "

	"2. same section"
	"2.1 post face (front, left back, right)   2D (bottom, left, top, right) "
	"2.2 beam face (front, bottom, back, top)  2D (right, bottom, left, top) "
	
	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionRoundWithoutNumber [
	^ self stanSegmentsForSectionWithoutNumber: #splitedRoundSegments type: 'sectionRound'
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionSlant [
	^ self stanSegmentsForSectionCategoryNamed: #sectionSlant
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionVertical [
	^ self stanSegmentsForSectionCategoryNamed: #sectionVertical
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionWithoutNumber: aGetSegmentsSelector type: aTypeString [
	| nodes spans |
	nodes := self stanNodes.
	spans := self realMaterialSpans.
	
	(aTypeString sameAs: 'sectionSlant')
		ifTrue: [
			spans := spans reject: [ :span | span isDummyCross ] ].	
	^ Array
		streamContents: [ :s | 
			spans
				do: [ :span | 
					s nextPutAll: (span createStanSegments: aGetSegmentsSelector nodes: nodes type: aTypeString subType: aTypeString) ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSectionWithoutNumberCategoryNamed: aSymbol [
	(self class sectionMethodMap at: aSymbol)
		ifNotNil: [ :selectorAndType | 
			^ self stanSegmentsForSectionWithoutNumber: selectorAndType first type: selectorAndType second ].
	^ #()
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSlope [
	| segments zOrderMap |
	segments := self stanSegmentsForSlopeWithoutNumber.
	zOrderMap := Dictionary new.
	segments
		do: [ :seg | 
			| zOrder |
			zOrder := seg valueOfProperty: #zOrderFromTop.
			(zOrderMap at: zOrder ifAbsentPut: [ OrderedCollection new ]) add: seg ].
	segments := OrderedCollection new.	
	zOrderMap keys sort
		do: [ :index | 
			((zOrderMap at: index) sort: [ :a :b | 
					(a valueOfProperty: #legIndex) < (b valueOfProperty: #legIndex) ])
				do: [ :each | 
					segments add: each ] ].
	^ (TwkStan fillNumbers: segments  start:  self stanTopNumberForSlopeSegment) asSet asArray sort: [:a :b | a number < b number ].

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSegmentsForSlopeWithoutNumber [
	| legs  |
	^ Array
		streamContents: [ :s | 
			legs := self stanNodesArrayByLegs.
			legs
				doWithIndex: [ :nodes :legIndex | 
					1 to: nodes size - 1 do: [ :index | 
						| n1 n2 |
						n1 := nodes at: index.
						n2 := nodes at: index + 1.
						s
							nextPut:
								((self nodeCenter segmentFrom: n1 to: n2)
									parent: self;
									addTag: self name;
									type: 'slope';
									subType: 'slope';
									setProperty: #legIndex toValue: legIndex;
									setProperty: #zOrderFromTop toValue: index;
									yourself) ] ] ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSideSelector [
	^ #right
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSliceRoundSegmentsOfVolume: aNumber [
	^ (self sliceRoundSegmentsOfVolume: aNumber)
		collect: [ :seg | seg roundedForStan ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSlopeCsvString [
	^ String streamContents: [ :s |
		self writeStanSlopeCsvOutputTo: s withHeader: true.
		 ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSlopeDo: aBlock [
	| nodeTopNumber d3points offset |
	d3points := self stanLocal3DPointsForSlope.
	nodeTopNumber := self stanTopNumberForSlopeNode: d3points.
	offset := self stanOffsetWithGrand.
	d3points := TwkTowerKit offsetPoints: d3points offset: offset .
	"d3points := d3points reject: [ :p3 | p3 third <= 0.0 ]".
	d3points := d3points roundedForStan.
	aBlock value: d3points value: nodeTopNumber
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanSlopeRoundSignMap [
	^ self class stanSlopeRoundSignMap
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick class >> stanSlopeRoundSignMap [
	^ self subclassResponsibility
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForFaceNode [
	^ self stanTopNumberForNodeCategoryNamed: #face
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForFaceSegment [
	^ self stanTopNumberForSegmentCategoryNamed: #face
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForNodeCategoryNamed: aSymbol [
	| number |
	number := self topNodeNumberFor: aSymbol.
	nodeNumberAllocMap keys ifEmpty: [ ^ number ].
	^ number adjustOne
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForSectionCenterNode [
	^ self stanTopNumberForNodeCategoryNamed: #sectionCenter
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForSectionRoundInsertNode [
	^ self stanTopNumberForNodeCategoryNamed: #sectionRoundInsert
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForSectionRoundSegment [
	^ self stanTopNumberForSegmentCategoryNamed: #sectionRound		
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForSegmentCategoryNamed: aSymbol [	
	| number |
	number := self topSegmentNumberFor: aSymbol.
	segmentNumberAllocMap keys ifEmpty: [ ^ number ].
	^ number adjustOne

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForSlopeNode [	
	^ self stanTopNumberForSlopeNode: #()
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForSlopeNode: d3points [
	| number |	
	number := self topNodeNumberFor: #slope.
	nodeNumberAllocMap keys ifEmpty: [ ^ number ].
	d3points isEmptyOrNil ifTrue: [ ^ number ].	
	^ number + (self stanTopNumberOffset: d3points)
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberForSlopeSegment [	
	^ self stanTopNumberForSegmentCategoryNamed: #slope.

]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanTopNumberOffset: d3points [
	(d3points first)
		ifNotNil: [ :p3 |
			(((p3 at: 1) @ (p3 at: 2)) closeTo: (0.0 @ 0.0))
				ifFalse: [ ^ 1 ].
			  ] .
	^ 0.
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanXOffset [
	^ 0
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanYOffset [
	^ 0
	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> stanZOffset [
	^ self valueOfProperty: #stanZOffset ifAbsent: [ 0 ] 
	
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> topNodeNumber: aNumber for: aSymbol [
	self assert: (#(#slope #face #sectionCenter #sectionRoundInsert) includes: aSymbol).
	nodeNumberAllocMap at: aSymbol put: aNumber.
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> topNodeNumberFor: partSymbol [
	| partial |
	partial := nodeNumberAllocMap at: partSymbol ifAbsent: [ self nodeCenter maxNodeNumber + 1 ].
	partial = #continue
		ifFalse: [ ^ partial ].
	^ (self nodeCenter maxNodeNumberOfBrick: self) + 1
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> topSegmentNumber: aNumber for: aSymbol [
	self assert: ((self class sectionMethodMap keys, #(#slope #face)) includes: aSymbol).
	segmentNumberAllocMap at: aSymbol put: aNumber.
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> topSegmentNumberFor: partSymbol [
	| partial |
	partial := segmentNumberAllocMap
		at: partSymbol
		ifAbsent: [ self nodeCenter maxSegmentNumber + 1 ].
	^ partial = #continue
		ifFalse: [ partial ]
		ifTrue: [ self nodeCenter maxSegmentNumber + 1 ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> unitNumberForNode [
	^ 100
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> unitNumberForSegment [
	^ 1000.
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> writeStanFacePointCsvOutputTo: aStream withHeader: aBoolean [
	self
		stanFacePointDo: [ :allRecords :nodeTopNumber | 
			TwkTowerKit
				writeD3Points: allRecords
				topNumber: nodeTopNumber
				on: aStream
				withHeader: aBoolean ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> writeStanSectionCenterCsvOutputTo: aStream withHeader: aBoolean [
	self
		stanSectionCenterDo: [ :allRecords :nodeTopNumber | 
			TwkTowerKit
				writeD3Points: allRecords
				topNumber: nodeTopNumber
				on: aStream
				withHeader: aBoolean ]
]

{ #category : #'*TowerKit-STAN' }
TwkAbstractBrick >> writeStanSlopeCsvOutputTo: aStream withHeader: aBoolean [
	self
		stanSlopeDo: [ :d3points :nodeTopNumber | 
			TwkTowerKit
				writeD3Points: d3points
				topNumber: nodeTopNumber
				on: aStream
				withHeader: aBoolean ]
]
