Extension { #name : #GdsElement }

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionKeyNumber [

	<magritteDescription>
	^ MANumberDescription new
		  label: 'Key';
		  accessor: #keyNumber;
		  beReadOnly;
		  priority: 101;
		  yourself
]

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionOiginX [

	<magritteDescription>
	^ MANumberDescription new
		  label: 'X';
		  accessor: #originX;
		  beReadOnly;
		  priority: 102;
		  yourself
]

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionOiginY [

	<magritteDescription>
	^ MANumberDescription new
		  label: 'Y';
		  accessor: #originY;
		  beReadOnly;
		  priority: 103;
		  yourself
]

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionType [

	<magritteDescription>
	^ MAStringDescription new
		  label: 'Type';
		  accessor: #typeString;
		  beReadOnly;
		  priority: 100;
		  yourself
]
