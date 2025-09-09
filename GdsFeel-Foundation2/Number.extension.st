Extension { #name : #Number }

{ #category : #'*GdsFeel-Foundation2' }
Number >> fixNegativeZero [
	(self closeTo: Float negativeZero)
		ifTrue: [ ^ self abs ].
	^ self
]
