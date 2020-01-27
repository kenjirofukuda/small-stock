Class {
	#name : #TwkStan,
	#superclass : #Object,
	#category : #'TowerKit-STAN'
}

{ #category : #'as yet unclassified' }
TwkStan class >> fillNumbers: aStanSegmentCollection start: aNumber [
	| number |
	number := aNumber.
	aStanSegmentCollection do: [ :stanSegment |
		stanSegment number < 0
			ifTrue: [ 
				stanSegment number: number.
				number := number + 1 ] ].
	^ aStanSegmentCollection

]
