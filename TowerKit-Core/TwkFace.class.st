Class {
	#name : #TwkFace,
	#superclass : #TwkNode,
	#instVars : [
		'direction',
		'brickStack',
		'spanIndex',
		'optionalSpans',
		'lastAddPlain',
		'grandSpanSize',
		'splitIndexes',
		'crossValues',
		'realMaterialInfos',
		'viewDirection3d',
		'viewDirection2dIndex',
		'recorder',
		'viewDirectionLegIndex'
	],
	#category : #'TowerKit-Core'
}

{ #category : #localization }
TwkFace class >> localizedDirectionStringMap [
	| map |
	map := Dictionary new.
	map at: #front put: '正面'.
	map at: #back put: '背面'.
	map at: #left put: '左側面'.
	map at: #right put: '右側面'.
	map at: #top put: '上面'.
	map at: #bottom put: '下面'.
	^ map
]

{ #category : #adding }
TwkFace >> addWidth: aNumber [
	self recorder add: (Array with: #width with: aNumber).	
]

{ #category : #'objects from disk' }
TwkFace >> additionalObjectKeys [
	^ Array with: 'brickStack' 
]

{ #category : #adding }
TwkFace >> basicAddWidth: aNumber [
	| plain nSkip limit ownIndex left |
	plain := TwkPlane new
		value: aNumber;
		yourself.
	self brickStack addItem: plain.
	limit := 0.
	ownIndex := self brickStack spans indexOf: plain.
	left := self brickStack spans copyFrom: 1 to: ownIndex.
	nSkip := left count: [ :v | v isDepthSpan ].
	[ nSkip ~= spanIndex and: [ limit < 100 ] ]
		whileTrue: [ 
			limit := limit + 1.
			self brickStack downItem: plain.
			ownIndex := self brickStack spans indexOf: plain.
			left := self brickStack spans copyFrom: 1 to: ownIndex.
			nSkip := left count: [ :v | v isDepthSpan ] ]
]

{ #category : #adding }
TwkFace >> basicSkipSpans: anInteger [ 
	spanIndex ifNil: [ spanIndex := 0 ].
	spanIndex := spanIndex + anInteger.
	
]

{ #category : #accessing }
TwkFace >> brickStack [
	^ brickStack 
		ifNil: [ 
			brickStack := 
			(TwkBrickStack new parent: self)
				name: self directionString;  
				yourself ]
]

{ #category : #accessing }
TwkFace >> compositBrick [
	^ self parent parent
]

{ #category : #accessing }
TwkFace >> crossValues: aCollection [ 
	crossValues := aCollection.
	aCollection doWithIndex: [ :symbolOrArray :index |
		(self brickStack depthSpans 
			detect: [ :item | item depthIndex = index ] ifNone: [  ])
			ifNotNil: [ :foundDepthItem |
				foundDepthItem crossValues: symbolOrArray ] ]
]

{ #category : #accessing }
TwkFace >> depthIndexAndSign [
	| dir3 depthIndex sign |
	dir3 := self viewDirection3d.
	depthIndex := 0.
	sign := 1.
	self viewDirection3d
		doWithIndex: [ :each :index | 
			depthIndex = 0
				ifTrue: [ 
					(each closeTo: 0.0)
						ifFalse: [ 
							depthIndex := index.
							sign := each sign ] ] ].
	^ Array with: depthIndex with: sign * (dir3 last)
]

{ #category : #accessing }
TwkFace >> direction [
	^ direction asSymbol
	
]

{ #category : #accessing }
TwkFace >> direction: aSymbol [
	direction := aSymbol asSymbol.
	self name: self directionString.
]

{ #category : #accessing }
TwkFace >> directionString [
	^ self direction asString asUppercase
	
]

{ #category : #accessing }
TwkFace >> facePointIndex [
	(self parent indexToDirectionMap)
		keysAndValuesDo: [:index :dir | 
			self direction = dir 
				ifTrue: [ ^ index  ]
			].
	^ 0.

]

{ #category : #accessing }
TwkFace >> facePoints [
	^ self fixPointsOnHorizontal: self brickStack facePoints.

]

{ #category : #actions }
TwkFace >> fillActivePlane [
	recorder ifNil: [ ^ self ].
	recorder do: [ :each |
		each first = #width ifTrue: [ self basicAddWidth: each second ].
		each first = #skip ifTrue: [ self basicSkipSpans: each second ] ]
]

{ #category : #actions }
TwkFace >> fillDefaultRealMaterialInfo [
	self brickStack planeSpans do: [ :span | 
		span realMaterial: (self parent defaultPlaneRealMaterial) ] .
	
]

{ #category : #actions }
TwkFace >> fillPassivePlane [
	self brickStack fillPassivePlane.
	"realMaterialInfos
		ifNotNil: [ 
			| booleanValue indexes planeSpans |
			booleanValue := realMaterialInfos first.
			indexes := realMaterialInfos second.
			planeSpans := self brickStack planeSpans.
			indexes do: [ :index | planeSpans at: index ] ]"
]

{ #category : #actions }
TwkFace >> fillRealMaterialInfo [
	| booleanValue indexes planeSpans |
	realMaterialInfos ifNil: [ ^ self ].
	realMaterialInfos
		do: [ :info | 
			booleanValue := info first.
			indexes := info second.
			planeSpans := self brickStack planeSpans.
			indexes
				do: [ :index | 
					| span |
					span := planeSpans at: index.
					span realMaterial: booleanValue ] ]
]

{ #category : #actions }
TwkFace >> fillSections [
	self parent fillSections: self.
	self parent fillSectionsDepthAuto: self.
	self parent fillSectionsPlaneAuto: self.
	self parent fillSpans: self.	
]

{ #category : #accessing }
TwkFace >> fixPointsOnHorizontal: aPoints [
	| points |
	points := aPoints.
	self isHorizontalStack
		ifTrue: [ points := points collect: [ :p | p rightRotatedInModel ] ].
	^ points
]

{ #category : #accessing }
TwkFace >> grandSpanSize [
	^ grandSpanSize ifNil: [ grandSpanSize := 0 ].
]

{ #category : #accessing }
TwkFace >> grandSpanSize: aNumber [
	grandSpanSize := aNumber.
]

{ #category : #accessing }
TwkFace >> halfPoints [
	^ self fixPointsOnHorizontal: self brickStack halfPoints.

]

{ #category : #'as yet unclassified' }
TwkFace >> indexesOfCrossK [
	^ self 
		valueOfProperty: #indexOfCrossK 
		ifAbsentPut: [ self spansForCrossK collect: [ :each | each depthIndex ] ]
]

{ #category : #initialization }
TwkFace >> initialize [
	super initialize.
	spanIndex := 0.
]

{ #category : #accessing }
TwkFace >> insertPoints [
	^ self fixPointsOnHorizontal: self brickStack insertPoints.

]

{ #category : #testing }
TwkFace >> isHorizontalStack [
	^ self parent direction = #horizontal
]

{ #category : #'objects from disk' }
TwkFace >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(direction grandSpanSize splitIndexes crossValues realMaterialInfos viewDirection3d viewDirection2dIndex recorder); yourself
]

{ #category : #'objects from disk' }
TwkFace >> jsonKeysForObject [
	^ super jsonKeysForObject addAll: self additionalObjectKeys ; yourself
]

{ #category : #accessing }
TwkFace >> localPointsForSlope [
	| points  |
	points := self brickStack splitedHalfPoints.
	points := (points collect: [ :p | p roundTo: TwkTowerKit stanRoundValue ]) asSet asArray.
	^ points
]

{ #category : #'objects from disk' }
TwkFace >> postFixJsonRestore [
	super postFixJsonRestore.
	direction := direction asSymbol.
	recorder 
		ifNotNil: [
			recorder := (TwkNode stringCollectionToSymbols: recorder) asOrderedCollection].
	"self crossValues: (TwkNode stringCollectionToSymbols: crossValues)."

]

{ #category : #'as yet unclassified' }
TwkFace >> realMaterial: aBoolean indexes: aCollection [ 
	realMaterialInfos ifNil: [ realMaterialInfos := OrderedCollection new ].
	realMaterialInfos add: ( Array with: aBoolean with: aCollection). 
]

{ #category : #accessing }
TwkFace >> recorder [
	^ recorder ifNil: [ recorder := OrderedCollection new ]
]

{ #category : #adding }
TwkFace >> skipSpans: anInteger [ 
	self recorder add: (Array with: #skip with: anInteger).	
]

{ #category : #accessing }
TwkFace >> spanValues: aCollection [
	self brickStack spanValues: aCollection
]

{ #category : #'as yet unclassified' }
TwkFace >> spansForCrossK [
	^ self brickStack sectionSpans 
		select: [ :each | each isDepthSpan 
			and: [each wallCross crossValues includesAnyOf: #(k2 k3 k4)] ]
]

{ #category : #accessing }
TwkFace >> splitIndexes [
	^ splitIndexes ifNil: [ splitIndexes := #() ]
]

{ #category : #accessing }
TwkFace >> splitIndexes: aNumberCollection [
	splitIndexes := aNumberCollection.
	splitIndexes
		do: [ :index | 
			(self brickStack depthSpans detect: [ :each | each depthIndex = index ] ifNone: [  ])
				ifNotNil: [ :span | span crossSplit: true ] ]
]

{ #category : #accessing }
TwkFace >> splitedHalfPoints [
	| points |
	points := self brickStack splitedHalfPoints.
	self isHorizontalStack
		ifTrue: [ points := points collect: [ :p | p rightRotatedInModel ] ].
	^ points
]

{ #category : #actions }
TwkFace >> verify [
	self fillActivePlane.
	self fillPassivePlane.
	self fillDefaultRealMaterialInfo.
	self fillRealMaterialInfo.
	self fillSections.
]

{ #category : #accessing }
TwkFace >> viewDirection2dIndex [
	^ viewDirection2dIndex
]

{ #category : #accessing }
TwkFace >> viewDirection2dIndex: aArray3 [
	viewDirection2dIndex := aArray3. 
]

{ #category : #accessing }
TwkFace >> viewDirection3d [
	^ viewDirection3d 
]

{ #category : #accessing }
TwkFace >> viewDirection3d: aArray3 [
	viewDirection3d := aArray3. 
]

{ #category : #accessing }
TwkFace >> viewDirectionLegIndex: aArray2 [
	"at: 1 -> young node Number"
	"at: 2 -> old node Number"	
	viewDirectionLegIndex := aArray2. 
]
