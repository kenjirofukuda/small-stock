Extension { #name : #Number }

{ #category : #'*TowerKit-Core' }
Number >> adjustOne [
	self asString last = $0 ifTrue: [ ^ self + 1 ].
	^ self
	
]
