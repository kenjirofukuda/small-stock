Extension { #name : #GdsStructureReference }

{ #category : #'*GdsFeel-Magritte' }
GdsStructureReference >> descriptionReferenceName [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Reference';
		accessor: #structureName;
		beReadonly;
		priority: 120;
		yourself	
]
