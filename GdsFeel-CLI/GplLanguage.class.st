Class {
	#name : 'GplLanguage',
	#superclass : 'Object',
	#instVars : [
		'keywords'
	],
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplLanguage >> initialize [
	self initializeKeywords
]

{ #category : 'as yet unclassified' }
GplLanguage >> initializeKeywords [
	keywords := Array streamContents: [ :s | self installIfOn: s ].
	keywords do: [ :each | each string ]
]

{ #category : 'as yet unclassified' }
GplLanguage >> installIfOn: aStream [
	aStream nextPut: (GplLanguageKeyword fromString: 'IF').
	aStream
		nextPut: ((GplLanguageKeyword fromString: 'ELSE') parent: 'IF').
	aStream
		nextPut: ((GplLanguageKeyword fromString: 'ELIF') parent: 'IF').
	aStream
		nextPut: ((GplLanguageKeyword fromString: 'ENDIF') parent: 'IF')
]

{ #category : 'as yet unclassified' }
GplLanguage >> installLoopOn: aStream [
	aStream nextPut: (GplLanguageKeyword fromString: 'DO').
	aStream
		nextPut: ((GplLanguageKeyword fromString: 'WHILE') parent: 'DO').
	aStream
		nextPut: ((GplLanguageKeyword fromString: 'UNTIL') parent: 'IF').
	aStream
		nextPut: ((GplLanguageKeyword fromString: 'ENDIF') parent: 'IF')
]
