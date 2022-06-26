Class {
	#name : #GplIota,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #testing }
GplIota class >> isFunctionAllowed [
	^ true
]

{ #category : #accessing }
GplIota class >> methodName [
	^ 'IOTA'
]

{ #category : #handler }
GplIota >> evaluateToken: aToken [
	| v step start end values |
	(evaluator numArgs: aToken) < 1
		ifTrue: [ ^ self runtimeError: 'MISSING ARGUMENT for IOTA' ].
	v := evaluator popArg asGplValue asVector.
	(v size > 3 or: [ v size < 1 ])
		ifTrue: [ ^ self
				runtimeError: 'ILLIGAL ARGUMENT SIZE: {m} or {n} {m} or {n} {step} {m}' ].
	(#('BOOLEAN' 'INTEGER') includes: v typeString)
		ifFalse: [ ^ self runtimeError: 'ILLIGAL NUMERIC INPUT' ].
	step := 1.
	start := 1.
	end := 1.
	v size = 1
		ifTrue: [ end := (v at: 1) asSmalltalkValue ].
	v size = 2
		ifTrue: [ start := (v at: 1) asSmalltalkValue.
			end := (v at: 2) asSmalltalkValue ].
	v size = 3
		ifTrue: [ start := (v at: 1) asSmalltalkValue.
			step := (v at: 2) asSmalltalkValue.
			end := (v at: 3) asSmalltalkValue ].
	values := (start to: end by: step) collect: [ :v1 | v1 ].
	^ GdsVector
		withAll: (values collect: [ :v2 | GdsInteger fromLiteral: v2 asString ])
]
