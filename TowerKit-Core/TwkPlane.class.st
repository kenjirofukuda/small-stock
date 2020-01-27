Class {
	#name : #TwkPlane,
	#superclass : #TwkStackItem,
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkPlane >> deepSideDepthSpan [
	^ self deepSideItem
		ifNil: [ nil ]
		ifNotNil: [ :foundItem | 
			foundItem isDepthSpan
				ifFalse: [ self error: 'Not a depth span object' ].
			foundItem ]
]

{ #category : #'as yet unclassified' }
TwkPlane >> defaultRealMaterial [
	^ true
]

{ #category : #'as yet unclassified' }
TwkPlane >> depthIncludes: aNumber [
	^ (self valueOfProperty: #splited ifAbsent: [  ])
		ifNotNil:
			[ :sourceDepthSpan | 
			sourceDepthSpan naverMap values contains: [ :each | each closeToMidRangeDepth: aNumber ] ]
		ifNil: [ self sectionHeight closeTo: aNumber ]
]

{ #category : #accessing }
TwkPlane >> facePoints [
	| indexes |
	self section ifNil: [ ^ #() ].
	self section crossValues ifNil: [ ^ #() ].
	self parent ifNil: [ ^ #() ].
	self parent parent ifNil: [ ^ #() ].
	
	indexes := self section crossDelegate crossMemberIndexes.
	(indexes flattened includes: self parent parent facePointIndex)
		ifTrue: [
			| points |
			points := self  virtualPoints.
			 ^ Array with: (points first + points second) * 0.5. 
			].
	^ #()		
]

{ #category : #actions }
TwkPlane >> fillDummySplitter [
	self section: TwkSection planeDummySection .

]

{ #category : #initialization }
TwkPlane >> initialize [
	super initialize.
	realMaterial := self defaultRealMaterial.
	
]

{ #category : #accessing }
TwkPlane >> insertPoints [
	^ self planeSideCross insertPoints
]

{ #category : #printing }
TwkPlane >> inspectMarker [
	^ '-----'
]

{ #category : #testing }
TwkPlane >> isPlane [
	^ true
]

{ #category : #'as yet unclassified' }
TwkPlane >> memberSegmentWithSplit: aBoolean [
	(self value closeTo: 0.0)
		ifTrue: [ ^ #() ].
	self realMaterial
		ifTrue: [ 
			aBoolean
				ifTrue: [ 
					self facePoints
						ifNotEmpty: [ :points | 
							| vPoints |
							vPoints := self virtualPoints.
							^ Array
								with: (LineSegment from: vPoints first to: points first)
								with: (LineSegment from: points first to: vPoints second) ] ].
			^ Array with: self virtualSegment ].
	^ #()
]

{ #category : #accessing }
TwkPlane >> memberSegments [
	^ self memberSegmentWithSplit: false
]

{ #category : #accessing }
TwkPlane >> offset [
	^ 0
]

{ #category : #accessing }
TwkPlane >> outCode [
	^'PLAIN'
]

{ #category : #accessing }
TwkPlane >> pointOffset: aNumber [
	^ aNumber @ self height.

]

{ #category : #accessing }
TwkPlane >> resolved [
	^ width notNull
]

{ #category : #accessing }
TwkPlane >> shallowSideDepthSpan [
	^ self shallowSideItem
		ifNil: [ nil ]
		ifNotNil: [ :foundItem | 
			foundItem isDepthSpan
				ifFalse: [ self error: 'Not a depth span object' ].
			foundItem ]
]

{ #category : #accessing }
TwkPlane >> typeSymbol [
	^ '-'
]

{ #category : #accessing }
TwkPlane >> value [
	^ self width
]

{ #category : #accessing }
TwkPlane >> value: aNumber [
	self width: aNumber
]

{ #category : #accessing }
TwkPlane >> virtualPoints [
	| y x |
	y := self height.
	x := self value * 0.5.
	^ Array with: (x negated @ y) with: (x @ y).
]

{ #category : #accessing }
TwkPlane >> virtualSegment [
	| y x |
	y := self height.
	x := self value * 0.5.
	^ LineSegment from: (x negated @ y) to: (x @ y).
]
