Class {
	#name : #TwkSegment,
	#superclass : #TwkStanObject,
	#instVars : [
		'from',
		'to',
		'face',
		'spanIndex'
	],
	#category : #'TowerKit-STAN'
}

{ #category : #'objects from disk' }
TwkSegment class >> csvHeaderOn: s [
	s nextPut: #from.
	s nextPut: #to.

]

{ #category : #'as yet unclassified' }
TwkSegment class >> unitNumber [
	^ 10000
]

{ #category : #'objects from disk' }
TwkSegment >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'from' put: from number.
	aDictionary at: 'to' put: to number.
	aDictionary at: 'brick' put: self parent name.
	face
		ifNotNil: [
			aDictionary at: 'face' put: face direction asString].		
]

{ #category : #'objects from disk' }
TwkSegment >> csvDataOn: s [
	s nextPut: self from number.
	s nextPut: self to number
]

{ #category : #testing }
TwkSegment >> depthSpanForCrossK [
	^ self face brickStack depthSpans detect: [:each | each depthIndex = self spanIndex] 
]

{ #category : #accessing }
TwkSegment >> face [
	^ face
]

{ #category : #accessing }
TwkSegment >> face: aTwkFace [
	face := aTwkFace.
]

{ #category : #accessing }
TwkSegment >> faceIndex [
	^ self face parent segmentFaceDirections  indexOf: self face direction

]

{ #category : #accessing }
TwkSegment >> from [
	^ from
]

{ #category : #accessing }
TwkSegment >> from: aTwkNode [
	from := aTwkNode
]

{ #category : #'instance creation' }
TwkSegment >> from: aFromNode to: aToNode [
	self from: aFromNode.
	self to: aToNode
]

{ #category : #testing }
TwkSegment >> hasLegIndexes: aLegIndexArray [
	^ self legIndexes anySatisfy: [ :each |  aLegIndexArray includes: each ]
]

{ #category : #'as yet unclassified' }
TwkSegment >> indexStep1 [
	| indexK |
	indexK := self segmentIndexInK.
	"self haltIf: [ indexK = 0 ]."
	(#(1 2 3 4) includes: indexK)
		ifTrue: [ ^ 1 ].
	^ 2 
	
]

{ #category : #'as yet unclassified' }
TwkSegment >> indexStep2 [
	| indexK |
	indexK := self segmentIndexInK.
	(#(1 2) includes: indexK) ifTrue: [ ^ 1 ].
	(#(3 4) includes: indexK) ifTrue: [ ^ 2 ].
	^ 3
	
]

{ #category : #testing }
TwkSegment >> insideCrossK [
	face ifNil: [ ^ false ].
	^ self face indexesOfCrossK includes: self spanIndex 
]

{ #category : #testing }
TwkSegment >> insideDiamondCross [
	(self valueOfProperty: #span ifAbsent: [  ])
		ifNotNil: [ :span | 
			^ span planeSideCross crossValues includes: #diamond ].
	^ false
]

{ #category : #testing }
TwkSegment >> isSlope [
	^ self type sameAs: 'slope'
]

{ #category : #accessing }
TwkSegment >> legIndexes [
	^ Array with: self from legIndex with: self to legIndex
]

{ #category : #'as yet unclassified' }
TwkSegment >> lookupSegmentIndexInK [
	| table findSeg |
	table := self depthSpanForCrossK wallCross crossSegments roundedForStan.
	findSeg := self point2dSegment. 
	table doWithIndex: [ :each :index |
		((each start closeTo: findSeg start) and: [ (each end closeTo: findSeg end) ])
			ifTrue: [ ^ index ] ].
	^ 0
]

{ #category : #accessing }
TwkSegment >> lookupSpanIndex [	
	| depthValue |
	depthValue := self point2dCenter y.
	self ownerBrick isHorizontalStack 
		ifTrue: [ depthValue := self point2dCenter x ].
	^ (self parent brickStack findDepthSpans: depthValue)
		ifNotEmpty: [ :spans |
			spans first depthIndex]
		ifEmpty: [ 0 ].
	
]

{ #category : #accessing }
TwkSegment >> point2dCenter [
	^ (self point2dFrom + self point2dTo) * 0.5. 
	
]

{ #category : #accessing }
TwkSegment >> point2dFrom [
	^ self face facePointFromNode: self from.
	
]

{ #category : #accessing }
TwkSegment >> point2dSegment [
	^ LineSegment from: self point2dFrom to: self point2dTo
]

{ #category : #accessing }
TwkSegment >> point2dTo [
	^ self face facePointFromNode: self to.
	
]

{ #category : #printing }
TwkSegment >> printOn: aStream [ 
	aStream << 'SSEG['.
	aStream << self name.
	aStream << ',('.
	aStream << 'from: '.
	aStream << self from number asString.
	aStream << ', '.
	aStream << 'to: '.
	aStream << self to number asString.
	aStream << ')]'	
	
]

{ #category : #'as yet unclassified' }
TwkSegment >> segmentIndexInK [
	^ self valueOfProperty: #segmentIndexInK ifAbsentPut: [ self lookupSegmentIndexInK  ]

]

{ #category : #accessing }
TwkSegment >> spanIndex [	
	^ spanIndex ifNil: [ spanIndex := self lookupSpanIndex  ]
]

{ #category : #accessing }
TwkSegment >> to [
	^ to
]

{ #category : #accessing }
TwkSegment >> to: aTwkNode [
	to := aTwkNode
]
