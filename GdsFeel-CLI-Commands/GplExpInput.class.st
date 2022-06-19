Class {
	#name : #GplExpInput,
	#superclass : #GplTextInput,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplExpInput class >> methodName [
	^ 'EXPINPUT'
]

{ #category : #'as yet unclassified' }
GplExpInput >> signalResult [
	| textResult vec |
	textResult := super signalResult.
	textResult = GdsNull instance
		ifTrue: [ ^ GdsNull instance ].
	vec := GdsVector fromLiteral: textResult gplString.
	vec size = 1
		ifTrue: [ ^ vec elements first ].
	^ vec
]
