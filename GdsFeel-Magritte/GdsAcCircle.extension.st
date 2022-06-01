Extension { #name : #GdsAcCircle }

{ #category : #'*GdsFeel-Magritte' }
GdsAcCircle >> descriptionRadius [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Radius';
		accessor: #radius;
		beReadOnly;
		priority: 140;
		yourself	
]
