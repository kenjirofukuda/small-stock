Extension { #name : #TwkFace }

{ #category : #'*TowerKit-Magritte' }
TwkFace >> descriptionDirectionBrickStack [
	<magritteDescription>
	^ MAToOneRelationDescription new
		priority: 60;
		label: '区画';
		accessor: #brickStack;
		comment: '区画';
		classes: { TwkBrickStack };		
		yourself	
]

{ #category : #'*TowerKit-Magritte' }
TwkFace >> descriptionDirectionString [
	<magritteDescription>
	^ MAStringDescription new
		priority: 50;
		label: '向き';
		accessor: #directionString;
		comment: '向き';
		beReadonly;
		yourself	
]
