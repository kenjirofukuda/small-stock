Class {
	#name : #TwkTrussElement,
	#superclass : #TwkNode,
	#instVars : [
		'number'
	],
	#category : #'TowerKit-Diagram'
}

{ #category : #initialization }
TwkTrussElement >> initialize [
	number := -1.
]

{ #category : #accessing }
TwkTrussElement >> name [
	^ (self topLetter, self number asString)
]

{ #category : #accessing }
TwkTrussElement >> number [
	^ number
	
]

{ #category : #accessing }
TwkTrussElement >> number: anInteger [
	number := anInteger
	
]

{ #category : #printing }
TwkTrussElement >> printOn: aStream [ 
	aStream nextPutAll: self name.

]

{ #category : #accessing }
TwkTrussElement >> topLetter [
	^ self subclassResponsibility
]

{ #category : #accessing }
TwkTrussElement >> world [
	^ self parent
]
