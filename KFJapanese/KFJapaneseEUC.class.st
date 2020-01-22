Class {
	#name : #KFJapaneseEUC,
	#superclass : #KFJapanese,
	#instVars : [
		'a1Map',
		'a3Map'
	],
	#classVars : [
		'Default'
	],
	#category : #KFJapanese
}

{ #category : #accessing }
KFJapaneseEUC class >> default [
	^ Default ifNil: [ Default := self new ]
]

{ #category : #accessing }
KFJapaneseEUC class >> exampleA1Map [
	<example>
	^ self default a1Map inspect.
]

{ #category : #accessing }
KFJapaneseEUC class >> exampleA3Map [
	<example>
	^ self default a3Map inspect.
]

{ #category : #accessing }
KFJapaneseEUC class >> reset [
	<script>
	^ Default := nil.
]

{ #category : #accessing }
KFJapaneseEUC >> a1Map [
	^ a1Map ifNil: [ a1Map := self lookupA1Map ]
]

{ #category : #accessing }
KFJapaneseEUC >> a3Map [
	^ a3Map ifNil: [ a3Map := self lookupA3Map ]
]

{ #category : #conversion }
KFJapaneseEUC >> convertRecord: anArray [
	"#('A1F1' '8191' 'EFBFA0' 'FFE0' '2171' '{CantDisplay}' '&#65504;')"

	| key char |
	key := Character value: (Integer readFrom: (anArray first allButFirst: 2) base: 16).
	char := Character value: (Integer readFrom: (anArray at: 4) base: 16).
	^ Array with: key with: char
]

{ #category : #initialization }
KFJapaneseEUC >> initializeA1Map [
	a1Map := self lookupA1Map
]

{ #category : #initialization }
KFJapaneseEUC >> initializeA3Map [
	a3Map := self lookupA3Map
]

{ #category : #'private - lookup' }
KFJapaneseEUC >> lookupA1Array [
	"self lookupA1Array"

	^ self lookupArrayBeginsWith: 'A1'
]

{ #category : #'private - lookup' }
KFJapaneseEUC >> lookupA1Map [
	"self lookupA1Map"

	^ self lookupMapFromArray: self lookupA1Array
]

{ #category : #'private - lookup' }
KFJapaneseEUC >> lookupA2Array [
	"self lookupA2Array"

	^ self lookupArrayBeginsWith: 'A2'
]

{ #category : #'private - lookup' }
KFJapaneseEUC >> lookupA3Array [
	"self lookupA3Array"

	^ self lookupArrayBeginsWith: 'A3'
]

{ #category : #'private - lookup' }
KFJapaneseEUC >> lookupA3Map [
	"self lookupA3Map"

	^ self lookupMapFromArray: self lookupA3Array
]
