Class {
	#name : #GplGridScale,
	#superclass : #GplBiContextHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplGridScale class >> methodName [
	^ 'GSCALE'
]

{ #category : #'as yet unclassified' }
GplGridScale >> functionCall: aToken [
	^ self viewport grid asArray asGdsValue
]

{ #category : #'as yet unclassified' }
GplGridScale >> procedureCall: aToken [
	| gv1 vec smVec |
	self viewport grid.
	gv1 := evaluator popArg asGplValue.
	vec := gv1 asVector.
	smVec := vec asSmalltalkValue.
	(#(1 2 4) includes: smVec size)
		ifFalse: [ ^ self error: 'ILLIGAL ARGUMENT ' ].
	smVec size = 1
		ifTrue: [ self viewport grid scale: smVec first asPoint ].
	smVec size = 2
		ifTrue: [ self viewport grid scale: smVec first @ smVec second ].
	smVec size = 4
		ifTrue: [ self viewport grid
				offset: smVec first @ smVec second;
				scale: smVec third @ smVec fourth ].
	self fullRedraw.
	^ self nullVector
]
