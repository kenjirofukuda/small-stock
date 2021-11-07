Extension { #name : #GdsPrimitiveElement }

{ #category : #'*GdsFeel-Magritte' }
GdsPrimitiveElement >> descriptionLayerNumber [

	<magritteDescription>
	^ MANumberDescription new
		  label: 'Layer';
		  accessor: #layerNumber;
		  beReadOnly;
		  priority: 112;
		  yourself
]
