Class {
	#name : #GplCustomHandler,
	#superclass : #GplHandler,
	#category : #'GdsFeel-CLI-Handler'
}

{ #category : #'as yet unclassified' }
GplCustomHandler class >> commandNames [
	"GplCustomHandler commandNames explore."

	^ self
		flattendArray:
			(self allSubclasses
				collect: [ :clazz | clazz handledSpecs collect: [ :spec | spec name ] ])
]

{ #category : #'as yet unclassified' }
GplCustomHandler class >> handledSpecs [
	^ #()
]

{ #category : #'as yet unclassified' }
GplCustomHandler class >> isFunctionAllowed: aCommandName [
	^ (self handledSpecs
		detect:
			[ :spec | (spec name sameAs: aCommandName) and: [ spec isFunctionAllowed ] ]
		ifNone: [  ]) notNil
]

{ #category : #'as yet unclassified' }
GplCustomHandler class >> lookupHandlerClass: aCommandName [
	^ self allSubclasses
		detect: [ :clazz | 
			(clazz handledSpecs
				detect: [ :spec | spec name sameAs: aCommandName ]
				ifNone: [  ]) notNil ]
		ifNone: [  ]
]

{ #category : #'as yet unclassified' }
GplCustomHandler >> argumentType: aToken [
	(evaluator numArgs: aToken) = 1
		ifTrue: [ ^ #monadic ].
	(evaluator numArgs: aToken) = 2
		ifTrue: [ ^ #dyadic ].
	^ #niladic
]

{ #category : #'as yet unclassified' }
GplCustomHandler >> evaluateToken: aToken [
	^ self biContextCall: aToken
]

{ #category : #'as yet unclassified' }
GplCustomHandler >> functionCall: aToken [
	^ self methodCall: aToken methodType: #function
]

{ #category : #'as yet unclassified' }
GplCustomHandler >> methodCall: aToken methodType: methodType [
	| sel |
	sel := GplCommandSpec
		selectorWithArgType: (self argumentType: aToken)
		methodType: methodType
		methodName: aToken fragment.
	(self respondsTo: sel)
		ifFalse: [ ^ self
				error:
					'TODO: developer must implement: ' , self class printString , '>>'
						, sel printString ].
	^ self perform: sel with: aToken
]

{ #category : #'as yet unclassified' }
GplCustomHandler >> procedureCall: aToken [
	^ self methodCall: aToken methodType: #procedure
]
