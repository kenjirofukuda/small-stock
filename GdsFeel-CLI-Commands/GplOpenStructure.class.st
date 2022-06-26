Class {
	#name : #GplOpenStructure,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplOpenStructure class >> methodName [
	^ 'OSTRUCT'
]

{ #category : #handler }
GplOpenStructure >> evaluateToken: aToken [
	| arg1 struct structureName |
	Smalltalk garbageCollect.
	self requireLibraryOpend.
	(evaluator numArgs: aToken) = 0
		ifTrue: [ ^ self error: 'STRUCTURE NAME NOT SPECIFIED' ].
	self station structure
		ifNotNil: [ ^ self
				error: 'STRUCTURE ALREADY OPEND: ' , self station structure name ].
	arg1 := evaluator popArg asGplValue.
	self mustbeString: arg1.
	structureName := arg1 gplString.
	struct := self station library structureNamed: structureName.
	struct
		ifNil: [ ^ self error: 'STRUCTURE NOT FOUND: ' , structureName ].
	self station ostructNames: [ :names | structureName ].
	^ self nullVector
]
