Extension { #name : #Collection }

{ #category : #'*TowerKit-Core' }
Collection >> twkInstance [
	^ self collect: #twkInstance
]

{ #category : #'*TowerKit-Core' }
Collection >> twkJsonObject [
	^ self collect: #twkJsonObject
]
