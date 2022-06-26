Class {
	#name : #GplOpenLib,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplOpenLib class >> methodName [
	^ 'OPENLIB'
]

{ #category : #'as yet unclassified' }
GplOpenLib >> evaluateToken: aToken [
	| arg1 libName |
	(evaluator numArgs: aToken) < 1
		ifTrue: [ ^ self runtimeError: 'MISSING LIBRARY NAME' ].
	arg1 := evaluator popArg asGplValue.
	self mustbeString: arg1.
	libName := arg1 gplString.
	(GdsLibrary exists: libName)
		ifFalse: [ ^ self error: 'LIBRARY NOT FOUND: ' , libName ].
	evaluator console
		ifNil: [ self openDeprecated: libName.
			^ self nullVector ].
	self station openLibraryNamed: libName.
	^ self nullVector
]

{ #category : #'as yet unclassified' }
GplOpenLib >> openDeprecated: libName [
	| clazz |
	clazz := self stationUIClass.
	clazz
		ifNotNil: [ clazz openWithInform: false.
			self station openLibraryNamed: libName ].
	^ self nullVector
]
