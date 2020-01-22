Class {
	#name : #GplViewingHandler,
	#superclass : #GplMultiHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplViewingHandler class >> associateArray [
	^{'PAN' -> #pan:  . 'ZOOM' -> #zoom:  . 'FIT' -> #fit: }
]

{ #category : #testing }
GplViewingHandler class >> isFunctionAllowed: aCommandName [
	^false
]

{ #category : #handler }
GplViewingHandler >> fit: aToken [
	self mustStructureOpen.
	self viewport viewFit.
	 ^self nullVector. 
]

{ #category : #handler }
GplViewingHandler >> pan: aToken [
	| arg1 gv1 sv1 |
	self mustStructureOpen.
	arg1 := evaluator popArg asGplValue.
	gv1 := arg1 asVector.
	self mustBeCoordinatable: gv1.
	gv1 size = 2 ifFalse: [^self illigalCoordinate].
	sv1 := gv1 asSmalltalkValue.
	self viewport viewCenter: (sv1 first @ sv1 second).
	 ^self nullVector. 
]

{ #category : #handler }
GplViewingHandler >> zoom: aToken [
	| arg1 gv1 sv1 |
	self mustStructureOpen.
	arg1 := evaluator popArg asGplValue.
	gv1 := arg1 asVector.
	self mustBeCoordinatable: gv1.
	gv1 size = 1 ifFalse: [^self error: 'RELATIVE MAGINIFY MUST SCALAR'].
	sv1 := gv1 asSmalltalkValue first.
	(sv1 = 0.0 or: [sv1 negative])
		 ifTrue: [^self error: 'POSITIVE VALUE BUT: ', sv1 asString].
	self viewport zoom: sv1.
	 ^self nullVector. 
]
