"
A GdsDglType is DATAGENERAL DATA TYPES.

Instance Variables

"
Class {
	#name : #GdsDglType,
	#superclass : #GdsScalar,
	#classInstVars : [
		'regexPat'
	],
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #testing }
GdsDglType class >> acceptableExpression: aString [
	| num |
	(aString matchesRegex: self acceptRegexPattern)
		ifFalse: [ ^ false ].
	num := (self coreceExpressionAsSmalltalkNumber: aString) asNumber.
	num ifNil: [ ^ false ].
	^ num between: self minValue and: self maxValue
]

{ #category : #private }
GdsDglType class >> bestClassOfStatement: aString [
	| classes |
	classes := (self handledClassesOfStatement: aString) asArray.
	classes ifEmpty: [ ^ nil ].
	classes size = 1
		ifTrue: [ ^ classes last ].
	^ (classes sort: [ :a :b | a storageCost < b storageCost ]) first
]

{ #category : #printing }
GdsDglType class >> displayName [
	^ (self name asString allButFirst: 3) asUppercase
]

{ #category : #'instance creation' }
GdsDglType class >> fromLiteral: aString [
	^ self fromLiteralString: aString
]

{ #category : #private }
GdsDglType class >> handledClassesOfStatement: aString [
	^ self instanciateClasses select: [ :clazz | clazz matches: aString ]
]

{ #category : #initialize }
GdsDglType class >> initialize [
	"self initialize"

	self allSubclasses
		do: [ :clazz | 
			[ clazz initializeRegexPat ]
				on: Error
				do: [  ] ]
]

{ #category : #initialize }
GdsDglType class >> initializeRegexPat [
	regexPat := self acceptRegexPattern asRegex
]

{ #category : #private }
GdsDglType class >> instanciateClasses [
	^ {GdsBoolean.	"GdsCharacter . "
	GdsInteger.
	GdsInteger2.
	GdsReal}
]

{ #category : #testing }
GdsDglType class >> matches: aString [
	^ regexPat matches: aString
]

{ #category : #accessing }
GdsDglType class >> maxValue [
	self subclassResponsibility
]

{ #category : #accessing }
GdsDglType class >> minValue [
	self subclassResponsibility
]

{ #category : #accessing }
GdsDglType class >> precisionRank [
	^ -1
]

{ #category : #accessing }
GdsDglType class >> shape [
	^ #() copy
]

{ #category : #accessing }
GdsDglType class >> storageCost [
	^ 0
]

{ #category : #accessing }
GdsDglType class >> typeString [
	^ self name asString asUppercase allButFirst: 3
]

{ #category : #convert }
GdsDglType >> asSmalltalkValue [
	^ self stringValue asNumber
]

{ #category : #printing }
GdsDglType >> displayName [
	^ self class displayName
]

{ #category : #'as yet unclassified' }
GdsDglType >> maxValue [
	self class maxValue
]

{ #category : #'as yet unclassified' }
GdsDglType >> minValue [
	self class minValue
]

{ #category : #'as yet unclassified' }
GdsDglType >> storageCost [
	^ self class storageCost
]

{ #category : #accessing }
GdsDglType >> typeString [
	^ self class typeString
]
