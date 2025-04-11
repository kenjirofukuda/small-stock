"
A GdsDataVector is GPLII's Vector.

Instance Variables
	values:		<Array<GdsDglType>>

values
	- xxxxx

"
Class {
	#name : 'GdsVector',
	#superclass : 'GdsArray',
	#instVars : [
		'values'
	],
	#category : 'GdsFeel-CLI-Data',
	#package : 'GdsFeel-CLI',
	#tag : 'Data'
}

{ #category : 'instance creation' }
GdsVector class >> fromLiteral: aGplExpr [
	| exprs gValues |
	exprs := aGplExpr findTokens: ' '.
	gValues := exprs collect: [ :each | GdsScalar fromLiteral: each ].
	^ self withAll: gValues
]

{ #category : 'instance creation' }
GdsVector class >> fromSmalltalk: anObject [
	^ self withAll: (anObject collect: [ :each | each asGdsValue ])
]

{ #category : 'printing' }
GdsVector class >> gplStringValues: aCollection [
	^ (aCollection collect: [ :elm | elm gplString ]) joinUsing: ' '
]

{ #category : 'printing' }
GdsVector class >> gplStringValues: aCollection paddLeftWidth: aWidth [
	^ (aCollection collect: [ :elm | elm gplString padLeftTo: aWidth ])
		joinUsing: ' '
]

{ #category : 'printing' }
GdsVector class >> gplStringValues: aCollection paddLeftWidth: aLeftWidth rightWidth: aRightWidth [
	^ (aCollection
		collect: [ :elm | elm gplStringLeftWidth: aLeftWidth rightWidth: aRightWidth ])
		joinUsing: ' '
]

{ #category : 'printing' }
GdsVector class >> gplStringValues: aCollection paddWidth: aWidth [
	^ (aCollection collect: [ :elm | elm gplString padLeftTo: aWidth ])
		joinUsing: ' '
]

{ #category : 'testing' }
GdsVector class >> isAcceptableSmalltalkObject: anObject [
	(anObject isKindOf: Collection)
		ifFalse: [ ^ false ].
	anObject ifEmpty: [ ^ false ].
	^ anObject
		allSatisfy: [ :each | GdsNumber isAcceptableSmalltalkObject: each ]
]

{ #category : 'accessing' }
GdsVector class >> rank [
	^ 1
]

{ #category : 'instance creation' }
GdsVector class >> withAll: aGplValues [
	| modes maxMode upperClazz vec |
	modes := aGplValues collect: [ :gValue | gValue mode ].
	modes asSet size = 1
		ifTrue: [ vec := self new.
			aGplValues do: [ :elm | vec add: elm ].
			^ vec ].
	maxMode := modes max.
	upperClazz := GdsDglType instanciateClasses
		detect: [ :clazz | clazz mode = maxMode ].
	vec := self new.
	aGplValues
		do: [ :elm | vec add: (upperClazz fromLiteral: elm gplString) ].
	^ vec
]

{ #category : 'adding' }
GdsVector >> add: aGdsDataStructure [
	self
		assert: (aGdsDataStructure isKindOf: GdsDataStructure)
		description: 'Only GdsDataStructure'.
	values ifNil: [ values := OrderedCollection new ].
	values add: aGdsDataStructure
]

{ #category : 'convert' }
GdsVector >> asSmalltalkValue [
	^ (self elements collect: [ :each | each asSmalltalkValue copy ])
		asArray
]

{ #category : 'convert' }
GdsVector >> asVector [
	^ self
]

{ #category : 'accessing' }
GdsVector >> at: aInteger [
	^ [ values at: aInteger ]
		on: Error
		do: [ :ex | self runtimeError: 'SUBSCRIPTION OUT OF RANGE' ]
]

{ #category : 'accessing' }
GdsVector >> at: aInteger put: aGplValue [
	values at: aInteger put: aGplValue
]

{ #category : 'accessing' }
GdsVector >> atSubscript: aGdsDataStructure [
	| indexes vec |
	indexes := self indexesOfSubscript: aGdsDataStructure.
	vec := self class withAll: (self indexedValues: indexes).
	^ vec size = 1
		ifTrue: [ vec at: 1 ]
		ifFalse: [ vec ]
]

{ #category : 'accessing' }
GdsVector >> atSubscript: aSubscript put: aGdsValue [
	| subscripts |
	(aSubscript isMemberOf: GdsList)
		ifTrue: [ ^ self notSupportMatrixSubscription ].
	(aGdsValue isKindOf: GdsScalar)
		ifFalse: [ ^ self error: 'CAN''T ASSIGN NON SCALAR VALUE.' ].
	subscripts := aSubscript asVector.
	subscripts elements
		do: [ :each | self at: each asSmalltalkValue put: aGdsValue ].
	^ aGdsValue
]

{ #category : 'accessing' }
GdsVector >> copyFrom: from to: to [
	^ values copyFrom: from to: to
]

{ #category : 'copying' }
GdsVector >> copyValues [
	| newValues |
	newValues := values collect: [ :each | each copy ].
	values := OrderedCollection new.
	values addAll: newValues
]

{ #category : 'accessing' }
GdsVector >> elements [
	^ values asArray
]

{ #category : 'convert' }
GdsVector >> gplString [
	^ String streamContents: [ :s | self printGplOn: s ]
]

{ #category : 'accessing' }
GdsVector >> mode [
	values ifNil: [ ^ GdsNull mode ].
	values ifEmpty: [ ^ GdsNull mode ].
	^ values first mode
]

{ #category : 'printing' }
GdsVector >> printGplOn: aStream [
	aStream nextPutAll: (self class gplStringValues: values)
]

{ #category : 'printing' }
GdsVector >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	self printGplOn: aStream.
	aStream nextPutAll: ')'
]

{ #category : 'accessing' }
GdsVector >> shape [
	^ self size
]

{ #category : 'accessing' }
GdsVector >> size [
	values ifNil: [ ^ 0 ].
	^ values size
]

{ #category : 'accessing' }
GdsVector >> typeString [
	values ifNil: [ ^ GdsNull typeString ].
	values ifEmpty: [ ^ GdsNull typeString ].
	^ values first typeString
]
