Extension { #name : #GdsItemContext }

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsItemContext >> point [
	self elementType: #point.
]

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsItemContext >> putPoint: aPoint [
	self point.
	self ce: aPoint.
	self put.
]
