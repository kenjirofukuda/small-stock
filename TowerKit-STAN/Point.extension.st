Extension { #name : #Point }

{ #category : #'*TowerKit-STAN' }
Point >> roundedForStan [
	^ self roundTo: TwkTowerKit stanRoundValue 
]
