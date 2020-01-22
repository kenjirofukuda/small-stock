Class {
	#name : #KFJapaneseSJIS,
	#superclass : #KFJapanese,
	#instVars : [
		'map81',
		'map82',
		'map83',
		'map84',
		'map87'
	],
	#classVars : [
		'Default'
	],
	#category : #KFJapanese
}

{ #category : #accessing }
KFJapaneseSJIS class >> default [
	^ Default ifNil: [ Default := self new ]
]

{ #category : #conversion }
KFJapaneseSJIS >> convertRecord: anArray [
	"#('A1F1' '8191' 'EFBFA0' 'FFE0' '2171' '{CantDisplay}' '&#65504;')"

	| key char shisCodePart |
	shisCodePart := (anArray last beginsWith: '*')
		ifTrue: [ anArray last allButFirst ]
		ifFalse: [ anArray second ].
	key := Character
		value: (Integer readFrom: (shisCodePart allButFirst: 2) base: 16).
	char := Character
		value: (Integer readFrom: (anArray at: 4) base: 16).
	^ Array with: key with: char
]

{ #category : #accessing }
KFJapaneseSJIS >> findChar1Code: aChar1Code char2: character2 [
	aChar1Code = 16r81
		ifTrue: [ (self map81 at: character2 ifAbsent: [  ])
				ifNotNil: [ :foundCh | ^ foundCh ] ].
	aChar1Code = 16r82
		ifTrue: [ (self map82 at: character2 ifAbsent: [  ])
				ifNotNil: [ :foundCh | ^ foundCh ] ].
	aChar1Code = 16r83
		ifTrue: [ (self map83 at: character2 ifAbsent: [  ])
				ifNotNil: [ :foundCh | ^ foundCh ] ].
	aChar1Code = 16r84
		ifTrue: [ (self map84 at: character2 ifAbsent: [  ])
				ifNotNil: [ :foundCh | ^ foundCh ] ].
	aChar1Code = 16r87
		ifTrue: [ (self map87 at: character2 ifAbsent: [  ])
				ifNotNil: [ :foundCh | ^ foundCh ] ].
	^ nil
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup81Array [
	"self lookupA3Array"

	^ self lookupArrayBeginsWith: '81'
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup81Map [
	"self lookupA1Map"

	^ self lookupMapFromArray: self lookup81Array
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup82Array [
	"self lookupA3Array"

	^ self lookupArrayBeginsWith: '82'
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup82Map [
	"self lookupA1Map"

	^ self lookupMapFromArray: self lookup82Array
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup83Array [
	"self lookupA3Array"

	^ self lookupArrayBeginsWith: '83'
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup83Map [
	"self lookupA1Map"

	^ self lookupMapFromArray: self lookup83Array
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup84Array [
	"self lookupA3Array"

	^ self lookupArrayBeginsWith: '84'
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup84Map [
	"self lookupA1Map"

	^ self lookupMapFromArray: self lookup84Array
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup87Array [
	"self lookupA3Array"

	^ self lookupArrayBeginsWith: '87'
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookup87Map [
	"self lookupA1Map"

	^ self lookupMapFromArray: self lookup87Array
]

{ #category : #'private - lookup' }
KFJapaneseSJIS >> lookupArrayBeginsWith: aString [
	"self lookupA1Array"

	^ self class source1 lines
		collect: [ :line | 
			[ (line findTokens: ' ') asArray ]
				on: Error
				do: [ :ex | ex return: #() ] ]
		thenSelect: [ :arr | 
			arr notEmpty
				and: [ (arr second beginsWith: aString)
						or: [ arr last beginsWith: '*' , aString ] ] ]
]

{ #category : #accessing }
KFJapaneseSJIS >> map81 [
	^ map81 ifNil: [ map81 := self lookup81Map ]
]

{ #category : #accessing }
KFJapaneseSJIS >> map82 [
	^ map82 ifNil: [ map82 := self lookup82Map ]
]

{ #category : #accessing }
KFJapaneseSJIS >> map83 [
	^ map83 ifNil: [ map83 := self lookup83Map ]
]

{ #category : #accessing }
KFJapaneseSJIS >> map84 [
	^ map84 ifNil: [ map84 := self lookup84Map ]
]

{ #category : #accessing }
KFJapaneseSJIS >> map87 [
	^ map87 ifNil: [ map87 := self lookup87Map ]
]
