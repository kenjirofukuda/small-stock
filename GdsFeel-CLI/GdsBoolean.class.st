"
A GdsBoolean is Boolean value on GDSII.

storage cost: 1byte

1 -> TRUE
0 -> FLASE
TRUE -> TRUE
FALSE -> FALSE

Instance Variables

"
Class {
	#name : #GdsBoolean,
	#superclass : #GdsNumber,
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #accessing }
GdsBoolean class >> acceptRegexPattern [
	^'[01]|TRUE|FALSE'
]

{ #category : #test }
GdsBoolean class >> coreceExpressionAsSmalltalkNumber: anGplExpression [
	anGplExpression = 'TRUE' ifTrue: [^'1'].
	anGplExpression = 'FALSE' ifTrue: [^'0'].
	^anGplExpression
]

{ #category : #'instance creation' }
GdsBoolean class >> fromSmalltalk: aObject [
	aObject = true ifTrue: [ ^self new stringValue: '1'].
	aObject = false ifTrue: [ ^self new stringValue: '0'].
	^self new stringValue: aObject asString.
]

{ #category : #test }
GdsBoolean class >> isAcceptableSmalltalkObject: anObject [
	(anObject isKindOf: Boolean) ifTrue: [^true].
	^anObject isInteger and: [anObject  = 1 or: [anObject = 0]].
]

{ #category : #accessing }
GdsBoolean class >> maxValue [
	^1
]

{ #category : #accessing }
GdsBoolean class >> minValue [
	^0
]

{ #category : #accessing }
GdsBoolean class >> mode [
	^1
]

{ #category : #accessing }
GdsBoolean class >> precisionRank [
	^1
]

{ #category : #accessing }
GdsBoolean class >> storageCost [
	^ 1
]

{ #category : #accessing }
GdsBoolean class >> typeString [
	^'LOGICAL'
]

{ #category : #convert }
GdsBoolean >> asSmalltalkValue [
	self stringValue = 'TRUE'
		ifTrue: [^1].
	self stringValue = 'FALSE'
		ifTrue: [^0].
	^super asSmalltalkValue 	
		
]
