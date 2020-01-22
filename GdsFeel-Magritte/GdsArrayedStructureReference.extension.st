Extension { #name : #GdsArrayedStructureReference }

{ #category : #'*GdsFeel-Magritte' }
GdsArrayedStructureReference >> descriptionColumnCount [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Columns';
		accessor: #columnCount;
		beReadonly;
		priority: 131;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsArrayedStructureReference >> descriptionColumnStep [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Column step';
		accessor: #xStep;
		beReadonly;
		priority: 133;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsArrayedStructureReference >> descriptionRowCount [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Rows';
		accessor: #rowCount;
		beReadonly;
		priority: 130;
		yourself	
]

{ #category : #'*GdsFeel-Magritte' }
GdsArrayedStructureReference >> descriptionRowStep [
	<magritteDescription>
	^ MANumberDescription new
		label: 'Row step';
		accessor: #yStep;
		beReadonly;
		priority: 132;
		yourself	
]
