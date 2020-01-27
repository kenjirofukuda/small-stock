Class {
	#name : #TwkAbstractBrick,
	#superclass : #TwkNode,
	#instVars : [
		'verifyTotalLength',
		'defaultPlaneRealMaterial',
		'spanValues',
		'crossValues',
		'spanUsingMap',
		'sectionUsingMap',
		'faceMap',
		'sectionMap',
		'nodeNumberAllocMap',
		'segmentNumberAllocMap',
		'stanOffsetWithGrand',
		'realMaterialSpans'
	],
	#classVars : [
		'SectionMethodMap'
	],
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkAbstractBrick class >> directions [
	^ #()
]

{ #category : #accessing }
TwkAbstractBrick class >> displayDirections [
	^ #()
]

{ #category : #accessing }
TwkAbstractBrick class >> segmentFaceDirections [
	^ self subclassResponsibility 
]

{ #category : #accessing }
TwkAbstractBrick >> addSection: aBlockClosure [ 
	| newSection |
	newSection := TwkSection new.
	newSection parent: self.
	sectionMap ifNil: [ sectionMap :=  Dictionary new ].
	aBlockClosure value: newSection.	
	(sectionMap includesKey:  newSection name)
		ifTrue: [ self error: 'Already exists: ', newSection asString ].
	sectionMap at: newSection name put: newSection.

]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> convert3dFunctions [
	^ self subclassResponsibility 
	
]

{ #category : #accessing }
TwkAbstractBrick >> crossValues: aCollection [ 
	crossValues := aCollection.
	self faces do: [ :face | face crossValues: aCollection ]
]

{ #category : #accessing }
TwkAbstractBrick >> defaultPlaneRealMaterial [
	^ defaultPlaneRealMaterial
]

{ #category : #accessing }
TwkAbstractBrick >> defaultPlaneRealMaterial: aBoolean [ 
	defaultPlaneRealMaterial := aBoolean.
]

{ #category : #accessing }
TwkAbstractBrick >> depthSideIndex [
	^ self subclassResponsibility
]

{ #category : #accessing }
TwkAbstractBrick >> direction [
	^ #vertical
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> directionToLegIndexsArray [
	^ #(#(#front 2 1) #(#right 1 4) #(#back 4 3) #(#left 3 2)).

]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> directionToSignIndexArray [
	^ #(#(#front 4) #(#back 3) #(#left 2) #(#right 1)).

]

{ #category : #accessing }
TwkAbstractBrick >> directions [
	^ self class directions
]

{ #category : #accessing }
TwkAbstractBrick >> displayDirections [
	^ self class displayDirections
]

{ #category : #accessing }
TwkAbstractBrick >> faceAt: aDirectionSymbol [
	self assert: (self class directions includes: aDirectionSymbol).
	^ faceMap
		at: aDirectionSymbol
		ifAbsentPut: [ 
			TwkFace new
				parent: self;
				direction: aDirectionSymbol;
				viewDirection3d: (self viewDirection3dMap at: aDirectionSymbol);
				viewDirectionLegIndex: (self viewDirectionLegIndexMap at: aDirectionSymbol);
				viewDirection2dIndex: (self viewDirection2dIndexMap at: aDirectionSymbol)
				yourself ]
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> facePointRoundMaps [
	^ self facePointRoundMapsSpanFilter: [ :each | true ] 
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> facePointRoundMapsSpanFilter: aBlock [
	^ self facePointRoundMapsSpanFilter: aBlock makePointBlock: [ :span | span facePoints ]
	

]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> facePointRoundMapsSpanFilter: aBlock makePointBlock: aMakePointBlock [
	| facePointsMap allRound |
	facePointsMap := Dictionary new.
	self faces do: [ :face | facePointsMap at: face direction put: (face stanOrderedSpans select: aBlock) ].
	allRound := OrderedCollection new.
	1 to: (facePointsMap at: #front) size do: [ :index | 
		| round |
		round := Dictionary new.
		self directions
			do: [ :direction | 
				| span basePoints |
				span := (facePointsMap at: direction) at: index.
				basePoints := aMakePointBlock cull: span cull: direction. 
				round
					at: direction
					put:
						(basePoints
							collect: [ :p | 
								self isBeam
									ifTrue: [ p rightRotatedInModel ]
									ifFalse: [ p ] ]).
							].
		(round values anySatisfy: [ :points | points notEmpty ])
			ifTrue: [ 
				round at: #spanIndex put: index.
				allRound add: round ] ].
	^ allRound
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> facePointRoundMapsSpanFilter: aBlock withInsertPoints: aWithInsertPoints [
	| facePointsMap allRound |
	facePointsMap := Dictionary new.
	self faces do: [ :face | facePointsMap at: face direction put: (face stanOrderedSpans select: aBlock) ].
	allRound := OrderedCollection new.
	1 to: (facePointsMap at: #front) size do: [ :index | 
		| round |
		round := Dictionary new.
		self directions
			do: [ :direction | 
				| span basePoints |
				span := (facePointsMap at: direction) at: index.
				basePoints := span facePoints asOrderedCollection.
				aWithInsertPoints
					ifTrue: [
						span section
							ifNotNil: [basePoints addAll: (span section wallSideInsertPointsOnDirection: direction) ] ].
				round
					at: direction
					put:
						(basePoints
							collect: [ :p | 
								self isBeam
									ifTrue: [ p rightRotatedInModel ]
									ifFalse: [ p ] ]).
							].
		(round values anySatisfy: [ :points | points notEmpty ])
			ifTrue: [ 
				round at: #spanIndex put: index.
				allRound add: round ] ].
	^ allRound
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> faceToFunctionIndexMap [
	^ self subclassResponsibility
]

{ #category : #accessing }
TwkAbstractBrick >> faces [
	^ self class displayDirections collect: [ :dir | self faceAt: dir ].
]

{ #category : #actions }
TwkAbstractBrick >> fillSections: aTwkFace [
	sectionUsingMap ifNil: [ ^ self ].
	sectionUsingMap
		keysAndValuesDo: [ :sectionName :indexes | 
			| section |
			section := (sectionMap at: sectionName) .
			(section depthSplit 
				ifTrue: [ aTwkFace brickStack depthSpans ]
				ifFalse: [ aTwkFace brickStack planeSpans ])
				doWithIndex: [ :stackItem :stackIndex | 
					(indexes includes: stackIndex)
						ifTrue: [ 
							stackItem isDepthSpan ifTrue: [ stackItem crossSplit: true ].
							stackItem section: section copy ] ] ]
]

{ #category : #actions }
TwkAbstractBrick >> fillSectionsDepthAuto: aTwkFace [
	(aTwkFace brickStack depthSpans reject: [ :depthSpan | depthSpan crossSplit ])
		ifNotEmpty: [ :noSplitDepthSpans | 
			(noSplitDepthSpans select: [ :each | each wallCross hasHorizontalSegment ])
				ifNotEmpty: [ :spans | spans do: [ :span | span fillDummySplitter ] ] ]
]

{ #category : #actions }
TwkAbstractBrick >> fillSectionsPlaneAuto: aTwkFace [
	aTwkFace brickStack planeSpans
		do: [ :plane | 
			| upperDepth lowerDepth splitCount |
			splitCount := 0.
			upperDepth := plane shallowSideDepthSpan.
			upperDepth
				ifNotNil: [ 
					(upperDepth wallCross hasCrossMemberIndex: 6)
						ifTrue: [ splitCount := splitCount + 1 ] ].
			lowerDepth := plane deepSideDepthSpan.
			lowerDepth
				ifNotNil: [ 
					(lowerDepth wallCross hasCrossMemberIndex: 8)
						ifTrue: [ splitCount := splitCount + 1 ] ].
			splitCount = 2
				ifTrue: [ plane fillDummySplitter ] ]
]

{ #category : #actions }
TwkAbstractBrick >> fillSpans: aTwkFace [
	spanUsingMap ifNil: [ ^ self ].
	spanUsingMap
		keysAndValuesDo: [ :sectionName :indexes | 
			aTwkFace brickStack depthSpans
				doWithIndex: [ :span :spanIndex | 
					(indexes includes: spanIndex)
						ifTrue: [ span section: (sectionMap at: sectionName) copy ] ] ]
				
]

{ #category : #accessing }
TwkAbstractBrick >> frontFace [
	^ self faceAt: #front.
]

{ #category : #accessing }
TwkAbstractBrick >> frontSymbols [
	^ #(front #back)
]

{ #category : #accessing }
TwkAbstractBrick >> indexOfParent [
	^ self parentCollection indexOf: self
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> indexToDirectionMap [
	^ self subclassResponsibility
]

{ #category : #accessing }
TwkAbstractBrick >> indexesOfCrossK [
	^ self 
		valueOfProperty: #indexOfCrossK 
		ifAbsentPut: [ self spansForCrossK collect: [ :each | each depthIndex ] ]
]

{ #category : #initialization }
TwkAbstractBrick >> initialize [
	super initialize.
	faceMap := Dictionary new.
	nodeNumberAllocMap := Dictionary new.
	segmentNumberAllocMap := Dictionary new.	
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> insertPointRoundMapsSpanFilter: aBlock [
	^ self facePointRoundMapsSpanFilter: aBlock makePointBlock: [ :span :direction | 
			span section
				ifNotNil: [span section wallSideInsertPointsOnDirection: direction ]
				ifNil: [ #() ] ]
	

]

{ #category : #testing }
TwkAbstractBrick >> isBeam [
	^ false
]

{ #category : #testing }
TwkAbstractBrick >> isHorizontalStack [
	^ self isBeam
]

{ #category : #testing }
TwkAbstractBrick >> isPost [
	^ false
]

{ #category : #testing }
TwkAbstractBrick >> isValidName [
	name ifNil: [ ^ false ].
	name ifEmpty: [ ^ false ].	
	 ^ self name matchesRegex: '.\d+'
]

{ #category : #'objects from disk' }
TwkAbstractBrick >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(verifyTotalLength defaultPlaneRealMaterial spanValues crossValues  spanUsingMap sectionUsingMap); yourself
]

{ #category : #'objects from disk' }
TwkAbstractBrick >> jsonKeysForObject [
	^ super jsonKeysForObject addAll: #(faceMap sectionMap); yourself
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> local3DPointsForFace [
	^ self local3DPointsForFace:  self facePointRoundMaps.

]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> local3DPointsForFace: aDictionaryArray [
	| funcs indexMap |
	funcs := self convert3dFunctions.
	indexMap := self faceToFunctionIndexMap.
	^ Array
		streamContents: [ :s | 
			aDictionaryArray
				do: [ :roundMap | 
					self directions
						do: [ :dir | 
							(roundMap at: dir)
								ifNotEmpty: [ :facePoints | 
									facePoints
										do: [ :point2d | 
											| array indexes signs p3 |
											array := indexMap at: dir.
											indexes := array collect: [ :each | each abs ].
											signs := array collect: [ :each | each sign ].
											p3 := Array new: 3 withAll: 0.
											p3 doWithIndex: [ :each :index |
												p3 at: index put: ((funcs at: (indexes at: index)) value: point2d) * (signs at: index) ].
											s nextPut: p3 ] ] ] ] ]
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> local3DPointsForSectionCenter [
	^ self local3DPointsForSectionCenter1
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> local3DPointsForSectionRoundInsert [
	^ self local3DPointsForFace: (self insertPointRoundMapsSpanFilter: [ :span | span hasSection ]).

]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> local3DPointsForSlope [
	| planes d3points |
	d3points := OrderedCollection new.
	planes := (self faceAt: #front) brickStack splitedPlanes.
	planes
		do: [ :each | 
			| indexed orderedPoints |
			indexed := each planeSideIndexedPoints.
			orderedPoints := OrderedCollection new.
			(each value closeTo: 0.0)
				ifTrue: [ orderedPoints add: (indexed at: 9) ]
				ifFalse: [ 
					orderedPoints add: (indexed at: 4).
					orderedPoints add: (indexed at: 1).
					orderedPoints add: (indexed at: 2).
					orderedPoints add: (indexed at: 3) ].
			 d3points addAll: orderedPoints].
	^ d3points
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> local3DPointsForSlopeNonSpit [
	| planes d3points |
	d3points := OrderedCollection new.
	planes := (self faceAt: #front) brickStack planeSpans.
	planes
		do: [ :each | 
			| indexed orderedPoints |
			indexed := each planeSideIndexedPoints.
			orderedPoints := OrderedCollection new.
			(each value closeTo: 0.0)
				ifTrue: [ orderedPoints add: (indexed at: 9) ]
				ifFalse: [ 
					orderedPoints add: (indexed at: 4).
					orderedPoints add: (indexed at: 1).
					orderedPoints add: (indexed at: 2).
					orderedPoints add: (indexed at: 3) ].
			 d3points addAll: orderedPoints].
	^ d3points
]

{ #category : #accessing }
TwkAbstractBrick >> longSideSelectorForRectangle [
	^ self isPost ifTrue: [ #height ] ifFalse: [ #width ].
]

{ #category : #accessing }
TwkAbstractBrick >> lookupRealMaterialSpans [
	^ (self faceAt: #front) brickStack realMaterialSpans.
]

{ #category : #'as yet unclassified' }
TwkAbstractBrick >> materialRegisterDo: aBlock [
	aBlock
		value:
			(self
				valueOfProperty: #materialRegistory
				ifAbsentPut: [ 
					TwkMaterialResitory new
						parent: self;
						yourself ])
]

{ #category : #accessing }
TwkAbstractBrick >> nodeCenter [
	^ self parent nodeCenter
]

{ #category : #accessing }
TwkAbstractBrick >> parentCollection [
	^ self parent posts
]

{ #category : #'objects from disk' }
TwkAbstractBrick >> postFixJsonRestore [
	super postFixJsonRestore.
	spanValues 
		ifNotNil: [
			self spanValues: spanValues].
	crossValues
		ifNotNil: [	
			self crossValues: crossValues].	
]

{ #category : #'as yet unclassified' }
TwkAbstractBrick >> realMaterial: aBoolean indexes: aCollection [ 
	self faces do: [:face | face realMaterial: aBoolean indexes: aCollection  ].
]

{ #category : #accessing }
TwkAbstractBrick >> realMaterialSpans [
	^ realMaterialSpans ifNil: [ realMaterialSpans := self lookupRealMaterialSpans ]
]

{ #category : #accessing }
TwkAbstractBrick >> realMaterialSpansOrdered [
	^ self realMaterialSpans 
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> realSectionSpans [
	^ self sectionSpans select: [ :each | each value > 0 and: [ each realMaterial ] ].
]

{ #category : #accessing }
TwkAbstractBrick >> sectionSpans [
	^ (self faceAt: #front) brickStack sectionSpans.
]

{ #category : #accessing }
TwkAbstractBrick >> sectionUsing: aSectionName depthIndexes: aIndexCollection [ 
	self sectionUsing: aSectionName indexes: aIndexCollection 
]

{ #category : #accessing }
TwkAbstractBrick >> sectionUsing: aSectionName indexes: aIndexCollection [ 
	sectionUsingMap ifNil: [ sectionUsingMap := Dictionary new ].
	sectionUsingMap at: aSectionName put: aIndexCollection.
	
]

{ #category : #accessing }
TwkAbstractBrick >> segmentFaceDirections [
	^ self class segmentFaceDirections
]

{ #category : #accessing }
TwkAbstractBrick >> segments2dForSectinCross [
	| map sortProc |
	map := self segments2dForSectinCrossMap.
	sortProc := self isPost
		ifTrue: [ [ :a :b | a index > b index ] ]
		ifFalse: [ [ :a :b | a index < b index ] ].
	^ Array
		streamContents: [ :s | 
			(map keys sort: sortProc)
				do: [ :span | 
					| map2 |
					map2 := map at: span.
					map2 keys sort do: [ :rank | s nextPutAll: (map2 at: rank) ] ] ]
]

{ #category : #accessing }
TwkAbstractBrick >> segments2dForSectinCross: aTwkStackItem [
	^ aTwkStackItem isDummyCross 
		ifTrue: [ #() ]
		ifFalse: [aTwkStackItem planeSideCross splitedCrossSegments].
]

{ #category : #accessing }
TwkAbstractBrick >> segments2dForSectinCrossMap [
	| map  |
	map := Dictionary new.
	self realMaterialSpans
		do: [ :span | 
			| groupMap |
			groupMap := TwkCross segmentsRankMap: (self segments2dForSectinCross: span).
			map at: span put: groupMap ].
	^ map
]

{ #category : #'as yet unclassified' }
TwkAbstractBrick >> shouldBeImplemented [
	[super shouldBeImplemented] on: Error do: [ :ex | self inform: ex asString. ex asString traceCr. ]
]

{ #category : #accessing }
TwkAbstractBrick >> sideSymbols [
	^ self subclassResponsibility 
]

{ #category : #'accessing - 3d' }
TwkAbstractBrick >> signsArray [
	^ Array with: 1 @ 0 with: -1 @ 0 with: 0 @ 1 with: 0 @ -1.

]

{ #category : #accessing }
TwkAbstractBrick >> sliceRoundPointsOfVolume: aNumber [
	| hHalf vHalf signs |
	self assert: aNumber positive.
	hHalf := ((self faceAt: self stanFrontSelector) brickStack lookupPassiveWidthOfHeight: aNumber) / 2.
	vHalf := ((self faceAt: self stanSideSelector) brickStack lookupPassiveWidthOfHeight: aNumber) / 2.
	self assert: hHalf positive. 
	self assert: vHalf positive. 
	signs := self slopeRoundSigns. 
	^ signs collect: [ :each | each * (hHalf @ vHalf)]
]

{ #category : #accessing }
TwkAbstractBrick >> sliceRoundSegmentsOfVolume: aNumber [
	| points |
	points := self sliceRoundPointsOfVolume: aNumber.
	points := points, { points first }.
	^ GeometryUtils lineSegmentsFormPointArray: points.
	
]

{ #category : #accessing }
TwkAbstractBrick >> sliceValues [
	^ (Array streamContents: [ :s |
		self faces do:  [ :f | s nextPutAll: f brickStack sliceHeights  ] ])
		asSet sorted.
]

{ #category : #accessing }
TwkAbstractBrick >> spanUsing: aSectionName indexes: aIndexCollection [ 
	spanUsingMap ifNil: [ spanUsingMap := Dictionary new ].
	spanUsingMap at: aSectionName put: aIndexCollection.
	
]

{ #category : #accessing }
TwkAbstractBrick >> spanValues [
	^ spanValues
]

{ #category : #accessing }
TwkAbstractBrick >> spanValues: aNumberCollection [
	spanValues := aNumberCollection.
	self faces do: [ :face | face spanValues: aNumberCollection ]
]

{ #category : #accessing }
TwkAbstractBrick >> spansForCrossK [
	^ self sectionSpans 
		select: [ :each | each isDepthSpan 
			and: [each wallCross crossValues includesAnyOf: #(k2 k3 k4)] ]
]

{ #category : #accessing }
TwkAbstractBrick >> splitIndexes: aCollection [ 
	self faces do: [ :each | each splitIndexes: aCollection ]
]

{ #category : #action }
TwkAbstractBrick >> verify [
	self faces do: [ :face | face verify ].
	self spanValues ifNil: [ ^ self ].
	self verifyTotalLength isNumber ifFalse: [ ^self ].
	self spanValues sum = self verifyTotalLength
		ifFalse: [ | msg |
			msg := '<1s> Check Sum Error: must <2p> but: <3p>'
				expandMacrosWith: self name
				with: self verifyTotalLength
				with: self spanValues sum.
			msg logCr.	
			self inform: msg ]
]

{ #category : #accessing }
TwkAbstractBrick >> verifyTotalLength [
	^ verifyTotalLength
]

{ #category : #accessing }
TwkAbstractBrick >> verifyTotalLength: aNumber [
	verifyTotalLength := aNumber
]

{ #category : #accessing }
TwkAbstractBrick >> viewDirection2dIndexMap [
	^ self class viewDirection2dIndexMap
]

{ #category : #accessing }
TwkAbstractBrick >> viewDirection3dMap [
	^ self class viewDirection3dMap
]

{ #category : #accessing }
TwkAbstractBrick >> viewDirectionLegIndexMap [
	^ self class viewDirectionLegIndexMap
]
