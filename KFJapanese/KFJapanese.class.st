Class {
	#name : #KFJapanese,
	#superclass : #Object,
	#classVars : [
		'Source1'
	],
	#category : #KFJapanese
}

{ #category : #examples }
KFJapanese class >> exampleEUC [
	<script>
	self exampleFileNamed: 'do-euc.txt' convertor: 'euc-jp'
]

{ #category : #examples }
KFJapanese class >> exampleFileNamed: aFileName convertor: aSymbol [
	<script>
	| file |
	aSymbol traceCr.
	file := self sampleDataFolder / aFileName.
	file
		readStreamDo: [ :s | 
			s binary.
			s contents traceCr.
			s reset.
			s text.
			s converter: (TextConverter newForEncoding: aSymbol).
			s contents traceCr ]
]

{ #category : #examples }
KFJapanese class >> exampleSJIS [
	<script>
	self exampleFileNamed: 'do-sjis.txt' convertor: 'Shift_JIS'
]

{ #category : #examples }
KFJapanese class >> exampleUTF8 [
	<script>
	self exampleFileNamed: 'do-utf8.txt' convertor: 'utf8'
]

{ #category : #resources }
KFJapanese class >> lookupSource1 [
	^ self source1File contents
]

{ #category : #examples }
KFJapanese class >> sampleDataFolder [ 
	^ FileLocator home / 'NextCloud' / 'Models' / 'miseiri'
]

{ #category : #resources }
KFJapanese class >> source1 [
	^ Source1 ifNil: [ Source1 := self lookupSource1 ]
]

{ #category : #resources }
KFJapanese class >> source1File [
	"self source1File inspect."
	^ FileLocator home / 'NextCloud'/ 'KFJapanese-source1.txt'
]

{ #category : #resources }
KFJapanese class >> source2 [
	^ ''
]

{ #category : #conversion }
KFJapanese >> convertRecord: anArray [
	^ self subclassResponsibility
]

{ #category : #'private - lookup' }
KFJapanese >> lookupArrayBeginsWith: aString [
	"self lookupA1Array"

	^ self class source1 lines
		select: [ :line | line beginsWith: aString ]
		thenCollect: [ :line | (line findTokens: ' ') asArray collect: [ :item | item trim ] ]
]

{ #category : #'private - lookup' }
KFJapanese >> lookupMapFromArray: anArray [
	"self lookupA1Map"

	| map |
	map := Dictionary new.
	anArray
		do: [ :rec | 
			| pair |
			pair := self convertRecord: rec.
			map at: pair first put: pair second ].
	^ map
]
