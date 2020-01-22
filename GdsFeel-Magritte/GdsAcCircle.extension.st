Extension { #name : #GdsAcCircle }

{ #category : #'*GdsFeel-Magritte' }
GdsAcCircle >> descriptionRadius [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Radius';
		accessor: #radius;
		beReadonly;
		priority: 140;
		yourself	
]
