Extension { #name : #Collection }

{ #category : #'*GdsFeel-Foundation' }
Collection >> fixNegativeZero [
	^ self collect: [ :each | each fixNegativeZero ]
]
