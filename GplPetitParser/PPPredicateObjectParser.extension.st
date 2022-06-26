Extension { #name : #PPPredicateObjectParser }

{ #category : #'*GplPetitParser-extension' }
PPPredicateObjectParser classSide >> octalDigit [
	^ self chars: '01234567' message: '$0 to $7 expected'
]

{ #category : #'*GplPetitParser-extension' }
PPPredicateObjectParser classSide >> uppercaseLetter [
	^ self
		chars: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
		message: '$A to $Z expected'
]
