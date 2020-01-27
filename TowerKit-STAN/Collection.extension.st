Extension { #name : #Collection }

{ #category : #'*TowerKit-STAN' }
Collection >> roundedForStan [
	^ self collect: [:a | a roundedForStan ]
]
