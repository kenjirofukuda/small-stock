Class {
	#name : #GplStatementsGrammarTest,
	#superclass : #PPCompositeParserTest,
	#category : #'GplPetitParser-Tests'
}

{ #category : #'as yet unclassified' }
GplStatementsGrammarTest >> parserClass [
	^ GplStatementsGrammar
]

{ #category : #'as yet unclassified' }
GplStatementsGrammarTest >> testCodeBlock [
	self parse: ' ' rule: #codeBlock.
	self
		parse:
			'
'
		rule: #codeBlock.


	" oneLine "
	self parse: 'A:=1' rule: #codeBlock.
	self
		parse:
			'
	A:=1
	B:=1
	C:=1'
		rule: #codeBlock.
	self
		parse:
			'A:=1
	B:=1
	C:=1
'
		rule: #codeBlock.
	self
		parse:
			'A:=1
	| this is a comment
	C:=1'
		rule: #codeBlock.

	"nested flowcontrol"
	self
		parse:
			'IF 1 THEN
	  IF 2 THEN
	  ELSE
	  ENDIF
	ELSE
	ENDIF
	'
		rule: #codeBlock
]

{ #category : #'as yet unclassified' }
GplStatementsGrammarTest >> testEmptyStatement [
	self parse: '' rule: #emptyStatement.
	self parse: ' ' rule: #emptyStatement.
	self parse: ' 		' rule: #emptyStatement.
	self
		fail:
			'
'
		rule: #emptyStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement1 [
	self parse: 'IF A = 1 THEN C := 1 ENDIF' rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement10 [
	"double ELSE "

	"10"

	self
		fail:
			'IF A = 1 THEN
ELSE
ELSE
ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement11 [
	"11"

	self
		parse: 'IF A = 1 THEN C:=2 ELIF B = 1 THEN L:=3 ELSE D:=1 ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement12 [
	"12"

	self
		parse:
			'IF A = 1 THEN C:=2 ELIF B = 1 THEN L:=3 ELIF B > 1 THEN L:=5 ELSE D:=1 ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement13 [
	"13"

	self
		parse: 'IF A = 1 THEN C:=2 ELIF B = 1 THEN ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement14 [
	"14"

	self
		parse:
			'IF A = 1 THEN
	C:=2
ELIF B = 1 THEN
ENDIF'
		rule: #ifStatement

	"
GplStatementsGrammar new ifStatement end parse: 
'IF A = 1 THEN
	C:=2
ELIF B = 1 THEN
ENDIF'
.

"
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement15 [
	"15"

	self
		parse:
			'IF A = 1 THEN
	C:=2
ELIF B = 1 THEN
	L:=3
ELSE
	D:=1
ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement16 [
	"Missing THEN"

	"16"

	self fail: 'IF A = 1  C := 1 ENDIF' rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement17 [
	"17"

	"missing ENDIF"

	self fail: 'IF A = 1 THEN C := 1' rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement18 [
	"double ELSE"

	self
		fail: 'IF A = 1 THEN C := 1 ELSE F:=1 ELSE F:=2 ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement2 [
	"expression empty"

	self fail: 'IF  THEN C := 1 ENDIF' rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement3 [
	"3"

	self parse: 'IF A = 1 THEN C := 1 ELSE ENDIF' rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement4 [
	"4"

	self
		parse: 'IF A = 1 THEN C := 1 ELSE B := 2 ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement5 [
	"5"

	self parse: 'IF A = 1 THEN ENDIF' rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement6 [
	"6"

	self
		parse:
			'IF A = 1 THEN
    C := 1   
ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement7 [
	"7"

	self
		parse:
			'IF A = 1 THEN
C := 1
D := 1
E := 1
ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement8 [
	"emptyStatement"

	"8"

	self
		parse:
			'IF A = 1 THEN
ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - if' }
GplStatementsGrammarTest >> testIfStatement9 [
	"9"

	self
		parse:
			'IF A = 1 THEN
ELSE
	F:=1
ENDIF'
		rule: #ifStatement
]

{ #category : #'tests - sourceLine' }
GplStatementsGrammarTest >> testSourceLine1 [
	"without blanks"

	self parse: 'A:=1' rule: #sourceLine
]

{ #category : #'tests - sourceLine' }
GplStatementsGrammarTest >> testSourceLine2 [
	"both spaces"

	self parse: ' A:=1 ' rule: #sourceLine
]

{ #category : #'tests - sourceLine' }
GplStatementsGrammarTest >> testSourceLine3 [
	"both space and inline comment"

	self parse: ' A:=1| comment' rule: #sourceLine
]

{ #category : #'tests - sourceLine' }
GplStatementsGrammarTest >> testSourceLine4 [
	"both space and inline comment"

	self
		parse:
			' A:=1
| comment'
		rule: #sourceLine
]

{ #category : #'as yet unclassified' }
GplStatementsGrammarTest >> testStatement [
	self parse: 'A:=1' rule: #statement.
	self
		parse:
			'    A:=1
	B:=1
	C:=1'
		rule: #statement.


	"has both delimiters "
	self parse: ' A:=1 ' rule: #statement
]
