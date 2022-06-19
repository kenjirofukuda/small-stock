"
A GdsNull is empty vector.

instance represents """"
but not a character vector.

like as lisp's empty list.

TYPEOF """"
=> NULL

RANK """"
=> 1  
is a vector. not sclar

"
Class {
	#name : #GdsNull,
	#superclass : #GdsVector,
	#classVars : [
		'Singleton'
	],
	#category : #'GdsFeel-CLI-Data'
}

{ #category : #accessing }
GdsNull class >> acceptRegexPattern [
	^ '""'
]

{ #category : #accessing }
GdsNull class >> fromLiteral: aString [
	(self acceptableExpression: aString asString)
		ifFalse: [ self syntaxError: 'ILLIGAL LITERAL FORMAT' ].
	^ self instance
]

{ #category : #'instance creation' }
GdsNull class >> fromSmalltalk: aObject [
	^ GdsNull instance
]

{ #category : #accessing }
GdsNull class >> instance [
	Singleton ifNil: [ Singleton := GdsNull new ].
	^ Singleton
]

{ #category : #test }
GdsNull class >> isAcceptableSmalltalkObject: anObject [
	(anObject isKindOf: Collection)
		ifFalse: [ ^ false ].
	^ anObject isEmpty
]

{ #category : #accessing }
GdsNull class >> mode [
	^ 5
]

{ #category : #accessing }
GdsNull class >> shape [
	^ #()
]

{ #category : #accessing }
GdsNull class >> typeString [
	^ 'NULL'
]

{ #category : #accessing }
GdsNull >> applySymbol: aSymbol to: aObject [
	^ self illigalDataMode
]

{ #category : #convert }
GdsNull >> asSmalltalkValue [
	^ #() copy
]

{ #category : #accessing }
GdsNull >> atSubscript: aGdsDataStructure [
	^ self runtimeError: 'ILLIGAL ACCESS FOR NULL VECTOR []'
]

{ #category : #copying }
GdsNull >> copy [
	^ self
]

{ #category : #convert }
GdsNull >> gplSourceString [
	^ '""'
]

{ #category : #convert }
GdsNull >> gplString [
	^ ''
]

{ #category : #testing }
GdsNull >> isNullVector [
	^ true
]

{ #category : #printing }
GdsNull >> printOn: aStream [
	aStream nextPutAll: 'a GdsNull'
]

{ #category : #testing }
GdsNull >> sameAsInteger [
	^ false
]

{ #category : #accessing }
GdsNull >> shape [
	^ #() copy
]

{ #category : #accessing }
GdsNull >> size [
	^ 0
]
