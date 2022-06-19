"
A GplSubroutineGrammarTest is a test class for testing the behavior of GplSubroutineGrammar
"
Class {
	#name : #GplSubroutineGrammarTest,
	#superclass : #PPCompositeParserTest,
	#category : #'GplPetitParser-Tests'
}

{ #category : #'as yet unclassified' }
GplSubroutineGrammarTest >> parserClass [
	^ GplSubroutineGrammar
]

{ #category : #'tests-grammar-function' }
GplSubroutineGrammarTest >> testMonadicFunctionHeader [
	self
		parse: 'MONADIC FUNCTION FOO:=BAR PARAM'
		rule: #monadicFunctionHeader.
	self
		parse: 'MONADIC FUNCTION FOO := BAR PARAM'
		rule: #monadicFunctionHeader.
	self
		fail: 'MONADIC FUNCTION FOO : = BAR PARAM'
		rule: #monadicFunctionHeader.

	"keywod join"
	self
		fail: 'MONADIC_FUNCTION FOO := BAR PARAM'
		rule: #monadicFunctionHeader.
	self
		fail: 'MONADICFUNCTION FOO := BAR PARAM'
		rule: #monadicFunctionHeader.
	self
		fail: 'MONADIC FUNCTION FOO := BARPARAM'
		rule: #monadicFunctionHeader.

	"include TAB"
	self
		parse: 'MONADIC		FUNCTION FOO := BAR PARAM'
		rule: #monadicFunctionHeader.

	"include CR"
	self
		fail:
			'MONADIC
FUNCTION FOO := BAR PARAM'
		rule: #monadicFunctionHeader
]

{ #category : #'tests-grammar-function' }
GplSubroutineGrammarTest >> testNiladicFunctionHeader [
	self parse: 'NILADIC FUNCTION FOO:=BAR' rule: #niladicFunctionHeader.
	self parse: 'NILADIC FUNCTION FOO:=BAR' rule: #niladicFunctionHeader.
	self
		parse: 'NILADIC FUNCTION FOO := BAR'
		rule: #niladicFunctionHeader.
	self
		fail: 'NILADIC FUNCTION FOO : = BAR'
		rule: #niladicFunctionHeader.

	"keywod join"
	self fail: 'NILADIC_FUNCTION FOO := BAR' rule: #niladicFunctionHeader.
	self fail: 'NILADICFUNCTION FOO := BAR' rule: #niladicFunctionHeader.
	self fail: 'NILADIC FUNCTIONFOO := BAR' rule: #niladicFunctionHeader.

	"include TAB"
	self
		parse: 'NILADIC		FUNCTION FOO := BAR'
		rule: #niladicFunctionHeader.

	"include CR"
	self
		fail:
			'NILADIC
FUNCTION FOO := BAR'
		rule: #monadicFunctionHeader
]
