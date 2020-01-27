Class {
	#name : #TwkDepthSpan,
	#superclass : #TwkStackItem,
	#instVars : [
		'depthIndex',
		'wallCross'
	],
	#category : #'TowerKit-Core'
}

{ #category : #'accessing - cross' }
TwkDepthSpan >> basicHorizontalIndexedPoints [
	^ self basicHorizontalIndexedPointsNew
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> basicHorizontalIndexedPointsNew [
	| map points indexMap a b c d e f g h |
	map := self naverMap.
	points := OrderedCollection new.
	indexMap := Dictionary new.
	map
		keysAndValuesDo: [ :dir :span | 
			indexMap at: dir put: span wallSideIndexedPoints ].
	a := (indexMap at: #bottom) at: 5.
	b := (indexMap at: #bottom) at: 7.
	c := ((indexMap at: #top) at: 5) negated.
	d := ((indexMap at: #top) at: 7) negated.
	e := (indexMap at: #front) at: 5.
	f := (indexMap at: #front) at: 7.
	g := ((indexMap at: #back) at: 5) negated.
	h := ((indexMap at: #back) at: 7) negated.
	points add: (h x @ a x).
	points add: (e x @ b x).
	points add: (f x @ c x).
	points add: (g x @ d x).
	^ points asArray
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> basicHorizontalIndexedPointsOld [
	| map fW tW bW mW corssWidths points |
	map := self naverMap.
	points := OrderedCollection new.
	corssWidths := Dictionary new.
	map
		keysDo: [ :dir | 
			| cross |
			cross := (map at: dir) wallSideIndexedPoints at: 9.
			corssWidths at: dir put: ((map at: dir) parent lookupPassiveWidthOfHeight: cross y) * 0.5 ].
	tW := corssWidths at: #top.
	fW := corssWidths at: #front.
	mW := corssWidths at: #bottom.
	bW := corssWidths at: #back.
	points add: tW @ fW.
	points add: mW @ fW negated.
	points add: mW negated @ bW negated.
	points add: tW negated @ bW.
	^ points asArray
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> basicVerticalIndexedPoints [
	| map points indexMap a b c d e f g h |
	map := self naverMap.
	points := OrderedCollection new.
	indexMap := Dictionary new.
	map
		keysAndValuesDo: [ :dir :span | 
			indexMap at: dir put: span wallSideIndexedPoints ].
	a := (indexMap at: #right) at: 5.
	b := (indexMap at: #right) at: 7.
	c := ((indexMap at: #left) at: 5) negated.
	d := ((indexMap at: #left) at: 7) negated.
	e := (indexMap at: #front) at: 5.
	f := (indexMap at: #front) at: 7.
	g := ((indexMap at: #back) at: 5) negated.
	h := ((indexMap at: #back) at: 7) negated.
	points add: (h x @ a x ).
	points add: (e x @ b x).
	points add: (f x @ c x).
	points add: (g x @ d x).
	^ points asArray
]

{ #category : #actions }
TwkDepthSpan >> beGrand [
	self partCode: #grad.
]

{ #category : #actions }
TwkDepthSpan >> bePower [
	self partCode: #power.
]

{ #category : #testing }
TwkDepthSpan >> closeToMidRangeDepth: aTestDepth [
	^ (self midRangeIndexedPoints collect: [ :p | p y ])
		anySatisfy: [ :y | y closeTo: aTestDepth ]
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> crossSegments [
	^ self privateCrossSegments.
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> crossSplited [
	| bottomSide topSide newPassivePlane |
	self crossSplit
		ifFalse: [ ^ super crossSplited ].
	self assert: (self wallCross hasAnyCrosses: #(#k2 #midHorizontal #midToCrossHorizontal #crossHorizontal #b)).
	bottomSide := self copy.
	bottomSide setProperty: #splited toValue: 'bottomSide'.
	bottomSide section: nil.
	topSide := self copy.
	topSide section: nil.
	topSide setProperty: #splited toValue: 'topSide'.
	(self wallCross crossValues includes: #crossHorizontal)
		ifTrue: [ | points |
			points := self wallCross indexedPoints.
			topSide value: ((points at: 8) dist: (points at: 9) abs).
			bottomSide value: ((points at: 9) dist: (points at: 6) abs) ]
		ifFalse: [ 
			{bottomSide.
			topSide} do: [ :each | each value: each value * 0.5 ] ].
	newPassivePlane := TwkPassivePlane new
		realMaterial: true;
		parent: self parent;
		setProperty: #splited toValue: self;
		yourself.
	(self wallCross crossValues includes: #k2)
		ifTrue: [ newPassivePlane crossClass: TwkCrossSliceK ].
	self section 
		ifNil: [ self halt. ]
		ifNotNil: [ :sec | newPassivePlane section: sec copy ].
	"self halt."
	^ Array with: bottomSide with: newPassivePlane with: topSide
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> crossValues [
	^ self wallCross crossValue
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> crossValues: aSymbolOrArray [ 
	self wallCross crossValues: aSymbolOrArray.
	
]

{ #category : #accessing }
TwkDepthSpan >> deepSidePlane [
	^ self deepSideItem
		ifNil: [ nil ]
		ifNotNil: [ :foundItem | 
			foundItem isPlane
				ifFalse: [ self error: 'Not a plane object' ].
			foundItem ]
]

{ #category : #accessing }
TwkDepthSpan >> deepSideSegment [
	([ self deepSidePlane ]
		on: Error
		do: [ :ex | ex return: nil ])
		ifNotNil: [ :plane | 
			plane realMaterial
				ifTrue: [ self wallSideIndexedPoints
						ifNotEmpty: [ :points | 
							((points at: 3) closeTo: (points at: 2))
								ifFalse: [ ^ LineSegment from: (points at: 3) to: (points at: 2) ] ] ] ].
	^ nil
]

{ #category : #accessing }
TwkDepthSpan >> depthBase [
	| startIndex |
	startIndex := self depthIndex - 1. 
	startIndex <= 0 ifTrue: [ ^ 0 ].
	^ ((self parent depthSpans copyFrom: 1 to: startIndex) collect: [ :each | each value ]) sum.
	
]

{ #category : #accessing }
TwkDepthSpan >> depthEnd [
	^ self depthBase + self value.

]

{ #category : #testing }
TwkDepthSpan >> depthIncludes: aDepthValue [
	^ aDepthValue >= self depthBase and: [ aDepthValue <= self depthEnd ]
]

{ #category : #accessing }
TwkDepthSpan >> depthIndex [
	^ depthIndex
]

{ #category : #accessing }
TwkDepthSpan >> depthIndex: anInteger [ 
	depthIndex := anInteger.
]

{ #category : #accessing }
TwkDepthSpan >> depthRange [
	| base |
	base := self depthBase. 	
	^ base to: (base + self value).

]

{ #category : #accessing }
TwkDepthSpan >> facePoints [
	| segs points |
	segs := self memberSegments.
	segs size <= 1
		ifTrue: [ ^ #() ].
	points := Array
		streamContents: [ :s | 
			segs
				do: [ :each1 | 
					segs
						do: [ :each2 | 
							each1 = each2
								ifFalse: [ (each1 intersectionWith: each2) 
									ifNotNil: [ :cross | s nextPut: (cross roundTo: TwkTowerKit epsilonForCrossPoint) ] ] ] ] ].
	^ points asSet asArray
]

{ #category : #actions }
TwkDepthSpan >> fillDummySplitter [
	self section: TwkSection depthDummySection .
	self crossSplit: true.
]

{ #category : #initialization }
TwkDepthSpan >> initialize [
	super initialize.
	crossSplit := false.
]

{ #category : #testing }
TwkDepthSpan >> insideDepth: aDepthValue [
	^ aDepthValue > self depthBase and: [ aDepthValue < self depthEnd ]
]

{ #category : #printing }
TwkDepthSpan >> inspectMarker [
	^ '  |  '
]

{ #category : #testing }
TwkDepthSpan >> isDepthSpan [
	^ true
]

{ #category : #testing }
TwkDepthSpan >> isWallSideSquare [
	| shallowSidePlane deepSidePlane |
	shallowSidePlane := self shallowSidePlane.
	shallowSidePlane ifNil: [ ^ false ].
	deepSidePlane := self deepSidePlane.
	deepSidePlane ifNil: [ ^ false ].
	^ shallowSidePlane value closeTo: deepSidePlane value
]

{ #category : #'objects from disk' }
TwkDepthSpan >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(depthIndex); yourself
]

{ #category : #'objects from disk' }
TwkDepthSpan >> jsonKeysForObject [
	^ super jsonKeysForDirect addAll: #(wallCross); yourself
]

{ #category : #accessing }
TwkDepthSpan >> leftSlopeSegment [
	(self wallSideIndexedPoints)
		ifNotEmpty: [ :points |
			^ LineSegment from: (points at: 3) to: (points at: 4)  ].
	^ nil 
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> lookupWallSideIndexedPoints [
	| points shallowSidePlane deepSidePlane unitWidth1 unitWidth2 top bottom|
	shallowSidePlane := [self shallowSidePlane] on: Error do: [:ex | ex return: nil].
	shallowSidePlane ifNil: [ ^ #() ].
	deepSidePlane := [self deepSidePlane] on: Error do: [:ex | ex return: nil].
	deepSidePlane ifNil: [ ^ #() ].	
	unitWidth1 := shallowSidePlane value * 0.5.	
	unitWidth2 := deepSidePlane value * 0.5.	
	points := OrderedCollection new.
	top := self height.
	bottom := deepSidePlane height.
	points add: (unitWidth1 @ top).
	points add: (unitWidth2 @ bottom).
	points add: (unitWidth2 negated @ bottom).	
	points add: (unitWidth1 negated @ top).
	TwkCross fillRestIndexdPointsOn: points.
	^ points asArray	
																
]

{ #category : #accessing }
TwkDepthSpan >> memberSegments [
	^ self crossSegments
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> midRangeIndexedPoints [
	| points |
	points := self wallSideIndexedPoints .
	^ #(9 10 11 5 7) collect: [ :each | points at: each ]
																
]

{ #category : #accessing }
TwkDepthSpan >> offset [
	^ offset ifNil: [ offset := 0 ]
]

{ #category : #accessing }
TwkDepthSpan >> outCode [
	^'OFFSET'
]

{ #category : #'objects from disk' }
TwkDepthSpan >> postFixJsonRestore [
	super postFixJsonRestore.
	wallCross 
		ifNotNil: [ 
			| savedCrossValues |
			savedCrossValues := wallCross crossValues. 
			wallCross := nil.
			self crossValues: savedCrossValues]
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> privateCrossSegments [
	^ self wallCross crossSegments
]

{ #category : #accessing }
TwkDepthSpan >> rightSlopeSegment [
	(self wallSideIndexedPoints)
		ifNotEmpty: [ :points |
			^ LineSegment from: (points at: 2) to: (points at: 1)  ].
	^ nil
]

{ #category : #accessing }
TwkDepthSpan >> sectionHeight [
	^ (self wallCross indexedPoints at: 9) y
]

{ #category : #accessing }
TwkDepthSpan >> shallowSidePlane [
	^ self shallowSideItem
		ifNil: [ nil ]
		ifNotNil: [ :foundItem | 
			foundItem isPlane
				ifFalse: [ self error: 'Not a plane object' ].
			foundItem ]
]

{ #category : #accessing }
TwkDepthSpan >> shallowSideSegment [
	([ self shallowSidePlane ]
		on: Error
		do: [ :ex | ex return: nil ])
		ifNotNil: [ :plane | 
			plane realMaterial
				ifTrue: [ self wallSideIndexedPoints
						ifNotEmpty: [ :points | 
							((points at: 4) closeTo: (points at: 1))
								ifFalse: [ ^ LineSegment from: (points at: 4) to: (points at: 1) ] ] ] ].
	^ nil
]

{ #category : #accessing }
TwkDepthSpan >> sliceSegments [
	^ (Array with: self shallowSideSegment with: self deepSideSegment) reject: [ :seg | seg isNil ]
]

{ #category : #accessing }
TwkDepthSpan >> slopeSegments [
	^ (Array with: self leftSlopeSegment with: self rightSlopeSegment) reject: [ :seg | seg isNil ]
]

{ #category : #'accessing - cross' }
TwkDepthSpan >> splitedCrossSegments [
	^ self wallCross splitedCrossSegments
]

{ #category : #accessing }
TwkDepthSpan >> typeSymbol [
	^ '|'
]

{ #category : #accessing }
TwkDepthSpan >> value [
	^ self offset
]

{ #category : #accessing }
TwkDepthSpan >> value: aNumber [
	self offset: aNumber
]

{ #category : #initialization }
TwkDepthSpan >> wallCross [
	^ wallCross
		ifNil: [ 
			wallCross := TwkCross new parent: self; name: self depthIndex; yourself.
			wallCross indexedPoints: [ self wallSideIndexedPoints ].
			wallCross testSquare: [ self isWallSideSquare ] ].

]

{ #category : #'accessing - cross' }
TwkDepthSpan >> wallSideIndexedPoints [
	^ self valueOfProperty: #wallSideIndexedPoints ifAbsentPut: [ self lookupWallSideIndexedPoints ] 
																
]
