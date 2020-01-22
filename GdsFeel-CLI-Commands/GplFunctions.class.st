Class {
	#name : #GplFunctions,
	#superclass : #GplMultiHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplFunctions class >> associateArray [
	^{
	'IDKEYS' -> #idKeys: .
	'KEYCE' -> #keyCe: .
	'CEKEY' -> #ceKey: }
]

{ #category : #testing }
GplFunctions class >> isFunctionAllowed [
	^true
]

{ #category : #testing }
GplFunctions class >> isFunctionAllowed: aCommandName [
	^true
]

{ #category : #handler }
GplFunctions >> ceKey: aToken [
	| gv1 smVec element smPoint |
	self mustStructureOpen.
	gv1 := evaluator popArg asGplValue asVector.
	smVec := gv1 asSmalltalkValue.
	smVec size = 2 ifFalse: [^self illigalCoordinate].
	smPoint := smVec first@smVec second.
	element := self structure findNearestElementByPoint: smPoint.
	^element
		ifNil: [self nullVector]
		ifNotNil: [element keyNumber asGdsValue ]
	
]

{ #category : #handler }
GplFunctions >> idKeys: aToken [
	self mustStructureOpen.
	^(self structure idSelection keyNumbers) asArray asGdsValue. 

]

{ #category : #handler }
GplFunctions >> keyCe: aToken [
	| gv1 smVec element smPoint |
	self mustStructureOpen.
	gv1 := evaluator popArg asGplValue asVector.
	smVec := gv1 asSmalltalkValue.
	smVec size = 1 ifFalse: [^self error: 'ARGUMENT MUST KEYNUMBER ONLY'].
	element := self findElementByKeyNumber: smVec first.
	smPoint := element xy.
	^{smPoint x . smPoint y } asGdsValue.
]
