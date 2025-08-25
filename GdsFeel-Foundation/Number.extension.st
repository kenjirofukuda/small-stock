Extension { #name : #Number }

{ #category : #'*GdsFeel-Foundation' }
Number >> fixNegativeZero [
	(self closeTo: Float negativeZero)
		ifTrue: [ ^ self abs ].
	^ self
]
