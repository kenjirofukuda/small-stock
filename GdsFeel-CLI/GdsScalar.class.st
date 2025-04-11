"
A GdsDataScalar is GPLII's Scalar.

Instance Variables
	stringValue:		<ByteSyting>

stringValue
	- GPLII literal expression.

"
Class {
	#name : 'GdsScalar',
	#superclass : 'GdsArray',
	#instVars : [
		'stringValue'
	],
	#category : 'GdsFeel-CLI-Data',
	#package : 'GdsFeel-CLI',
	#tag : 'Data'
}

{ #category : 'as yet unclassified' }
GdsScalar class >> fromLiteral: aString [
	| clazz |
	clazz := GdsDglType bestClassOfStatement: aString.
	clazz ifNil: [ self syntaxError: 'ILLIGAL LITERAL: ' , aString ].
	^ clazz fromLiteralString: aString
]

{ #category : 'as yet unclassified' }
GdsScalar class >> rank [
	^ 0
]

{ #category : 'as yet unclassified' }
GdsScalar class >> shape [
	^ GdsNull instance
]

{ #category : 'math function' }
GdsScalar >> abs [
	^ self newRealSelector: #abs
]

{ #category : 'private' }
GdsScalar >> applySmalltalkValueSymbol: aSymbol to: aObject [
	| leftValue |
	aObject isScalar not
		ifTrue: [ leftValue := self asVector: aObject size.
			(aObject isKindOf: GdsMatrix)
				ifTrue: [ leftValue := GdsMatrix
						fromGdsVector: leftValue
						row: aObject rowCount
						col: aObject columnCount ].
			^ leftValue perform: aSymbol with: aObject ].
	^ self asFloat
		perform:
			(aSymbol = #%
				ifTrue: [ #/ ]
				ifFalse: [ aSymbol ])
		with: aObject asFloat
]

{ #category : 'private' }
GdsScalar >> applySymbol: aSymbol to: aObject [
	self applySymbolCheck: aSymbol to: aObject.
	^ (self applySmalltalkValueSymbol: aSymbol to: aObject) asGdsValue
]

{ #category : 'math function' }
GdsScalar >> arcTan [
	^ self newRealBlock: [ self asFloat arcTan radiansToDegrees ]
]

{ #category : 'converting' }
GdsScalar >> asFloat [
	^ self asSmalltalkValue asFloat
]

{ #category : 'converting' }
GdsScalar >> asGdsFloating [
	^ GdsReal fromLiteral: self asFloat
]

{ #category : 'converting' }
GdsScalar >> asVector [
	^ self vectorClass withAll: (Array with: self)
]

{ #category : 'converting' }
GdsScalar >> asVector: aSize [
	^ self vectorClass withAll: (Array new: aSize withAll: self)
]

{ #category : 'accessing' }
GdsScalar >> at: aIndex [
	^ self error: 'ILIIGAL ACCESS FOR SCALAR []'
]

{ #category : 'accessing' }
GdsScalar >> atSubscript: aSubscript [
	^ self subscriptCheckForReturn: aSubscript
]

{ #category : 'accessing' }
GdsScalar >> atSubscript: aSubscript put: aGdsValue [
	^ self subscriptCheckForAssign: aSubscript
]

{ #category : 'math function' }
GdsScalar >> ceiling [
	^ self newRealSelector: #ceiling
]

{ #category : 'math function' }
GdsScalar >> cos [
	^ self newRealBlock: [ self asFloat degreesToRadians cos ]
]

{ #category : 'accessing' }
GdsScalar >> elements [
	^ Array with: self
]

{ #category : 'math function' }
GdsScalar >> exp [
	^ self newRealSelector: #exp
]

{ #category : 'math function' }
GdsScalar >> floor [
	^ self newRealSelector: #floor
]

{ #category : 'accessing' }
GdsScalar >> gplValueOfShape [
	^ GdsNull instance
]

{ #category : 'testing' }
GdsScalar >> isScalar [
	^ true
]

{ #category : 'math function' }
GdsScalar >> ln [
	^ self newRealSelector: #ln
]

{ #category : 'testing' }
GdsScalar >> mostCompactValue [
	| smInt |
	self sameAsInteger
		ifTrue: [ smInt := self asSmalltalkValue integerPart asInteger.
			(smInt = 1 or: [ smInt = 0 ])
				ifTrue: [ ^ GdsBoolean fromSmalltalk: smInt ].
			^ GdsInteger fromSmalltalk: smInt ].
	^ self
]

{ #category : 'converting' }
GdsScalar >> negated [
	^ self newRealSelector: #negated
]

{ #category : 'testing' }
GdsScalar >> negative [
	^ self asFloat negative
]

{ #category : 'private' }
GdsScalar >> newIntegerBlock: aBlock [
	^ GdsInteger fromLiteral: aBlock value asInteger
]

{ #category : 'private' }
GdsScalar >> newIntegerSelector: aSelector [
	^ GdsInteger fromLiteral: (self asFloat perform: aSelector) asInteger
]

{ #category : 'private' }
GdsScalar >> newRealBlock: aBlock [
	^ GdsReal new stringValue: aBlock value asFloat
]

{ #category : 'private' }
GdsScalar >> newRealSelector: aSelector [
	^ GdsReal fromLiteral: (self asFloat perform: aSelector) asFloat
]

{ #category : 'math function' }
GdsScalar >> not [
	^ self
		newIntegerBlock: [ self asFloat isZero
				ifTrue: [ -1 ]
				ifFalse: [ 0 ] ]
]

{ #category : 'math function' }
GdsScalar >> pi [
	^ self newRealBlock: [ self asFloat * Float pi ]
]

{ #category : 'printing' }
GdsScalar >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	aStream nextPutAll: self gplString.
	aStream nextPutAll: ')'
]

{ #category : 'converting' }
GdsScalar >> reciprocal [
	^ self newRealSelector: #reciprocal
]

{ #category : 'testing' }
GdsScalar >> sameAsInteger [
	^ self asSmalltalkValue asFloat fractionPart = 0.0
]

{ #category : 'converting' }
GdsScalar >> sign [
	^ self newIntegerSelector: #sign
]

{ #category : 'math function' }
GdsScalar >> sin [
	^ self newRealBlock: [ self asFloat degreesToRadians sin ]
]

{ #category : 'accessing' }
GdsScalar >> size [
	^ 1
]

{ #category : 'testing' }
GdsScalar >> strictlyPositive [
	^ self asFloat strictlyPositive
]

{ #category : 'accessing' }
GdsScalar >> stringValue [
	^ stringValue asString
]

{ #category : 'accessing' }
GdsScalar >> stringValue: aGplExpression [
	stringValue := aGplExpression
]

{ #category : 'accessing' }
GdsScalar >> subscriptCheckFor: aGdsDataStructure [
	^ self runtimeError: 'CAN''T  SUBSCRIPTION ACCESS TO SCALAR VALUE '
]

{ #category : 'math function' }
GdsScalar >> tan [
	^ self newRealBlock: [ self asFloat degreesToRadians tan ]
]
