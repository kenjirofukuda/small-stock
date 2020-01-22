Extension { #name : #CollectionValueHolder }

{ #category : #'*GdsFeel-Foundation' }
CollectionValueHolder >> removeAllFoundIn: aCollection [ 
	| result |
	result := value removeAllFoundIn:  aCollection.
	self valueChanged: aCollection.
	^ result
]
