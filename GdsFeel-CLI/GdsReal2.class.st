"
A GdsReal2 is Real number on GDSII.

storage cost: 4byte(2word) 16bit machine

4-byte real:
SEEEEEEE MMMMMMMM MMMMMMMM MMMMMMMM
"
Class {
	#name : #GdsReal2,
	#superclass : #GdsFloating,
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #testing }
GdsReal2 class >> acceptableExpression: aString [
	"TODO: implements minValue maxValue"

	| num |
	(aString matchesRegex: self acceptRegexPattern)
		ifFalse: [ ^ false ].
	num := aString asNumber.
	num ifNil: [ ^ false ].
	^ true
]

{ #category : #accessing }
GdsReal2 class >> mode [
	^ 8
]

{ #category : #accessing }
GdsReal2 class >> storageCost [
	^ 4
]

{ #category : #accessing }
GdsReal2 class >> typeString [
	^ 'REAL2'
]
