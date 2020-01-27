Class {
	#name : #TwkStackItem,
	#superclass : #TwkNode,
	#instVars : [
		'width',
		'offset',
		'originKind',
		'partKind',
		'viewDirection',
		'crossSplit',
		'childStack',
		'section',
		'planeSideCross',
		'realMaterial',
		'crossClass'
	],
	#category : #'TowerKit-Core'
}

{ #category : #'as yet unclassified' }
TwkStackItem class >> fromMap: aDictionary [
	| outCode clazz instance |
	outCode := aDictionary at: 'code'.
	(outCode sameAs: 'PLAIN')
		ifTrue: [ clazz := TwkPlane ].
	(outCode sameAs: 'PASSIVE')
		ifTrue: [ clazz := TwkPassivePlane ].
	(outCode sameAs: 'OFFSET')
		ifTrue: [ clazz := TwkDepthSpan ].
	clazz ifNil: [ ^ self ].
	instance := clazz new.
	instance attributesFrom: aDictionary.
	^ instance
				
]

{ #category : #converting }
TwkStackItem >> asDepthSpan [
	^ TwkDepthSpan new setAttributesFrom: self
]

{ #category : #converting }
TwkStackItem >> asPassivePlane [
	^ TwkPassivePlane new setAttributesFrom: self
]

{ #category : #converting }
TwkStackItem >> asPlane [
	^ TwkPlane new setAttributesFrom: self
]

{ #category : #'accessing - cross' }
TwkStackItem >> basicHorizontalIndexedPoints [
	| map fW tW bW mW points |
	map := self naverMap.
	points := OrderedCollection new.
	tW := (map at: #top) value * 0.5.  
	fW := (map at: #front) value * 0.5.  
	mW := (map at: #bottom) value * 0.5.  
	bW := (map at: #back) value * 0.5.  
	points add: (tW         @ fW).
	points add: (mW         @ fW negated).
	points add: (mW negated @ bW negated).
	points add: (tW negated @ bW).
	^ points asArray	
]

{ #category : #'accessing - cross' }
TwkStackItem >> basicVerticalIndexedPoints [
	| map fW lW bW rW points |
	map := self naverMap.
	points := OrderedCollection new.
	fW := (map at: #front) value * 0.5.  
	lW := (map at: #left) value * 0.5.  
	bW := (map at: #back) value * 0.5.  
	rW := (map at: #right) value * 0.5.  
	points add: (bW         @ rW). 
	points add: (fW         @ rW negated). 
	points add: (fW negated @ lW negated). 
	points add: (bW negated @ lW).
	^ points asArray	
]

{ #category : #accessing }
TwkStackItem >> childStack [
	^ childStack ifNil: [ childStack := TwkBrickStack new parent: self ]
]

{ #category : #private }
TwkStackItem >> clearCache [
	
]

{ #category : #accessing }
TwkStackItem >> columnValue [
	^ self value
]

{ #category : #accessing }
TwkStackItem >> crossClass [
	^ crossClass ifNil: [ crossClass := TwkCross ].
	
]

{ #category : #accessing }
TwkStackItem >> crossClass: aTwkCrossClass [
	crossClass := aTwkCrossClass 
	
]

{ #category : #accessing }
TwkStackItem >> crossSplit [
	^ crossSplit
]

{ #category : #accessing }
TwkStackItem >> crossSplit: aBoolean [
	crossSplit := aBoolean
]

{ #category : #'accessing - cross' }
TwkStackItem >> crossSplited [
	^ Array with: self
]

{ #category : #accessing }
TwkStackItem >> deepSideItem [
	| prevIndex |
	prevIndex := self index - 1.
	prevIndex <= 0 ifTrue: [ ^ nil ].
	^ self parent spans at: prevIndex.

]

{ #category : #testing }
TwkStackItem >> depthIncludes: aNumber [ 
	^ self subclassResponsibility 
]

{ #category : #displaying }
TwkStackItem >> displayString [
	^ self columnValue 
		ifNil: [ '-' ] 
		ifNotNil: [ :v |v printShowingDecimalPlaces: 2]
]

{ #category : #accessing }
TwkStackItem >> halfPoint [
	^ (self width * 0.5) @ self height
]

{ #category : #accessing }
TwkStackItem >> halfPoints [
	^ self Array with: self halfPoint
]

{ #category : #accessing }
TwkStackItem >> halfWidth [
	self width <= 0 ifTrue: [ ^ 0 ].
	^ self width / 2.0
]

{ #category : #testing }
TwkStackItem >> hasChildStack [
	^ self childStack spans notEmpty 
]

{ #category : #testing }
TwkStackItem >> hasSection [
	^ self section notNil
]

{ #category : #accessing }
TwkStackItem >> height [
	^ (self parent subTotalOf: self)
]

{ #category : #accessing }
TwkStackItem >> index [
	^ self parent spans indexOf: self.

]

{ #category : #initialization }
TwkStackItem >> initialize [
	super initialize.
	crossSplit := false.
	self viewDirection: #frontToBack.
	realMaterial := false.
	
]

{ #category : #accessing }
TwkStackItem >> insertPoints [
	^ #()
]

{ #category : #printing }
TwkStackItem >> inspectMarker [
	^ '     '
]

{ #category : #testing }
TwkStackItem >> isDepthSpan [
	^ false
]

{ #category : #testing }
TwkStackItem >> isDummyCross [
	^ section 
		ifNil: [ false ]
		ifNotNil: [ section dummyCross ]
]

{ #category : #testing }
TwkStackItem >> isPassive [
	^ false
]

{ #category : #testing }
TwkStackItem >> isPlane [
	^ false
]

{ #category : #testing }
TwkStackItem >> isPlaneSideSquare [
	| points seg1 seg2 seg3 seg4 |
	points := self planeSideIndexedPoints.
	seg1 := LineSegment from: (points at: 4) to: (points at: 1). 
	seg2 := LineSegment from: (points at: 3) to: (points at: 2). 
	seg3 := LineSegment from: (points at: 1) to: (points at: 2). 
	seg4 := LineSegment from: (points at: 4) to: (points at: 3).
	^ (seg1 length closeTo: seg2 length) and: [seg3 length closeTo: seg4 length].
	 			
]

{ #category : #testing }
TwkStackItem >> isValidWidthPlane [
	self isPlane ifFalse: [ ^ false ].
	self next ifNil: [ ^ true ].
	^ self width > 0 
]

{ #category : #'objects from disk' }
TwkStackItem >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(#width #offset #originKind #partKind #viewDirection #crossSplit #childStack  #realMaterial); yourself 
]

{ #category : #'objects from disk' }
TwkStackItem >> jsonKeysForObject [
	^ super jsonKeysForObject addAll: #(#section); yourself
]

{ #category : #accessing }
TwkStackItem >> leftPoint [
	^ self pointOfSide: -1
]

{ #category : #accessing }
TwkStackItem >> lookupNaverMap [
	self
		ownerBrickDo: [ :brick | 
			| map |
			map := Dictionary new.
			brick directions do: [ :each | 
				| stack |
				stack := (brick faceAt: each) brickStack.
				(self parent valueOfProperty: #splited ifAbsent: [ false ])
					ifTrue: [ stack := stack splited ].
				map at: each put: (stack spans at: self index) ].
			^ map ].
	^ nil
]

{ #category : #accessing }
TwkStackItem >> naverAt: aDirection [
	self ownerBrickDo: [ :brick | ^ brick spans at: self index ].
	^ nil
]

{ #category : #accessing }
TwkStackItem >> naverMap [
	^ self valueOfProperty: #naverMap ifAbsentPut: [ self lookupNaverMap  ]
]

{ #category : #accessing }
TwkStackItem >> next [
	| index |
	index := self parent spans indexOf: self.
	(index >= self parent spans size)
		ifTrue: [ ^ nil ].
	^ self parent spans at: index + 1
]

{ #category : #accessing }
TwkStackItem >> offset [
	^ offset ifNil: [ offset := 0 ]
]

{ #category : #accessing }
TwkStackItem >> offset: aNumber [
	offset := [aNumber asNumber] on: Error do: [ :ex | ex return: nil ]. 
]

{ #category : #accessing }
TwkStackItem >> originKind [
	originKind ifNil: [ ^ '' ].
	^ originKind
]

{ #category : #accessing }
TwkStackItem >> originKind: aSymbol [
	originKind := aSymbol isEmptyOrNil
		ifTrue: [ nil ]
		ifFalse: [ aSymbol asLowercase asSymbol ]
]

{ #category : #accessing }
TwkStackItem >> outCode [
	^'NULL'

]

{ #category : #accessing }
TwkStackItem >> partKind [
	partKind ifNil: [ ^ '' ].
	^ partKind
]

{ #category : #accessing }
TwkStackItem >> partKind: aSymbol [
	partKind := aSymbol isEmptyOrNil
		ifTrue: [ nil ]
		ifFalse: [ aSymbol asLowercase asSymbol ]
]

{ #category : #accessing }
TwkStackItem >> planeSideCross [
	^ planeSideCross
		ifNil: [ 
			planeSideCross := self crossClass new.
			planeSideCross parent: self.
			planeSideCross indexedPoints: [ self planeSideIndexedPoints ].
			self section ifNotNil: [ :sec | 
				planeSideCross crossValues: sec crossValues ].
			planeSideCross testSquare: [ self isPlaneSideSquare ].
			planeSideCross ]
]

{ #category : #'as yet unclassified' }
TwkStackItem >> planeSideHorizontalIndexedPoints [
	|  points |
	points := OrderedCollection new.
	points addAll: self basicHorizontalIndexedPoints.
	TwkCross fillRestIndexdPointsOn: points.
	^ points asArray	
																
]

{ #category : #accessing }
TwkStackItem >> planeSideIndexedPoints [
	^ self ownerBrick isPost
		ifTrue: [ self planeSideVerticalIndexedPoints  ]  
		ifFalse: [ self planeSideHorizontalIndexedPoints  ]
]

{ #category : #'as yet unclassified' }
TwkStackItem >> planeSideVerticalIndexedPoints [
	|  points |
	points := OrderedCollection new.
	points addAll: self basicVerticalIndexedPoints.
	TwkCross fillRestIndexdPointsOn: points.
	^ points asArray	
																
]

{ #category : #accessing }
TwkStackItem >> pointOfSide: aSignNumber [ 
	^ (self halfWidth * aSignNumber) @ self height
]

{ #category : #accessing }
TwkStackItem >> prev [
	| index |
	index := self parent spans indexOf: self.
	index <= 1
		ifTrue: [ ^ nil ].
	^ self parent spans at: index - 1
]

{ #category : #printing }
TwkStackItem >> printOn: aStream [
	aStream nextPutAll: self inspectMarker.
	aStream nextPut: Character space.
	aStream nextPutAll: self value asString.

]

{ #category : #accessing }
TwkStackItem >> realMaterial [
	 ^ realMaterial ifNil: [realMaterial := false].

]

{ #category : #accessing }
TwkStackItem >> realMaterial: aBoolean [
	realMaterial := aBoolean.
	
]

{ #category : #dependencies }
TwkStackItem >> release [
	super release.

]

{ #category : #accessing }
TwkStackItem >> rightPoint [
	^ self pointOfSide: 1
]

{ #category : #accessing }
TwkStackItem >> section [
	^ section
]

{ #category : #accessing }
TwkStackItem >> section: aTwkSection [
	section := aTwkSection.
	aTwkSection ifNotNil: [aTwkSection parent: self].
]

{ #category : #accessing }
TwkStackItem >> sectionHeight [
	^ self height
]

{ #category : #'objects from disk' }
TwkStackItem >> setAttributesFrom: other [
	self width: other width.
	self offset: other offset.
	
]

{ #category : #accessing }
TwkStackItem >> shallowSideItem [
	| nextIndex |
	nextIndex := self index + 1.
	nextIndex > self parent spans size ifTrue: [ ^ nil ].
	^ self parent spans at: nextIndex.

]

{ #category : #accessing }
TwkStackItem >> splitedRoundSegments [
	^ self planeSideCross splitedRoundSegments
]

{ #category : #accessing }
TwkStackItem >> value [
	^ nil
]

{ #category : #accessing }
TwkStackItem >> viewDirection2dIndex [
	^ self ownerBrick isPost 
		ifTrue: [ #(1 2) ]
		ifFalse: [ #(-2 3) ]
]

{ #category : #accessing }
TwkStackItem >> viewDirection: aSymbol [
	self assert: ( #(frontToBack rightToLeft topToBottom) includes: aSymbol) .
	viewDirection := aSymbol.
]

{ #category : #accessing }
TwkStackItem >> width [
	^ width ifNil: [ width := 0 ]
]

{ #category : #accessing }
TwkStackItem >> width: aNumber [
	width := [aNumber asNumber] on: Error do: [ :ex | ex return: nil ]. 
]
