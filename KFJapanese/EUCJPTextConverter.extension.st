Extension { #name : #EUCJPTextConverter }

{ #category : #'*KFJapanese-Extension' }
EUCJPTextConverter >> nextFromStream: aStream [
	| character1 character2 offset value1 value2 nonUnicodeChar result |
	aStream isBinary
		ifTrue: [ ^ aStream basicNext ].
	(character1 := aStream basicNext) ifNil: [ ^ nil ].
	character1 asciiValue <= 127
		ifTrue: [ ^ character1 ].
	(character2 := aStream basicNext) ifNil: [ ^ nil ].
	offset := 16rA1.
	value1 := character1 asciiValue - offset.
	value2 := character2 asciiValue - offset.
	(value1 < 0 or: [ value1 > 93 ])
		ifTrue: [ ^ nil ].
	(value2 < 0 or: [ value2 > 93 ])
		ifTrue: [ ^ nil ].
	result := nil.
	value1 == 0
		ifTrue: [ result := KFJapaneseEUC default a1Map at: character2 ifAbsent: [  ] ].
	result ifNotNil: [ ^ result ].
	value1 == 2
		ifTrue: [ result := KFJapaneseEUC default a3Map at: character2 ifAbsent: [  ] ].
	result ifNotNil: [ ^ result ].
	nonUnicodeChar := Character leadingChar: self leadingChar code: value1 * 94 + value2.
	result := Character codePoint: nonUnicodeChar asUnicode.
	^ result
]
