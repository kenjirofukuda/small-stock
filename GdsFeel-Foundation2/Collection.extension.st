Extension { #name : #Collection }

{ #category : #'*GdsFeel-Foundation2' }
Collection >> fixNegativeZero [

	^ self collect: [ :each | each fixNegativeZero ]
]
