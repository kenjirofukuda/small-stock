"
A GdsDataStructure is abstract class for GPLII core data.

Instance Variables


"
Class {
	#name : #GdsDataStructure,
	#superclass : #GdsObject,
	#category : #'GdsFeel-CLI-Data'
}

{ #category : #accessing }
GdsDataStructure class >> acceptRegexPattern [
	self subclassResponsibility
]

{ #category : #test }
GdsDataStructure class >> acceptableExpression: aString [
	^ aString matchesRegex: self acceptRegexPattern
]

{ #category : #'instance creation' }
GdsDataStructure class >> cantConvertSmalltalkObject: anObject [
	^ self
		error: 'CAN''T CREATE FROM Smalltalk Object: ' , anObject printString
]

{ #category : #test }
GdsDataStructure class >> coreceExpressionAsSmalltalkNumber: anGplExpression [
	^ anGplExpression
]

{ #category : #'instance creation' }
GdsDataStructure class >> fromLiteral: aString [
	^ self fromLiteralString: aString
]

{ #category : #'instance creation' }
GdsDataStructure class >> fromLiteralString: aString [
	(self acceptableExpression: aString asString)
		ifFalse: [ self syntaxError: 'ILLIGAL LITERAL FORMAT' ].
	^ self new
		stringValue: (self coreceExpressionAsSmalltalkNumber: aString asString)
]

{ #category : #'instance creation' }
GdsDataStructure class >> fromSmalltalk: aObject [
	^ self subclassResponsibility
]

{ #category : #'instance creation' }
GdsDataStructure class >> fromSmalltalkObject: anObject [
	(self isAcceptableSmalltalkObject: anObject)
		ifFalse: [ ^ self cantConvertSmalltalkObject: anObject ].
	^ self fromSmalltalk: anObject
]

{ #category : #test }
GdsDataStructure class >> isAcceptableSmalltalkObject: anObject [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdsDataStructure class >> mode [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdsDataStructure class >> rank [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdsDataStructure class >> shape [
	self subclassResponsibility
]

{ #category : #arithmetic }
GdsDataStructure >> % aObject [
	^ self applySymbol: #% to: aObject
]

{ #category : #arithmetic }
GdsDataStructure >> * aObject [
	^ self applySymbol: #* to: aObject
]

{ #category : #arithmetic }
GdsDataStructure >> + aObject [
	| v |
	"self halt."
	v := self applySymbol: #+ to: aObject.
	^ v
]

{ #category : #arithmetic }
GdsDataStructure >> - aObject [
	^ self applySymbol: #- to: aObject
]

{ #category : #arithmetic }
GdsDataStructure >> = aObject [
	(aObject isKindOf: GdsDataStructure)
		ifFalse: [ ^ false ].
	self size = aObject size
		ifFalse: [ ^ false ].
	self mode = aObject mode
		ifFalse: [ ^ false ].
	^ self asSmalltalkValue = aObject asSmalltalkValue
]

{ #category : #arithmetic }
GdsDataStructure >> applySymbol: aSymbol to: aObject [
	^ self illigalDataMode
]

{ #category : #private }
GdsDataStructure >> applySymbolCheck: aSymbol to: aObject [
	(#(+ - * %) includes: aSymbol)
		ifFalse: [ self error: 'ILLIGAL ARITHMETIC OPERATOR' ].
	self isCharVector
		ifTrue: [ ^ self illigalDataMode ].
	(self isKindOf: GdsNull)
		ifTrue: [ ^ self illigalDataMode ].
	aObject isCharVector
		ifTrue: [ ^ self illigalDataMode ].
	(aObject isKindOf: GdsNull)
		ifTrue: [ ^ self illigalDataMode ]
]

{ #category : #convert }
GdsDataStructure >> asGdsFloating [
	^ self subclassResponsibility
]

{ #category : #convert }
GdsDataStructure >> asGdsValue [
	^ self
]

{ #category : #convert }
GdsDataStructure >> asGplValue [
	^ self
]

{ #category : #convert }
GdsDataStructure >> asScalar [
	self isScalar
		ifTrue: [ ^ self ].
	self size = 1
		ifFalse: [ ^ self error: 'CANT CONVERT TO SCALAR' ].
	^ self at: 1
]

{ #category : #convert }
GdsDataStructure >> asSmalltalkValue [
	^ self subclassResponsibility
]

{ #category : #convert }
GdsDataStructure >> asVector [
	^ self vectorClass withAll: self elements
]

{ #category : #convert }
GdsDataStructure >> asVector: aSize [
	^ self vectorClass withAll: self elements
]

{ #category : #accessing }
GdsDataStructure >> at: aIndex [
	^ self error: 'ILIIGAL ACCESS FOR SCALAR []'
]

{ #category : #accessing }
GdsDataStructure >> atSubscript: aGdsDataStructure [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdsDataStructure >> atSubscript: aGdsDataStructure put: aGdsValue [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdsDataStructure >> atSubscriptWithCheck: aGdsDataStructure [
	| subscript |
	subscript := self subscriptCheckForReturn: aGdsDataStructure.
	^ self atSubscript: subscript
]

{ #category : #accessing }
GdsDataStructure >> atSubscriptWithCheck: aGdsDataStructure put: aGdsValue [
	| subscript |
	subscript := self subscriptCheckForAssign: aGdsDataStructure.
	^ self atSubscript: subscript put: aGdsValue
]

{ #category : #copying }
GdsDataStructure >> copy [
	^ super copy copyValues
]

{ #category : #copying }
GdsDataStructure >> copyValues [
	
]

{ #category : #accessing }
GdsDataStructure >> elements [
	^ self subclassResponsibility
]

{ #category : #convert }
GdsDataStructure >> gplSourceString [
	^ self gplString
]

{ #category : #convert }
GdsDataStructure >> gplString [
	^ self asSmalltalkValue asString
]

{ #category : #convert }
GdsDataStructure >> gplValueOfLength [
	^ GdsInteger fromLiteral: self length
]

{ #category : #convert }
GdsDataStructure >> gplValueOfRank [
	^ GdsInteger fromLiteral: self rank
]

{ #category : #convert }
GdsDataStructure >> gplValueOfShape [
	^ GdsInteger fromLiteral: self shape
]

{ #category : #convert }
GdsDataStructure >> gplValueOfSize [
	^ GdsInteger fromLiteral: self size
]

{ #category : #convert }
GdsDataStructure >> gplValueOfTypeof [
	^ GdsString fromLiteral: '"' , self typeString , '"'
]

{ #category : #'utility for subclass' }
GdsDataStructure >> illigalDataMode [
	^ self runtimeError: 'ILLIGAL DATA MODE'
]

{ #category : #'utility for subclass' }
GdsDataStructure >> indexedValues: aIndexArray [
	^ (aIndexArray collect: [ :each | self at: each ]) asArray
]

{ #category : #'utility for subclass' }
GdsDataStructure >> indexesOfSubscript: aGdsDataStructure [
	^ aGdsDataStructure asVector elements
		collect: [ :each | each asSmalltalkValue ]
]

{ #category : #testing }
GdsDataStructure >> isCharVector [
	^ false
]

{ #category : #testing }
GdsDataStructure >> isList [
	^ false
]

{ #category : #testing }
GdsDataStructure >> isNullVector [
	^ false
]

{ #category : #testing }
GdsDataStructure >> isScalar [
	^ false
]

{ #category : #accessing }
GdsDataStructure >> length [
	^ 1
]

{ #category : #accessing }
GdsDataStructure >> mode [
	^ self class mode
]

{ #category : #convert }
GdsDataStructure >> mostCompactValue [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdsDataStructure >> nonIntegralValue [
	^ self runtimeError: 'ILLIGAL SUBSCRIPT ACCESS. NON INTEGRAL VALUE'
]

{ #category : #private }
GdsDataStructure >> notSupportMatrixSubscription [
	^ self
		error: 'Sorry: current implement not support Matrix subscription'
]

{ #category : #accessing }
GdsDataStructure >> rank [
	^ self class rank
]

{ #category : #testing }
GdsDataStructure >> sameAsInteger [
	^ false
]

{ #category : #accessing }
GdsDataStructure >> shape [
	^ self class shape
]

{ #category : #accessing }
GdsDataStructure >> size [
	self subclassresponsibility
]

{ #category : #accessing }
GdsDataStructure >> subscriptCheckFor: aSubscript [
	(self isMemberOf: GdsMatrix)
		ifFalse: [ aSubscript = GdsNull instance
				ifTrue: [ ^ self nonIntegralValue ] ].
	aSubscript isCharVector
		ifTrue: [ ^ self nonIntegralValue ].
	(aSubscript isMemberOf: GdsMatrix)
		ifTrue: [ ^ self nonIntegralValue ].
	((aSubscript isMemberOf: GdsVector)
		or: [ aSubscript isKindOf: GdsScalar ])
		ifTrue: [ aSubscript sameAsInteger
				ifFalse: [ ^ self nonIntegralValue ] ].
	^ aSubscript
]

{ #category : #accessing }
GdsDataStructure >> subscriptCheckForAssign: aSubscript [
	^ self subscriptCheckFor: aSubscript
]

{ #category : #accessing }
GdsDataStructure >> subscriptCheckForReturn: aSubscript [
	^ self subscriptCheckFor: aSubscript
]

{ #category : #accessing }
GdsDataStructure >> typeString [
	^ self subclassResponsibility
]

{ #category : #accessing }
GdsDataStructure >> vectorClass [
	^ self typeString = 'CHAR'
		ifTrue: [ GdsString ]
		ifFalse: [ GdsVector ]
]
