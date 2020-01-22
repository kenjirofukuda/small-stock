Class {
	#name : #GplSingleHandler,
	#superclass : #GplHandler,
	#category : #'GdsFeel-CLI-Handler'
}

{ #category : #accessing }
GplSingleHandler class >> commandNames [
	^((self allSubclasses collect: [:clazz | clazz methodName asUppercase])
		reject: [:each | each isEmpty]) asArray
]

{ #category : #accessing }
GplSingleHandler class >> functionNames [
	"self functionNames"
	^((self allSubclasses select: [:clazz | 
			clazz isFunctionAllowed ])
		collect: [:each | each methodName]) asArray
]

{ #category : #accessing }
GplSingleHandler class >> lookupHandlerClass: aCommandName [
	^self allSubclasses detect: [:clazz | clazz methodName sameAs: aCommandName] ifNone: [nil]
	
]

{ #category : #accessing }
GplSingleHandler class >> methodNames [
	^((self allSubclasses collect: [:clazz | clazz methodName asUppercase])
		reject: [:each | each isEmpty]) asArray
]

{ #category : #accessing }
GplSingleHandler class >> procedureNames [
	"self procedureNames"
	^((self allSubclasses select: [:clazz | 
			clazz isFunctionAllowed not])
		collect: [:each | each methodName]) asArray
]
