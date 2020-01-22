Class {
	#name : #GplMultiHandler,
	#superclass : #GplHandler,
	#category : #'GdsFeel-CLI-Handler'
}

{ #category : #accessing }
GplMultiHandler class >> associateArray [
	^self subclassResponsibility .
	
]

{ #category : #accessing }
GplMultiHandler class >> commandNames [
	^ Array streamContents: [ :s |
		self allSubclasses do: [:clazz |
			clazz methodNames do: [:mname |
				s nextPut: mname asUppercase]]]

]

{ #category : #accessing }
GplMultiHandler class >> functionNames [
	"self functionNames"
	^ Array streamContents: [ :s |
		self allSubclasses do: [:clazz | 
			clazz methodNames do: [:each | 
				(clazz isFunctionAllowed: each)
					ifTrue: [s nextPut: each]]]]
]

{ #category : #testing }
GplMultiHandler class >> isFunctionAllowed: aCommandName [
	self subclassResponsibility 
]

{ #category : #private }
GplMultiHandler class >> lookupHandlerClass: aCommandName [
	^self allSubclasses
		detect: [:clazz | 
			clazz methodNames
				anySatisfy: [:each | each sameAs: aCommandName]] ifNone: [nil]
	
]

{ #category : #accessing }
GplMultiHandler class >> methodNames [
	^self associateArray collect: [:each | each key ]
]

{ #category : #accessing }
GplMultiHandler class >> procedureNames [
	"self procedureNames"
	^ Array streamContents: [ :s |
		self allSubclasses do: [:clazz | 
			clazz methodNames do: [:each | 
				(clazz isFunctionAllowed: each)
					ifFalse: [s nextPut: each] ] ] ]
]

{ #category : #private }
GplMultiHandler class >> selectorForMethodName: aCommandName [
	^(self selectorMap at: aCommandName asUppercase)
]

{ #category : #private }
GplMultiHandler class >> selectorMap [
	^Dictionary newFrom: self associateArray .
	
]

{ #category : #handler }
GplMultiHandler >> evaluateToken: aToken [
	| selector |
	selector := self class selectorForMethodName: aToken fragment.
	^self perform: selector with: aToken
]
