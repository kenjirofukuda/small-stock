"
A GplLanguageKeywordTest is a test class for testing the behavior of GplLanguageKeyword
"
Class {
	#name : 'GplLanguageKeywordTest',
	#superclass : 'TestCase',
	#category : 'GdsFeel-CLI-Tests',
	#package : 'GdsFeel-CLI',
	#tag : 'Tests'
}

{ #category : 'tests-as yet unclassified' }
GplLanguageKeywordTest >> testFoo [
	| words |
	words := Array
		streamContents: [ :s | 
			s nextPut: (GplLanguageKeyword fromString: 'IF').
			s nextPut: ((GplLanguageKeyword fromString: 'ELSE') parent: 'IF').
			s nextPut: ((GplLanguageKeyword fromString: 'ELIF') parent: 'IF').
			s nextPut: ((GplLanguageKeyword fromString: 'ENDIF') parent: 'IF') ].
	words do: [ :each | each string ].
	words explore
]
