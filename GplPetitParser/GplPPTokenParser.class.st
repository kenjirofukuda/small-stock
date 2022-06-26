Class {
	#name : #GplPPTokenParser,
	#superclass : #PPTokenParser,
	#category : #'GplPetitParser-Grammar'
}

{ #category : #private }
GplPPTokenParser >> defaultTokenClass [
	^ GplPPToken
]

{ #category : #parsing }
GplPPTokenParser >> parseComments: anArray on: aPPContext [
	| start comments |
	comments := anArray.
	[ [ aPPContext atEnd not and: [ aPPContext peek isSeparator ] ]
		whileTrue: [ aPPContext next ].
	aPPContext peek = $| ]
		whileTrue: [ aPPContext next.
			start := aPPContext position.
			aPPContext upTo: Character cr.
			comments := comments copyWith: (start to: aPPContext position) ].
	^ comments
]

{ #category : #parsing }
GplPPTokenParser >> parseOn: aPPContext [
	| memento comments token |
	memento := aPPContext remember.
	comments := self parseComments: #() on: aPPContext.
	token := super parseOn: aPPContext.
	token isPetitFailure
		ifTrue: [ aPPContext restore: memento.
			^ token ].
	comments := self parseComments: comments on: aPPContext.
	^ token comments: comments
]
