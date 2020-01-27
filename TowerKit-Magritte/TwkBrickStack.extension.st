Extension { #name : #TwkBrickStack }

{ #category : #'*TowerKit-Magritte' }
TwkBrickStack >> descriptionSpans [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #spans;
		label: '区画群';
		classes: TwkStackItem subclasses;
		ordered: true;
		priority: 40;
		yourself
]
