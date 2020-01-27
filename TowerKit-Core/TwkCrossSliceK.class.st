Class {
	#name : #TwkCrossSliceK,
	#superclass : #TwkCross,
	#category : #'TowerKit-Core'
}

{ #category : #accessing }
TwkCrossSliceK >> crossSegments [	
	| indexed   |
	indexed := self indexedPoints .	
	^ #( #(14 15) #(16 17) #(18 19) #(20 21))
		collect: [ :each |
			LineSegment from: (indexed at: each first) to: (indexed at: each second) 
			 ]	
		
"
 4 21  14  1

20         15

19         16

 3 18  17  2

"	
]

{ #category : #accessing }
TwkCrossSliceK >> indexedPoints [
	| indexed len unitPoints |
	indexed := super indexedPoints .	
	self assert: [ indexed size = 13 ].
	unitPoints := OrderedCollection new.	
	unitPoints addAll: indexed.		
	len := self k2d1.	
	unitPoints add: (indexed at: 1) + (len negated @ 0).		"14"
	unitPoints add: (indexed at: 1) + (0 @ len negated).		"15"
		
	unitPoints add: (indexed at: 2) + (0 @ len).				"16"
	unitPoints add: (indexed at: 2) + (len negated @ 0).		"17"	

	unitPoints add: (indexed at: 3) + (len @ 0).				"18"
	unitPoints add: (indexed at: 3) + (0 @ len).				"19"

	unitPoints add: (indexed at: 4) + (0 @ len negated).		"18"
	unitPoints add: (indexed at: 4) + (len @ 0).				"19"
	self assert: [ unitPoints size = 21 ].
	^ unitPoints
		
"
 4 21  14  1

20         15

19         16

 3 18  17  2

"	
]

{ #category : #accessing }
TwkCrossSliceK >> k2d1 [
	| points |
	points := self sourceDepthSpan wallCross indexedPoints.
	^ (points at: 12) dist: (points at: 5) 
	
]

{ #category : #accessing }
TwkCrossSliceK >> roundSegments [	
	| indexed   |
	indexed := self indexedPoints .	
	^ #( #(14 1) #(1 15) #(16 2) #(2 17) #(18 3) #(3 19) #(20 4) (4 21) )
		collect: [ :each |
			LineSegment from: (indexed at: each first) to: (indexed at: each second) 
			 ]	
		
"
 4 21  14  1

20         15

19         16

 3 18  17  2

"	
]

{ #category : #accessing }
TwkCrossSliceK >> sourceDepthSpan [
	^ self parent valueOfProperty: #splited
]
