Class {
	#name : #TwkCross,
	#superclass : #TwkNode,
	#instVars : [
		'crossValues',
		'indexedPoints',
		'squareBlock'
	],
	#classVars : [
		'CrossIndexMap'
	],
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkCross class >> crossIndexAssociations [
	"TwkCross initialize."
	"self crossIndexAssociations explore."
	^ {  
		#upSlant -> #(#(3 1)).
		#downSlant -> #(#(2 4)).
		"add alias"
		#SU -> #(#(3 1)).
		#SD -> #(#(2 4)).

		#cross -> #(#(3 1) #(2 4)).
		#turnV -> #(#(3 8) #(8 2)).
		#v -> #(#(4 6) #(6 1)).
		#crossHorizontal -> #(#(11 9) #(9 10)).
		#midHorizontalSquare -> #(#(7 9) #(9 5)).
		#midToCrossHorizontal -> #(#(7 9) #(9 5)).
		#midHorizontal -> #(#(7 5)).
		#midVertical -> #(#(6 8)).
		#diamond -> #(#(5 6) #(6 7) #(7 8) #(8 5)).
		#uprightCross -> #(#(6 8) #(7 5)).
		#dir2 -> #(#(6 9)).
		#k2 -> #(
			#(8 12) #(8 13) #(12 2) #(13 3) #(12 1) #(13 4) #(12 5) #(13 7) 
		).
		#b -> #(#(3 1) #(2 4) #(11 9) #(9 10)). " cross + crossHorizontal"
		#crossToBottomCenter -> #(#(9 6)). "deprecated. use t6"
		#t12 -> #(#(9 8)). 
		#t3 -> #(#(9 10)). 
		#t6 -> #(#(9 6)). 
		#t9 -> #(#(9 11)). 		
		#empty -> #()
			}.
	
"
detail of index:
----------------
 4     8     1

11     9     10

 7  13   12  5 

 3     6     2
----------------

 5: mid of 1-2
 7: mid of 4-3
12: cross of 8-2 7-5
13: cross of 8-5 7-5

"
]

{ #category : #accessing }
TwkCross class >> crossMemberSymbols [
	^ CrossIndexMap keys
]

{ #category : #accessing }
TwkCross class >> errorStringForCrossMember [
	^ 'only: ', ((self crossMemberSymbols collect: [ :symbol | symbol asString ])
		joinUsing: ' ')
]

{ #category : #utility }
TwkCross class >> fillRestIndexdPointsOn: aPoints [
	| cross rightCross leftCross midSegH k2LeftCross k2RightCross |
	self assert: aPoints size = 4.	
	aPoints add: ((aPoints at: 1) + (aPoints at: 2)) * 0.5.	"5"
	aPoints add: ((aPoints at: 2) + (aPoints at: 3)) * 0.5.	"6"
	aPoints add: ((aPoints at: 3) + (aPoints at: 4)) * 0.5.	"7"
	aPoints add: ((aPoints at: 4) + (aPoints at: 1)) * 0.5.	"8"
	cross := (LineSegment from: (aPoints at: 1) to: (aPoints at: 3))
		intersectionWith: (LineSegment from: (aPoints at: 2) to: (aPoints at: 4)).
	cross := cross 
		ifNil: [ 0 @ 0 ] 
		ifNotNil: [ cross roundTo: TwkTowerKit epsilonForCrossPoint ].	"9"
	aPoints add: cross.
	rightCross := aPoints at: 5.
	((aPoints at: 1) x - (aPoints at: 2) x closeTo: 0.0)
		ifFalse: [ 
			cross := 
				(LineSegment 
					from: (aPoints at: 9) 
					to: (aPoints at: 9) + (((aPoints at: 1) x * 2) @ 0) )
						intersectionWith: (LineSegment from: (aPoints at: 1) to: (aPoints at: 2)).
			cross 
				ifNotNil: [
					rightCross := cross roundTo: TwkTowerKit epsilonForCrossPoint ].
			 ].	"10"
	aPoints add: rightCross.
	leftCross := aPoints at: 7.
	((aPoints at: 3) x - (aPoints at: 4) x closeTo: 0.0)
		ifFalse: [ 
			cross := 
				(LineSegment 
					from: (aPoints at: 9) 
					to: (aPoints at: 9) + (((aPoints at: 4) x * 2) @ 0) )
						intersectionWith: (LineSegment from: (aPoints at: 3) to: (aPoints at: 4)).
			cross 
				ifNotNil: [
					leftCross := cross roundTo: TwkTowerKit epsilonForCrossPoint ].
			 ].	"11"
	aPoints add: leftCross.
	
	midSegH := LineSegment from: (aPoints at: 7) to: (aPoints at: 5).
	k2RightCross := aPoints at: 2.
	cross := 
		(LineSegment 
			from: (aPoints at: 8) 
			to: (aPoints at: 2))
				intersectionWith: midSegH.
	cross 
		ifNotNil: [
			k2RightCross := cross roundTo: TwkTowerKit epsilonForCrossPoint ].
	aPoints add: k2RightCross. "12"

	k2LeftCross := aPoints at: 3.
	cross := 
		(LineSegment 
			from: (aPoints at: 8) 
			to: (aPoints at: 3))
				intersectionWith: midSegH.
	cross 
		ifNotNil: [
			k2LeftCross := cross roundTo: TwkTowerKit epsilonForCrossPoint ].	
	aPoints add: k2LeftCross.	  "13"


]

{ #category : #'as yet unclassified' }
TwkCross class >> initialize [
	<script>
	| map |
	map := Dictionary new.
	self crossIndexAssociations do: [ :assoc |
		map at: assoc key put: assoc value ].
	CrossIndexMap := map.	
]

{ #category : #accessing }
TwkCross class >> segmentsRankMap: aSegments [
	"7  1  5"
	"4  0  3"
	"6  2  8"
	| map segs |
	map := Dictionary new.
	segs := aSegments collect: [ :seg | seg asItermJTerm ].
	segs do: [ :seg | 
		| rank |
		rank := seg rankOfStan.
		map at: rank ifAbsentPut: [OrderedCollection new].
		(map at: rank) add: seg ].
	^ map
]

{ #category : #accessing }
TwkCross >> addCrossSymbol: aSymbol [
	self crossValues: ((self crossValues, (Array with: aSymbol)) asSet asArray)
]

{ #category : #utility }
TwkCross >> crossMemberIndexes [
	^ Array
		streamContents: [ :s | 
			self crossValues ifNotNil: [ :values | 
				values do: [ :symbol | 
					s nextPut: (self indexesForCrossSymbol: symbol) ] ] ]
]

{ #category : #accessing }
TwkCross >> crossPoints [
	^ (Array
		streamContents: [ :s | 
			| allSegs |
			allSegs := self crossSegments.
			allSegs
				do: [ :seg1 | 
					allSegs
						do: [ :seg2 | 
							seg1 = seg2
								ifFalse: [ (seg1 intersectionWith: seg2) 
									ifNotNil: [ :crossPoint | s nextPut: (crossPoint roundTo: TwkTowerKit epsilonForCrossPoint) ] ] ] ] ]) asSet asArray
]

{ #category : #accessing }
TwkCross >> crossSegments [
	self indexedPoints
		ifNotEmpty: [ :points |  ^ self crossSegmentsForIndexedPoints: points ].
	^ #().
]

{ #category : #utility }
TwkCross >> crossSegmentsForIndexedPoints: aArrayPointCount9 [
	self assert: (aArrayPointCount9 size >= 9).
	^ Array streamContents: [ :s |
		self crossValues ifNotNil: [ :values  | values do: [ :symbol | | indexes |
			indexes := self indexesForCrossSymbol: symbol.
			indexes ifNotEmpty: [ 
				indexes do: [ :pair | | seg |
					seg := LineSegment 
						from: (aArrayPointCount9 at: pair first) to: (aArrayPointCount9 at: pair second) .
					s nextPut: seg.					
					 ]
				 ]
			]]
		]
]

{ #category : #accessing }
TwkCross >> crossValues [
	^ crossValues ifNil: [ #() ]
]

{ #category : #accessing }
TwkCross >> crossValues: aSymbolOrArray [
	| inputSymbols |
	inputSymbols := aSymbolOrArray isSymbol
		ifFalse: [ aSymbolOrArray ]
		ifTrue: [ Array with: aSymbolOrArray ].
	(inputSymbols anySatisfy: [ :symbol | (self class crossMemberSymbols includes: symbol) not ])
		ifTrue: [ self error: self class errorStringForCrossMember ].
	crossValues := inputSymbols
]

{ #category : #testing }
TwkCross >> hasAnyCrosses: aCollection [
	^ aCollection anySatisfy: [ :each | self crossValues includes: each ].
]

{ #category : #testing }
TwkCross >> hasBottomSplitSegment [
	^ self hasCrossMemberIndex: 6

]

{ #category : #testing }
TwkCross >> hasCrossMemberIndex: aNumber [
	^ self crossMemberIndexes flattened asSet includes: aNumber.

]

{ #category : #testing }
TwkCross >> hasHorizontalSegment [
	| pairList |
	pairList := self crossMemberIndexes.
	pairList := Array streamContents: [ :s | pairList do: [ :list | s nextPutAll: list ] ].
	^ #(#(11 9) #(9 11) #(9 10) #(10 9) #(7 9) #(9 7) #(9 5) #(5 9) #(10 11) #(11 10))
		anySatisfy: [ :each | pairList includes: each ]
]

{ #category : #testing }
TwkCross >> hasTopSplitSegment [
	^ self hasCrossMemberIndex: 8
]

{ #category : #accessing }
TwkCross >> indexedPoints [
	^ indexedPoints isBlock
		ifTrue: [ indexedPoints value ]
		ifFalse: [ indexedPoints ]
]

{ #category : #accessing }
TwkCross >> indexedPoints: aArrayOrBlock [
	indexedPoints := aArrayOrBlock.
]

{ #category : #accessing }
TwkCross >> indexesForCrossSymbol: aSymbol [
	| key |
	key := aSymbol.
	aSymbol = #midHorizontal
		ifTrue: [ 
			self isSquare 
				ifTrue: [ key := #midHorizontalSquare ] ].
	^ CrossIndexMap at: key ifAbsent: [ CrossIndexMap at: #empty ].


]

{ #category : #utility }
TwkCross >> indexesForDirection: faceSymbol [
	self ownerBrick isPost
		ifTrue: [ 
			faceSymbol = #front
				ifTrue: [ ^ #(2 3) ].
			faceSymbol = #left
				ifTrue: [ ^ #(3 4) ].
			faceSymbol = #back
				ifTrue: [ ^ #(4 1) ].
			faceSymbol = #right
				ifTrue: [ ^ #(1 2) ] ].
	^ #()
]

{ #category : #accessing }
TwkCross >> insertPoints [
	| map |
	map := self insertSegmentsMap.
	^ Array
		streamContents: [ :s | 
			map
				keysAndValuesDo: [ :key :values | 
					s
						nextPutAll:
							((values collect: [ :each1 | each1 controlPoints ]) flattened reject: [ :cp1 | key controlPoints anySatisfy: [ :each | cp1 closeTo: each ] ]) ] ]
]

{ #category : #accessing }
TwkCross >> insertSegments [
	^ self insertSegmentsMap values flattened
]

{ #category : #accessing }
TwkCross >> insertSegmentsMap [
	| resultMap crosses segs |
	resultMap := Dictionary new.
	self parent isPlane
		ifFalse: [ ^ resultMap ].
	self parent section ifNil: [ ^ resultMap ].
	crosses := OrderedCollection new.
	self ownerBrick directions
		do: [ :dir | 
			(self parent section insertSpecsOfDirection: dir)
				ifNotEmpty: [ :maps | 
					| indexes |
					indexes := self indexesForDirection: dir.
					indexes
						ifNotEmpty: [ 
							| points seg |
							points := self indexedPoints.
							segs := OrderedCollection new.
							seg := LineSegment from: (points at: indexes first) to: (points at: indexes last).
							maps do: [ :map | crosses add: (self offsetSignOfDirection: dir) * (map at: #offset) + seg midPoint ].
							segs addAll: (GeometryUtils splitSegment: seg crossPoints: crosses epsilon: TwkTowerKit epsilon).
							resultMap at: seg put: segs.
							 ] ] ].
	^ resultMap
]

{ #category : #accessing }
TwkCross >> isSquare [
	squareBlock ifNil: [ ^ true ].
	^ squareBlock value
]

{ #category : #'objects from disk' }
TwkCross >> jsonKeysForDirect [
	^ super jsonKeysForDirect addAll: #(crossValues); yourself
]

{ #category : #utility }
TwkCross >> offsetSignOfDirection: faceSymbol [
	self ownerBrick isPost
		ifTrue: [ 
			faceSymbol = #front
				ifTrue: [ ^ 1 @ 0 ].
			faceSymbol = #left
				ifTrue: [ ^ 0 @ -1 ].
			faceSymbol = #back
				ifTrue: [ ^ -1 @ 0 ].
			faceSymbol = #right
				ifTrue: [ ^ 0 @ 1 ] ].
	^ #()
]

{ #category : #'objects from disk' }
TwkCross >> postFixJsonRestore [
	super postFixJsonRestore.
	"self crossValues: (TwkNode stringCollectionToSymbols: crossValues)."

]

{ #category : #accessing }
TwkCross >> removeCrossSymbol: aSymbol [
	self crossValues: (self crossValues reject: [ :each | each = aSymbol ])
]

{ #category : #accessing }
TwkCross >> roundSegments [
	| points indexed |
	indexed := self indexedPoints .	
	points := (indexed copyFrom: 1 to: 4), (Array with: indexed first) .
	^ Array
		streamContents: [ :s | 
			1 to: points size do: [ :index | 
				index < points size
					ifTrue: [ 
						s nextPut: (
							LineSegment 
								from: (points at: index) to: (points at: index + 1)) ] ] ]
]

{ #category : #accessing }
TwkCross >> splitedCrossSegments [
	^ LineSegment splitedSegments: self crossSegments epsilon: TwkTowerKit epsilon

]

{ #category : #accessing }
TwkCross >> splitedHorizontalSegments [
	^ self splitedCrossSegments select: [ :each | each isHorizontal ]

]

{ #category : #accessing }
TwkCross >> splitedMixedSegments [

	| roundSegs insertSegsMap  |
	
	roundSegs := self roundSegments.
	insertSegsMap := self insertSegmentsMap.	
	roundSegs := roundSegs reject: [ :each | insertSegsMap keys anySatisfy: [ :each2 |  
			each sameStandSegment: each2 ] ].
		
	^ LineSegment 
			splitedSegments: (self crossSegments, roundSegs, (insertSegsMap values flattened)) asSet 
			epsilon: TwkTowerKit epsilon.

]

{ #category : #accessing }
TwkCross >> splitedRoundSegments [
	| splitedCrossSegs |
	splitedCrossSegs := self splitedCrossSegments .
	^ self splitedMixedSegments reject: [ :each | 
		splitedCrossSegs anySatisfy: [ :each2 |  
			each sameStandSegment: each2  ] ]
]

{ #category : #accessing }
TwkCross >> splitedSlantSegments [
	^ self splitedCrossSegments reject: [ :each | each isHorizontal or: [each isVertical] ]

]

{ #category : #accessing }
TwkCross >> splitedVerticalSegments [
	^ self splitedCrossSegments select: [ :each | each isVertical ]

]

{ #category : #accessing }
TwkCross >> testSquare: aBlock [
	squareBlock := aBlock.
]
