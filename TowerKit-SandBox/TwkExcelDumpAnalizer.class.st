Class {
	#name : #TwkExcelDumpAnalizer,
	#superclass : #Object,
	#category : #'TowerKit-SandBox'
}

{ #category : #conversion }
TwkExcelDumpAnalizer class >> columnName: n [
	n <= 26
		ifTrue: [ ^ (Character value: 64 + n) asString ].
	^ (self columnName: (n - 1 quo: 26)) , (self columnName: (n - 1 rem: 26) + 1)
]

{ #category : #conversion }
TwkExcelDumpAnalizer class >> columnNumber: s [
	| n offset |
	offset := ($A asciiValue - 1).
	n := 0.
	s do: [ :ch | n := n * 26 + (ch asciiValue - offset) ].
	^ n
]

{ #category : #examples }
TwkExcelDumpAnalizer class >> example1 [
	| map arraySize sharedTitle |
	map := self headerLabelsOfFile: self fixtureFilePath.
	arraySize := (map values collect: [ :value | value size ]) max.
	sharedTitle := Array new: arraySize.
	map
		keysAndValuesDo: [ :key :value | 
			| origValue |
			origValue := value copy.
			value traceCr.
			(value allSatisfy: [ :each | each isEmptyOrNil ])
				ifFalse: [ | found |
					found := false.
					value
						doWithIndex: [ :each :i | 
							found
								ifFalse:
									[ each ifEmpty: [ value at: i put: (sharedTitle at: i) ] ifNotEmpty: [ found := true ] ] ] ].
			(origValue allSatisfy: [ :each | each isEmptyOrNil ])
				ifTrue: [ map at: key put: '' ]
				ifFalse: [ map at: key put: ('/' join: value) ].
			value doWithIndex: [ :each :i | sharedTitle at: i put: each ] ].
	map explore
]

{ #category : #'as yet unclassified' }
TwkExcelDumpAnalizer class >> fixtureFilePath [
	^ ((FileLocator documents filesMatching: 'EF_*.txt') sort: [ :a :b | a basename < b basename ]) last
]

{ #category : #'as yet unclassified' }
TwkExcelDumpAnalizer class >> headerLabelsOfFile: aFileReference [
	| lines col map |
	aFileReference asFileReference
		mbReadStreamDo: [ :fs | 
			fs converter: ShiftJISTextConverter new.
			lines := fs contents lines ].
	map := OrderedDictionary new.
	lines
		do: [ :line | 
			| items addr form |
			items := line findTokens: ':'.
			addr := (items first findTokens: '$') asArray.
			addr at: 2 put: (addr at: 2) asInteger.
			form := ''.
			items size >= 2
				ifTrue: [ form := items second ].
			col := map at: addr first ifAbsentPut: [ OrderedCollection new ].
			col
				add:
					(self removeSpaces: form) ].
	^ map
]

{ #category : #'as yet unclassified' }
TwkExcelDumpAnalizer class >> removeSpaces: aString [
	| s a |
	s := aString withSeparatorsCompacted.
	s := s withBlanksCondensed.
	s := s copyReplaceAll: '　' with: ''.
	Character xmlSeparators , Character null asString
		do: [ :ch | s := s copyReplaceAll: ch asString with: '' ].
	^ s
]
