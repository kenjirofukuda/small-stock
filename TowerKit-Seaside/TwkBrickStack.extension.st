Extension { #name : #TwkBrickStack }

{ #category : #'*TowerKit-Seaside' }
TwkBrickStack >> outFile [
	^ (TwkTower defaultFolder / 'tower.json') asFileReference
]
