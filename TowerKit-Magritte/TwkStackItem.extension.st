Extension { #name : #TwkStackItem }

{ #category : #'*TowerKit-Magritte' }
TwkStackItem >> descriptionPrintString [
	"<magritteDescription>"
	^ MAStringDescription new
		accessor: #printString;
		priority: 10;
		yourself
]

{ #category : #'*TowerKit-Magritte' }
TwkStackItem >> descriptionTypeSymbol [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #typeSymbol;
		priority: 10;
		beReadonly;
		yourself
]
