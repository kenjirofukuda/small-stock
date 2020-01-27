Class {
	#name : #TwkPost,
	#superclass : #TwkAbstractBrick,
	#instVars : [
		'beamMountSpan'
	],
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkPost class >> directions [
	^ #(front left back right)
]

{ #category : #accessing }
TwkPost class >> displayDirections [
	^ #(front right back left)
]

{ #category : #'as yet unclassified' }
TwkPost class >> japaneseClassName [
	^ '支柱'
]

{ #category : #accessing }
TwkPost class >> segmentFaceDirections [
	^ #(#front #left #back #right)
]

{ #category : #accessing }
TwkPost class >> viewDirection2dIndexMap [
	| map |
	map := Dictionary new.
	"XZ: [1, 1]"
	map at: #front put: (Array with: 1 with: 3 with: 1.0). 
	"YZ: [-1, 1]" 
	map at: #left put: (Array with: 2 with: 3 with: -1.0). 	
	"XY: [-1, 1]" 
	map at: #back put: (Array with: 1 with: 3  with: -1.0). 	
	"YZ: [1, 1]" 
	map at: #right put: (Array with: 2 with: 3  with: 1.0). 	
	^ map
]

{ #category : #accessing }
TwkPost class >> viewDirection3dMap [
	| map |
	"at: 4 -> depth sort sign"
	map := Dictionary new.
	map at: #front put: (Array with: 0.0 with: 1.0 with: 0.0 with: 1.0). 
	map at: #left put: (Array with: 1.0 with: 0.0 with: 0.0 with: 1.0). 	
	map at: #back put: (Array with: 0.0 with: -1.0 with: 0.0 with: 1.0). 	
	map at: #right put: (Array with: -1.0 with: 1.0 with: 0.0 with: 1.0). 	
	^ map
]

{ #category : #accessing }
TwkPost class >> viewDirectionLegIndexMap [
	| map |
	map := Dictionary new.
	"XZ: [1, 1]"
	map at: #front put: (Array with: 1 with: 2). 
	"YZ: [-1, 1]" 
	map at: #left put: (Array with: 2 with: 3). 	
	"XY: [-1, 1]" 
	map at: #back put: (Array with: 3 with: 4). 	
	"YZ: [1, 1]" 
	map at: #right put: (Array with: 4 with: 1). 	
	^ map
]

{ #category : #accessing }
TwkPost >> beamMountOffset [
	| total1 total2 |
	total1 := [(self spanValues copyFrom: 1 to: self beamMountSpan - 1) sum] on: Error do: [ :ex | 0 ] .
	total2 := (self spanValues at: self beamMountSpan) * 0.5.
	self valueOfProperty: #stanZOffset ifPresentDo: [ :v | total1 := total1 + v ].
	^ total1 + total2
]

{ #category : #accessing }
TwkPost >> beamMountSpan [
	^ beamMountSpan
]

{ #category : #accessing }
TwkPost >> beamMountSpan: anInteger [ 
	anInteger isInteger
		ifFalse: [ ^ self error: '*** ERROR *** beamMountSpan: must be integer' ].
	beamMountSpan := anInteger.
]

{ #category : #'accessing - 3d' }
TwkPost >> convert3dFunctions [
	^ Array 
		with: ([ :p | p x ])
		with: ([ :p | p y ])
		with: ([ :p | ((self faceAt: #right) brickStack lookupPassiveWidthOfHeight: p y) * 0.5 ]) 
		with: ([ :p | ((self faceAt: #front) brickStack lookupPassiveWidthOfHeight: p y) * 0.5 ]) 

]

{ #category : #accessing }
TwkPost >> depthSideIndex [
	^ 3
]

{ #category : #'accessing - 3d' }
TwkPost >> faceToFunctionIndexMap [
	"index for convert3dFunctions"
	^ IdentityDictionary new
			at: #front put: #(  1 -3  2 );
			at: #left  put: #( -4 -1  2 );
			at: #back  put: #( -1  3  2 );
			at: #right put: #(  4  1  2 );
			yourself

]

{ #category : #accessing }
TwkPost >> fromBeam [
	^ self parent beams detect: [ :each | each to == self ] ifNone: [  ]
]

{ #category : #accessing }
TwkPost >> frontSymbols [
	^ #(front #back)
]

{ #category : #accessing }
TwkPost >> grandSpanSize [
	^ self faces first grandSpanSize
]

{ #category : #accessing }
TwkPost >> grandSpanSize: aNumber [
	self faces do: [ :each | each  grandSpanSize: aNumber]
]

{ #category : #'accessing - 3d' }
TwkPost >> indexToDirectionMap [
	| indexToFaceMap |
	indexToFaceMap := Dictionary new.
	indexToFaceMap at: 5 put: #right.
	indexToFaceMap at: 6 put: #front.
	indexToFaceMap at: 7 put: #left.
	indexToFaceMap at: 8 put: #back.
	indexToFaceMap at: 9 put: nil.
	^ indexToFaceMap
]

{ #category : #testing }
TwkPost >> isPost [
	^ true
]

{ #category : #accessing }
TwkPost >> jointHalfWidth [
	^ (self frontFace brickStack depthSpans
		detect: [ :each | each depthIndex = self beamMountSpan ]
		ifNone: [ 
			self logCr: '*** WARNING *** zero jointHalfWidth.'.
			0 ])
		ifNotNil: [ :foundDepthSpan | 
			| bottomPlaneIndex bottomPlane |
			bottomPlaneIndex := foundDepthSpan index - 1.
			bottomPlane := self frontFace brickStack spans at: bottomPlaneIndex.
			self assert: bottomPlane isPlane .
			bottomPlane value * 0.5 ]
]

{ #category : #'objects from disk' }
TwkPost >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(#beamMountSpan); yourself
]

{ #category : #testing }
TwkPost >> leftMost [
	^ self fromBeam isNil	
]

{ #category : #'accessing - 3d' }
TwkPost >> local3DPointsForSectionCenter1 [
	^ self realMaterialSpans 
		select: [ :span | span planeSideCross crossValues includes: #cross ]
		thenCollect: [ :span | 
			| z center |
			z := span sectionHeight.
			center := span planeSideIndexedPoints at: 9.
			Array with: center x with: center y with: z].

]

{ #category : #'accessing - 3d' }
TwkPost >> local3DPointsForSectionCenter2 [
	| allRecords targetSpans indexToFaceMap |
	allRecords := OrderedCollection new.
	targetSpans := self realSectionSpans.
	indexToFaceMap := self indexToDirectionMap.	
	targetSpans
		do: [ :span | 
			| indexedPoints indexes z map |
			indexedPoints := span planeSideIndexedPoints.
			indexes := span planeSideCross crossMemberIndexes flattened asSet asArray.	"without leg index"
			indexes := indexes reject: [ :index | index <= 4 ].
			map := span naverMap.
			indexes ifEmpty: [ indexes := #(9) ].
			indexes
				do: [ :index | 
					| pt |
					z := span sectionHeight.
					span isPlane
						ifFalse: [ 
							(indexToFaceMap at: index)
								ifNil: [ z := span sectionHeight ]
								ifNotNil: [ :dir | z := (map at: dir) wallSideIndexedPoints at: 9 ] ].
					pt := indexedPoints at: index.
					allRecords add: (Array with: pt x with: pt y with: z) ] ].
	^ allRecords
]

{ #category : #accessing }
TwkPost >> realMaterialSpansOrdered [
	^ self realMaterialSpans reversed
]

{ #category : #accessing }
TwkPost >> sideSymbols [
	^ #(#left #right)
]

{ #category : #accessing }
TwkPost >> stanBeamMountOffset [
	^ self beamMountOffset - self stanGrandSkipDepth
]

{ #category : #accessing }
TwkPost >> toBeam [
	^ self parent beams detect: [ :each | each from == self ] ifNone: [  ]
	
]

{ #category : #testing }
TwkPost >> writeMost [
	^ self toBeam isNil	
]
