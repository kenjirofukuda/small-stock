Extension { #name : #GdsElement }

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionKeyNumber [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Key';
		accessor: #keyNumber;
		beReadonly;
		priority: 101;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionOiginX [
	<magritteDescription>
	^ MANumberDescription new
		label: 'X';
		accessor: #originX;
		beReadonly;
		priority: 102;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionOiginY [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Y';
		accessor: #originY;
		beReadonly;
		priority: 103;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsElement >> descriptionType [
	<magritteDescription>
	^ MAStringDescription new
		label: 'Type';
		accessor: #typeString;
		beReadonly;
		priority: 100;
		yourself	
]
