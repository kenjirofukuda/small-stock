Extension { #name : #TwkCompositBrickTest }

{ #category : #'*TowerKit-STON' }
TwkCompositBrickTest >> testrRestoreFromSton [
	(TwkCompositBrick projectStonFiles first)
		ifNotNil: [ :f |
			(TwkCompositBrick fromStonFile: f) explore.
				 ]
			 
]
