Extension { #name : #Number }

{ #category : #'*GdsFeel-Foundation' }
Number >> asUserFromDBU: aDatabaseUnit [
	| fdbu |
	fdbu := aDatabaseUnit asFloat.
	^ (self * (fdbu reciprocal) * fdbu) rounded / fdbu
]

{ #category : #'*GdsFeel-Foundation' }
Number >> fixNegativeZero [
	(self closeTo: Float negativeZero) ifTrue: [ ^ self abs ].
	^ self 
]
