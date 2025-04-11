Class {
	#name : 'GplShisoku',
	#superclass : 'GplLiteralGrammar',
	#instVars : [
		'add',
		'prec1',
		'mul',
		'prec2',
		'parlen',
		'prec0',
		'precMax'
	],
	#category : 'GplPetitParser-Grammar',
	#package : 'GplPetitParser',
	#tag : 'Grammar'
}

{ #category : 'as yet unclassified' }
GplShisoku >> add [
	^ self left: prec1 op: $+ right: prec0
]

{ #category : 'as yet unclassified' }
GplShisoku >> left: aLargerPrecParser op: op right: aOwnPrecParser [
	| blanks opParser |
	blanks := blankDelimiter star.
	opParser := op asParser.
	^ aLargerPrecParser , blanks , opParser , blanks , aOwnPrecParser
]

{ #category : 'as yet unclassified' }
GplShisoku >> mul [
	^ self left: prec2 op: $* right: prec1
]

{ #category : 'as yet unclassified' }
GplShisoku >> parenthesis [
	^ $( asParser , blankDelimiter star , prec0 , blankDelimiter star
		, $) asParser
]

{ #category : 'as yet unclassified' }
GplShisoku >> prec0 [
	^ add / prec1
]

{ #category : 'as yet unclassified' }
GplShisoku >> prec1 [
	^ mul / prec2
]

{ #category : 'as yet unclassified' }
GplShisoku >> prec2 [
	^ precMax
]

{ #category : 'as yet unclassified' }
GplShisoku >> precMax [
	^ parlen / super value
]

{ #category : 'as yet unclassified' }
GplShisoku >> start [
	^ prec0
]
