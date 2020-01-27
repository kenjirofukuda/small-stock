Class {
	#name : #TwkBrickStack,
	#superclass : #TwkNode,
	#instVars : [
		'spans',
		'activeIndex'
	],
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkBrickStack >> activeIndex [
	^ activeIndex ifNil: [ activeIndex := 1 ]
]

{ #category : #accessing }
TwkBrickStack >> activeIndex: anInteger [
	 activeIndex := anInteger.
]

{ #category : #actions }
TwkBrickStack >> addDepth: aNumber [
	self addItem: (TwkDepthSpan new value: aNumber)
]

{ #category : #actions }
TwkBrickStack >> addItem: anVitem [
	anVitem parent: self.
	spans add: anVitem.
	
		
]

{ #category : #actions }
TwkBrickStack >> addPassivePlane [
	self addItem: (TwkPassivePlane new)
]

{ #category : #actions }
TwkBrickStack >> addPlane: aNumber [
	self addItem: (TwkPlane new value: aNumber)
]

{ #category : #'as yet unclassified' }
TwkBrickStack >> clearSpansCache [
	self spans do: [ :each | each clearCache ].
]

{ #category : #actions }
TwkBrickStack >> deleteItem: anSpan [
	| index  |
	index := anSpan index.
	spans remove: anSpan.
	self activeIndex: index.
	anSpan parent: nil.
	
		
]

{ #category : #accessing }
TwkBrickStack >> depthSpans [
	^ self spans select: [:item | item isDepthSpan ]
]

{ #category : #actions }
TwkBrickStack >> downItem: anSpan [
	| index newIndex |
	index := self spans indexOf: anSpan.
	index = 1 
		ifTrue: [ ^ self  ].
	newIndex := index - 1.
	spans value swap: index with: newIndex. 
	spans valueChanged: [(spans at: index) . (spans at: newIndex)].
	self activeIndex:  newIndex.
		
]

{ #category : #accessing }
TwkBrickStack >> facePoints [
	^ (self spans collect: [ :item | item facePoints ]) flattened
]

{ #category : #'objects from disk' }
TwkBrickStack >> fileInJson [
	self outFile exists ifFalse: [ ^ self ].
	self outFile readStreamDo: [ :s |
		([(NeoJSONReader on: s) next] on: Error do: [:ex | ex return: nil])
			ifNotNil: [ :map | 
				self attributesFrom: map].		
		 ] 
]

{ #category : #'objects from disk' }
TwkBrickStack >> fileOutJson [
	self spans ifEmpty: [ ^ self inform: 'Can''t save empty' ].
	self outFile mbWriteStreamDo: [ :s | s nextPutAll: self asJson ].
]

{ #category : #actions }
TwkBrickStack >> fillPassivePlane [
	| s newItems mustPlane |
	newItems := OrderedCollection new.
	s := ReadStream on: self spans.
	mustPlane := false.
	[ s atEnd ]
		whileFalse: [ 
			| item |
			item := s next.
			newItems ifNotEmpty: [ mustPlane := newItems last isDepthSpan ].
			mustPlane
				ifTrue: [ 
					item isPlane
						ifFalse: [ 
							newItems
								add:
									(TwkPassivePlane new
										parent: self;
										yourself) ] ].
			newItems add: item ].
	newItems ifEmpty: [ ^ self ].
	self spans: #().
	newItems first isPlane 
		ifFalse: [ self spans add: (TwkPassivePlane new
										parent: self;
										yourself) ].
	self spans addAll: newItems.
	newItems last isPlane 
		ifFalse: [ self spans add: (TwkPassivePlane new
										parent: self;
										yourself) ].
	
]

{ #category : #accessing }
TwkBrickStack >> findDepthSpans: aDepth [
	^ self depthSpans select: [ :each | each depthIncludes: aDepth ]
]

{ #category : #actions }
TwkBrickStack >> fixDepthSpanIndexes [
	self depthSpans doWithIndex: [ :each :index | each depthIndex: index ]
]

{ #category : #accessing }
TwkBrickStack >> halfPoints [
	^ (self planeSpans collect: [ :item | item halfPoint ])
]

{ #category : #accessing }
TwkBrickStack >> halfPointsSkiped: aSkipSize [
	^ (self splitedSpansOf: (self planeSpans allButFirst: aSkipSize)) collect: [ :item | item halfPoint ]
]

{ #category : #'as yet unclassified' }
TwkBrickStack >> handleSpansUpdate [
	self clearSpansCache.
	self fixDepthSpanIndexes.
	
]

{ #category : #initialization }
TwkBrickStack >> initialize [
	super initialize.
	spans := OrderedCollection new asValueHolder.	
	spans whenChangedDo: [ :val | "val traceCr". self handleSpansUpdate ] 
]

{ #category : #accessing }
TwkBrickStack >> insertPoints [
	^ (self spans collect: [ :item | item insertPoints ]) flattened
]

{ #category : #actions }
TwkBrickStack >> insertSlice [

]

{ #category : #'objects from disk' }
TwkBrickStack >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(activeIndex); yourself
]

{ #category : #'objects from disk' }
TwkBrickStack >> jsonKeysForObjectCollection [
	^ super jsonKeysForObjectCollection addAll: #(spans); yourself
]

{ #category : #accessing }
TwkBrickStack >> leftSlopeSegments [
	^ self slopeSegmentsOfSide: -1
]

{ #category : #accessing }
TwkBrickStack >> leftSlopeSegmentsOfHeight: aNumber [
	| segs |
	segs := self leftSlopeSegments.
	^ segs select: [ :seg | aNumber between: seg start y and: seg end y ] 
]

{ #category : #accessing }
TwkBrickStack >> lookupPassiveWidthOfHeight: aHeight [
	| segs seg xPerYunit |
	segs := self slopeSegmentsOfHeight: aHeight side: 1. 
	segs ifEmpty: [ ^ nil  ].
	seg := segs first.
	(self validWidthItems reverse detect: [ :each | each width = (seg start x * 2) abs ] ifNone:[ nil])
		ifNotNil: [ :found | | delta  result | 
			xPerYunit := (seg direction x / seg direction y).
			delta := (aHeight - found height) *  xPerYunit.
			result := found width + (delta * 2.0).
			"self haltIf: [ result < 0 ]."
			^ result.
			].
	^nil
	
]

{ #category : #accessing }
TwkBrickStack >> planeSpans [
	^ self spans select: [:item | item isPlane ]
]

{ #category : #'objects from disk' }
TwkBrickStack >> postFixJsonRestore [
	super postFixJsonRestore.
	spans ifNotNil: [ self spans: self spans ].
]

{ #category : #accessing }
TwkBrickStack >> realMaterialSpans [
	^ self splited spans select: [:item | item realMaterial or: [item hasSection ]]
]

{ #category : #dependencies }
TwkBrickStack >> release [
	spans ifNotNil: [ 
		spans do: [ :each | each release ].
		spans := nil.
		 ].
	super release.
]

{ #category : #rendering }
TwkBrickStack >> renderContentOn: html [
	html text: 'aiueo'.
]

{ #category : #actions }
TwkBrickStack >> reset [
	spans value: OrderedCollection new.
]

{ #category : #accessing }
TwkBrickStack >> rightSlopeSegments [
	^ self slopeSegmentsOfSide: 1
]

{ #category : #accessing }
TwkBrickStack >> sectionSpans [
	^ self spans select: [:item | item hasSection ]
]

{ #category : #accessing }
TwkBrickStack >> sliceHeights [
	^ Array streamContents: [: s | 
		(self sliceValues)
			inject: 0 into: [ :each :subtotal |  s nextPut: (subtotal + each)]]

]

{ #category : #accessing }
TwkBrickStack >> slicePoints [
	^ self sliceHeights collect: [ :y | (0 @ y) ]

]

{ #category : #accessing }
TwkBrickStack >> sliceValues [
	^ self depthSpans collect: [:each | each value ]

]

{ #category : #accessing }
TwkBrickStack >> slopeSegmentsOfHeight: aNumber side: aSignNumber [
	| segs foundSegs |
	segs := self slopeSegmentsOfSide: aSignNumber.
	segs ifEmpty: [ ^ #() ].
	foundSegs := segs select: [ :seg | aNumber between: seg start y and: seg end y ] .
	
	foundSegs 
		ifEmpty: [
			(aNumber >= segs last end y)
				ifTrue: [  ^ Array with: segs last ]. 
			(aNumber <= segs first start y)
				ifTrue: [  ^ Array with: segs first ] 
			 ].
	^ foundSegs.
]

{ #category : #accessing }
TwkBrickStack >> slopeSegmentsOfSide: aSignNumber [
	| items |
	^ Array streamContents: [ :s |
		items := self validWidthItems .
		items doWithIndex: [ :each :index | | startItem endItem |
			(index < items size)
				ifTrue: [ 
					startItem := items at: index.
					endItem := items at: (index + 1).
					s nextPut: (LineSegment from: (startItem pointOfSide: aSignNumber) to: (endItem pointOfSide: aSignNumber)).
				]
		] 
	]
]

{ #category : #accessing }
TwkBrickStack >> spanValues: aCollection [
	self spans: #().
	aCollection
		doWithIndex: [ :value :index | 
			self 
				addItem:
					(TwkDepthSpan new
						value: value;
						depthIndex: index;
						yourself) ]
]

{ #category : #accessing }
TwkBrickStack >> spans [
	^ spans value
]

{ #category : #accessing }
TwkBrickStack >> spans: aArray [
	spans value: aArray asOrderedCollection.
	spans valueChanged: aArray.
	
]

{ #category : #'as yet unclassified' }
TwkBrickStack >> splited [
	^ self splited: self splitedSpans
]

{ #category : #'as yet unclassified' }
TwkBrickStack >> splited: aSpanCollection [
	| newStack |
	newStack := self class new.
	newStack setProperty: #splited toValue: true. 
	newStack parent: self parent.
	aSpanCollection do: [ :each | newStack addItem: each copy]. 	
	newStack clearSpansCache.
	^ newStack
	
]

{ #category : #accessing }
TwkBrickStack >> splitedHalfPoints [
	^ self splitedPlanes collect: [ :item | item halfPoint ]
]

{ #category : #accessing }
TwkBrickStack >> splitedPlanes [
	^ self splited spans select: [ :each | each isPlane ]
]

{ #category : #accessing }
TwkBrickStack >> splitedSliceHeights [
	^ Array streamContents: [: s | 
		s nextPut: 0.
		(self splited depthSpans collect: [:each | each value ])
			inject: 0 into: [ :each :subtotal |  s nextPut: (subtotal + each)]]

]

{ #category : #accessing }
TwkBrickStack >> splitedSliceValues [
	^ self depthSpans collect: [:each | each value ]

]

{ #category : #'as yet unclassified' }
TwkBrickStack >> splitedSpans [
	^ self splitedSpansOf: self spans
]

{ #category : #'as yet unclassified' }
TwkBrickStack >> splitedSpansOf: aSpanCollection [
	^ Array
		streamContents: [ :s | 
			aSpanCollection
				do: [ :span | 
					s nextPutAll: span crossSplited ] ].

]

{ #category : #'as yet unclassified' }
TwkBrickStack >> subTotalOf: anSpan [ 
	^ self subTotalOf: anSpan  allSpans: self spans. 
]

{ #category : #'as yet unclassified' }
TwkBrickStack >> subTotalOf: anSpan allSpans: aSpans [ 
	| subTotal size |
	"html tableData: [ html checkbox id: html nextId ]."
	size := aSpans indexOf: anSpan.
	subTotal := ((aSpans copyFrom: 1 to: size) collect: [ :each | each offset ]) sum.
	^ subTotal
]

{ #category : #actions }
TwkBrickStack >> upItem: anSpan [
	| index newIndex |
	index := self spans indexOf: anSpan.
	index = self spans size 
		ifTrue: [ ^ self  ].
	newIndex := index + 1.
	spans value swap: index with: newIndex.
	spans valueChanged: [(spans at: index) . (spans at: newIndex)].
	self activeIndex:  newIndex.
		
]

{ #category : #accessing }
TwkBrickStack >> validWidthItems [
	^ self spans select: [:each | each isValidWidthPlane  ]
]
