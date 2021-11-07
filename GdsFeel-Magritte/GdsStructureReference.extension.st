Extension { #name : #GdsStructureReference }

{ #category : #'*GdsFeel-Magritte' }
GdsStructureReference >> descriptionReferenceName [

	<magritteDescription>
	^ MAStringDescription new
		  label: 'Reference';
		  accessor: #structureName;
		  beReadOnly;
		  priority: 120;
		  yourself
]
