Class {
	#name : #GplSetView,
	#superclass : #GplBiContextHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplSetView class >> methodName [
	^'SETVIEW'
]

{ #category : #handler }
GplSetView >> functionCall: aToken [
	^GdsMatrix 
		fromOrigin:  self viewport  worldViewOrigin
		corner: self viewport  worldViewCorner
]

{ #category : #handler }
GplSetView >> procedureCall: aToken [
	| gv1 vec smVec worldBounds |
	gv1 := evaluator popArg asGplValue.
	vec := gv1 asVector.
	vec size = 4 ifFalse: [^self illigalCoordinate ].
	smVec := vec asSmalltalkValue.
	worldBounds := 
		GeometryUtils lookupDataBounds: {(smVec first @smVec second) . (smVec third @smVec fourth)}.
	worldBounds extent isZero ifTrue: [^self illigalCoordinate ].
	self viewport viewBounds: worldBounds.
	^self nullVector
]
