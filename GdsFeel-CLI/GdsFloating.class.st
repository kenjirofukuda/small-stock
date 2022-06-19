"
A GdsFloating is abstract class for Real number on GDSII.

0		represents: 0.
1.0		represents: 1.
0.1		represents: .1
1.0e-6	represents: 1.0E-6  disallow small capital 'e'

	



"
Class {
	#name : #GdsFloating,
	#superclass : #GdsNumber,
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #accessing }
GdsFloating class >> acceptRegexPattern [
	"'(\+|-)?([0-9]+\.?[0-9]*|\.[0-9]+)([eE](\+|-)?[0-9]+)?'"

	"stnard"

	"GPL disallow lowercase e
	OK: 1E6
	OK  1E-6
	NG  1E+6  -> invalid token #('1E' '+' '6')
	"

	^ '(-)?([0-9]+\.?[0-9]*|\.[0-9]+)([E](-)?[0-9]+)?'
]

{ #category : #test }
GdsFloating class >> coreceExpressionAsSmalltalkNumber: anGplExpression [
	((anGplExpression beginsWith: '.')
		or: [ anGplExpression beginsWith: '-.' ])
		ifTrue: [ | items all |
			all := OrderedCollection new.
			items := '.' split: anGplExpression.
			all add: '0'.
			all addAll: items allButFirst.
			^ items first , ('.' join: all) ].
	(anGplExpression endsWith: '.')
		ifTrue: [ ^ anGplExpression , '0' ].
	^ anGplExpression
]

{ #category : #'instance creation' }
GdsFloating class >> fromSmalltalk: aObject [
	^ GdsReal new stringValue: aObject asString
]

{ #category : #test }
GdsFloating class >> isAcceptableSmalltalkObject: anObject [
	^ anObject isNumber and: [ anObject isKindOf: Float ]
]

{ #category : #accessing }
GdsFloating class >> maxValue [
	^ 7.24e75
]

{ #category : #accessing }
GdsFloating class >> minValue [
	^ -7.24e75
]

{ #category : #accessing }
GdsFloating class >> mode [
	^ 3
]

{ #category : #convert }
GdsFloating >> asSmalltalkValue [
	^ self stringValue asLowercase asNumber asFloat
]

{ #category : #convert }
GdsFloating >> gplString [
	| expr |
	expr := super gplString.
	(expr endsWith: '.0')
		ifTrue: [ ^ expr allButLast: 1 ].
	(expr beginsWith: '-0.')
		ifTrue: [ ^ '-.' , (expr allButFirst: 3) ].
	(expr beginsWith: '0.')
		ifTrue: [ ^ '.' , (expr allButFirst: 2) ].
	^ expr asUppercase
]

{ #category : #convert }
GdsFloating >> gplStringLeftWidth: aLeftWidth rightWidth: aRightWidth [
	| gs items |
	gs := self gplString.
	items := {(gs copyFrom: 1 to: (gs indexOf: $.) - 1).
	(gs copyFrom: (gs indexOf: $.) + 1 to: gs size)}.
	^ String
		streamContents: [ :s | 
			s nextPutAll: (items first padLeftTo: aLeftWidth).
			s nextPut: $..
			s nextPutAll: (items second padRightTo: aRightWidth) ]
]
