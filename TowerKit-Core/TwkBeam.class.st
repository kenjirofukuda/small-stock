Class {
	#name : #TwkBeam,
	#superclass : #TwkAbstractBrick,
	#instVars : [
		'from',
		'to'
	],
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkBeam class >> directions [
	^ #(front bottom back top)
]

{ #category : #accessing }
TwkBeam class >> displayDirections [
	^ #(top front bottom back)
]

{ #category : #'as yet unclassified' }
TwkBeam class >> japaneseClassName [
	^ '梁'
]

{ #category : #accessing }
TwkBeam class >> segmentFaceDirections [
	^ #(#front #bottom #back #top)
]

{ #category : #accessing }
TwkBeam class >> viewDirection2dIndexMap [
	| map |
	map := Dictionary new.
	"XZ: [1, 1]"
	map at: #front put: (Array with: 1 with: 3 with: 1.0). 
	"XY: [1, 1]"
	map at: #top put: (Array with: 1 with: 2 with: 1.0). 	

	false
		ifTrue: [
			"XZ: [1, 1]"
			map at: #back put: (Array with: 1 with: 3  with: 1.0).  "--> master"]	

		ifFalse: [
			"XZ: [1, -1]"
			"specify 3D direction"
			map at: #back put: (Array with: 1 with: 3  with: -1.0). ]	.


	"XY: [1, -1]"
	map at: #bottom put: (Array with: 1 with: 2  with: -1.0). 	
	^ map
]

{ #category : #accessing }
TwkBeam class >> viewDirection3dMap [
	| map |
	"at: 4 -> depth sort sign"	
	map := Dictionary new.
	map at: #front put: (Array with: 0.0 with: 1.0 with: 0.0 with: 1.0). 
	map at: #top put: (Array with: 0.0 with: 0.0 with: -1.0 with: 1.0).

	true
		ifTrue: [ 	 	
			map at: #back put: (Array with: 0.0 with: 1.0 with: 0.0 with: -1.0). "<--master" ]	
		ifFalse: [
			map at: #back put: (Array with: 0.0 with: -1.0 with: 0.0 with: 1.0) ].
		 	
		map at: #bottom put: (Array with: 0.0 with: 0.0 with: 1.0 with: 1.0). 	
	^ map
]

{ #category : #accessing }
TwkBeam class >> viewDirectionLegIndexMap [
	| map |
	map := Dictionary new.
	"XZ: [1, 1]"
	map at: #front put: (Array with: 2 with: 1). 
	"XY: [1, 1]"
	map at: #top put: (Array with: 2 with: 3). 	

	true
	 	ifTrue: [
			"XZ: [1, 1]"
			map at: #back put: (Array with: 4 with: 3). "<-- master" 	]
		ifFalse: [
			"XZ: [1, 1]"
			map at: #back put: (Array with: 3 with: 4)]. 	


	"XY: [1, -1]"
	map at: #bottom put: (Array with: 4 with: 1). 	
	^ map
]

{ #category : #'accessing - 3d' }
TwkBeam >> convert3dFunctions [
	^ Array 
		with: ([ :p | p x ])
		with: ([ :p | p y ])
		with: ([ :p | ((self faceAt: #front) brickStack lookupPassiveWidthOfHeight: p x) * 0.5 ]) 
		with: ([ :p | ((self faceAt: #top) brickStack lookupPassiveWidthOfHeight: p x) * 0.5 ]) 

]

{ #category : #accessing }
TwkBeam >> depthSideIndex [
	^ 1
]

{ #category : #accessing }
TwkBeam >> direction [
	^ #horizontal
]

{ #category : #'accessing - 3d' }
TwkBeam >> directionToLegIndexsArray [
	^ #(#(#front 2 1) #(#top 1 4) #(#back 3 4) #(#bottom 3 2))
]

{ #category : #'accessing - 3d' }
TwkBeam >> directionToSignIndexArray [
	^ #(#(#front 1) #(#back 2) #(#top 3) #(#bottom 4))
]

{ #category : #'accessing - 3d' }
TwkBeam >> faceToFunctionIndexMap [
	"index for convert3dFunctions"
	^ IdentityDictionary new
			at: #front  put: #(  1 -4  2 );
			at: #bottom put: #(  1  2 -3 );
			at: #back   put: #(  1  4  2 );
			at: #top 	  put: #(  1  2  3 );
			yourself

]

{ #category : #accessing }
TwkBeam >> from [
	^ from
	
]

{ #category : #accessing }
TwkBeam >> from: aStringOrPost [
	from := aStringOrPost isString
		ifTrue: [
			self parent postNamed: aStringOrPost ]
		ifFalse: [ aStringOrPost ]
]

{ #category : #'accessing - 3d' }
TwkBeam >> indexToDirectionMap [
	| indexToFaceMap |
	indexToFaceMap := Dictionary new.
	indexToFaceMap at: 5 put: #front.
	indexToFaceMap at: 6 put: #bottom.
	indexToFaceMap at: 7 put: #back.
	indexToFaceMap at: 8 put: #top.
	indexToFaceMap at: 9 put: nil.
	^ indexToFaceMap
]

{ #category : #testing }
TwkBeam >> isBeam [
	^ true
	
]

{ #category : #accessing }
TwkBeam >> jointLength [
	^ self spanValues sum.
]

{ #category : #'objects from disk' }
TwkBeam >> jsonKeysForObject [
	^ super jsonKeysForObject addAll: #(from to); yourself
]

{ #category : #'accessing - 3d' }
TwkBeam >> local3DPointsForSectionCenter1 [
	^ self realMaterialSpans 
		select: [ :span | span planeSideCross crossValues includes: #cross ]
		thenCollect: [ :span | 
			| x center |
			x := span sectionHeight.
			center := span planeSideIndexedPoints at: 9.
			Array with: x with: center x with: center y].

]

{ #category : #'accessing - 3d' }
TwkBeam >> local3DPointsForSectionCenter2 [
	| allRecords  targetSpans indexToFaceMap|
	allRecords := OrderedCollection new.
	targetSpans := self realSectionSpans.
	indexToFaceMap := self indexToDirectionMap.	
	targetSpans
		do: [ :span | 
			| indexedPoints indexes x map |
			indexedPoints := span planeSideIndexedPoints.
			indexes := span planeSideCross crossMemberIndexes flattened asSet asArray.
			"without leg index"
			indexes := indexes reject: [ :index | index <= 4 ].
			x := span sectionHeight.
			map := span naverMap.
			indexes ifEmpty: [ indexes := #(9) ].
			indexes do: [ :index |
				| pt |
					span isPlane
						ifFalse: [ 
							(indexToFaceMap at: index)
								ifNil: [ x := span sectionHeight ]
								ifNotNil: [ :dir | x := (map at: dir) wallSideIndexedPoints at: 9 ] ].
				pt  := indexedPoints at: index.
				allRecords add: (Array with: x with: pt x with: pt y) ].
				 ].
	^ allRecords
]

{ #category : #accessing }
TwkBeam >> parentCollection [
	^ self parent beams
]

{ #category : #accessing }
TwkBeam >> sideSymbols [
	^ #(#top #bottom)
]

{ #category : #accessing }
TwkBeam >> stanSkipDepthOffset3d [
	self from ifNotNil: [ :fromPost | ^ fromPost stanSkipDepthOffset3d ].
	self to ifNotNil: [ :toPost | ^ toPost stanSkipDepthOffset3d ].
	^ { 0.0 . 0.0 . 0.0 }
		
]

{ #category : #accessing }
TwkBeam >> to [
	^ to
	
]

{ #category : #accessing }
TwkBeam >> to: aStringOrPole [
	to := aStringOrPole isString
		ifTrue: [ 
			self parent postNamed: aStringOrPole ]
		ifFalse: [ aStringOrPole ]
]
