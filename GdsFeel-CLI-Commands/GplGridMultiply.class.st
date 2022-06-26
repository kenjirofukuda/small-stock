Class {
	#name : #GplGridMultiply,
	#superclass : #GplBiContextHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplGridMultiply class >> methodName [
	^ 'GRID'
]

{ #category : #'as yet unclassified' }
GplGridMultiply >> functionCall: aToken [
	^ self viewport grid displayMultiply asInteger asGdsValue
]

{ #category : #'as yet unclassified' }
GplGridMultiply >> procedureCall: aToken [
	| gv1 vec smVec value |
	self viewport grid.
	(evaluator numArgs: aToken) = 0
		ifTrue: [ value := self
				call: 'GRID (EXPINPUT "Enter Grid Multiplier Count: ")' ]
		ifFalse: [ gv1 := evaluator popArg asGplValue.
			vec := gv1 asVector.
			smVec := vec asSmalltalkValue.
			smVec size = 1
				ifFalse: [ ^ self error: 'ILLIGAL ARGUMENT ' ].
			value := smVec first ].
	value fractionPart = 0.0
		ifFalse: [ ^ self error: 'SCALE MUST BE INTEGER VALUE' ].
	self viewport grid displayMultiply: value.
	self fullRedraw.
	^ self nullVector
]
