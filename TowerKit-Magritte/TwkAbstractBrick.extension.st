Extension { #name : #TwkAbstractBrick }

{ #category : #'*TowerKit-Magritte' }
TwkAbstractBrick >> descriptionFaces [
	<nagritteDescription>
	^ MAToManyRelationDescription new
		priority: 100;
		label: '面';
		accessor: #faces;		
		classes: (Array with: TwkFace);
		"beReadonly;"
		yourself.
]
