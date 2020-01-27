Extension { #name : #Number }

{ #category : #'*TowerKit-STAN' }
Number >> roundedForStan [
	^ self roundTo: TwkTowerKit stanRoundValue.
]
