Class {
	#name : 'GplLiteralGrammarTest',
	#superclass : 'PPCompositeParserTest',
	#instVars : [
		'gplGrammar'
	],
	#category : 'GplPetitParser-Tests',
	#package : 'GplPetitParser',
	#tag : 'Tests'
}

{ #category : 'accessing' }
GplLiteralGrammarTest >> parserClass [
	^ GplLiteralGrammar
]

{ #category : 'running' }
GplLiteralGrammarTest >> setUp [
	gplGrammar := GplLiteralGrammar new
]

{ #category : 'running' }
GplLiteralGrammarTest >> tearDown [
	gplGrammar := nil
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testCharLiteral [
	"Tests GplLiteralGrammar>>#charLiteral"

	self parse: '<NUL>' rule: #charLiteral.
	self fail: 'NUL' rule: #charLiteral.
	self fail: '<8>' rule: #charLiteral.	"only use 0 - 7"
	self parse: '<177>' rule: #charLiteral.
	self fail: '<377>' rule: #charLiteral.	"MAX 177"
	self fail: '<378>' rule: #charLiteral.
	self fail: '177' rule: #charLiteral.
	self parse: 'a' rule: #charLiteral.
	self fail: '<' rule: #charLiteral.
	self fail: '>' rule: #charLiteral
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testCharMnemonicLiteral [
	"Tests GplExpressionGrammar>>#charMnemonicLiteral"

	self fail: '<NUL' rule: #charMnemonicLiteral.
	self fail: 'NUL>' rule: #charMnemonicLiteral.
	self fail: '<NUL>>' rule: #charMnemonicLiteral.
	self fail: '<<NUL>' rule: #charMnemonicLiteral.
	self fail: '<NUL)' rule: #charMnemonicLiteral.
	self fail: '(NUL>' rule: #charMnemonicLiteral.
	self fail: '[NUL]' rule: #charMnemonicLiteral.
	self fail: '(NUL)' rule: #charMnemonicLiteral.
	self fail: '<NULL>' rule: #charMnemonicLiteral.
	self fail: '<NIL>' rule: #charMnemonicLiteral.
	self fail: '<nul>' rule: #charMnemonicLiteral.
	self parse: '<NUL>' rule: #charMnemonicLiteral.
	self parse: '<BEL>' rule: #charMnemonicLiteral.
	self parse: '<HT>' rule: #charMnemonicLiteral.
	self parse: '<TAB>' rule: #charMnemonicLiteral.	"but i wan'ts"
	self parse: '<LF>' rule: #charMnemonicLiteral.
	self parse: '<FF>' rule: #charMnemonicLiteral.
	self parse: '<CR>' rule: #charMnemonicLiteral.
	self parse: '<NL>' rule: #charMnemonicLiteral.
	self parse: '<ESC>' rule: #charMnemonicLiteral.
	self parse: '<QT>' rule: #charMnemonicLiteral.
	"$<"
	self fail: '<LT>' rule: #charMnemonicLiteral.	"but i wan'ts"
	"$>"
	self fail: '<GT>' rule: #charMnemonicLiteral.	"but i wan'ts"
	self parse: '<DEL>' rule: #charMnemonicLiteral.
	self parse: '<BRON>' rule: #charMnemonicLiteral.
	self parse: '<BROFF>' rule: #charMnemonicLiteral.

	"disallow lowercase. but..."
	self fail: '<nul>' rule: #charMnemonicLiteral.
	self fail: '<bel>' rule: #charMnemonicLiteral.
	self fail: '<ht>' rule: #charMnemonicLiteral.
	self fail: '<tab>' rule: #charMnemonicLiteral.	"but i wan'ts"
	self fail: '<lf>' rule: #charMnemonicLiteral.
	self fail: '<ff>' rule: #charMnemonicLiteral.
	self fail: '<cr>' rule: #charMnemonicLiteral.
	self fail: '<nl>' rule: #charMnemonicLiteral.
	self fail: '<esc>' rule: #charMnemonicLiteral.
	self fail: '<qt>' rule: #charMnemonicLiteral.
	self fail: '<del>' rule: #charMnemonicLiteral
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testCharNormalLiteral [
	"Tests GplLiteralGrammar>>#charNormalLiteral"

	self parse: 'a' rule: #charNormalLiteral.
	self parse: 'b' rule: #charNormalLiteral.
	self parse: '1' rule: #charNormalLiteral.
	self parse: '+' rule: #charNormalLiteral.

	"escape Character"
	self fail: '<' rule: #charNormalLiteral.
	self fail: '>' rule: #charNormalLiteral.
	self fail: 'aa' rule: #charNormalLiteral
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testCharOctalLiteral [
	"Tests GplExpressionGrammar>>#charOctalLiteral"

	self parse: '<0>' rule: #charOctalLiteral.
	self parse: '<00>' rule: #charOctalLiteral.
	self parse: '<000>' rule: #charOctalLiteral.
	self fail: '<0000>' rule: #charOctalLiteral.
	self parse: '<177>' rule: #charOctalLiteral.
	((0 to: 8r177) collect: [ :each | '<' , (each radix: 8) , '>' ])
		do: [ :each | self parse: each rule: #charOctalLiteral ].
	((8r200 to: 8r277) collect: [ :each | '<' , (each radix: 8) , '>' ])
		do: [ :each | self fail: each rule: #charOctalLiteral ].
	self fail: '<O>' rule: #charOctalLiteral.	"OPQR's first Oh not zero"
	"octal valur range over"
	self fail: '<8>' rule: #charOctalLiteral.
	"under zero"
	self fail: '<-0>' rule: #charOctalLiteral.
	"over 128"
	self fail: '<200>' rule: #charOctalLiteral.
	"max 3"
	self fail: '<1777>' rule: #charOctalLiteral
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testIntegerLiteral [
	self parse: '-1' rule: #integer.
	self parse: '0' rule: #integer.
	self parse: '1' rule: #integer.
	self
		deny: (gplGrammar integer end matches: '+1')
		description: 'Can''t use top plus sign'.
	self
		assert: (gplGrammar integer end matches: '-1')
		description: 'Allow only minus signt'.
	self
		deny: (gplGrammar integer end matches: '1.0')
		description: 'Can''t use floating point'
]

{ #category : 'tests-grammar' }
GplLiteralGrammarTest >> testLogical [
	
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testLogicalLiteral [
	self parse: '1' rule: #logical.
	self parse: '0' rule: #logical.
	self parse: 'TRUE' rule: #logical.
	self parse: 'FALSE' rule: #logical.
	self fail: '.1' rule: #logical.
	self fail: '0.' rule: #logical.
	self fail: '2' rule: #logical.
	self fail: '-1' rule: #logical.

	"originally disallow loweracse. but..."
	self fail: 'true' rule: #logical.
	self fail: 'false' rule: #logical
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testNullLiteral [
	"Tests GplExpressionGrammar>>#nullLiteral"

	self parse: '""' rule: #nullLiteral.

	"GDS NULL is not..."
	self fail: 'NULL' rule: #nullLiteral.	"C MACRO"
	self fail: 'nil' rule: #nullLiteral.	"Smalltalk"
	self fail: '()' rule: #nullLiteral.	"lisp"
	self fail: '" "' rule: #nullLiteral	"Space"
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testRealLiteral [
	self assert: (gplGrammar realExponentFormat end matches: '-1.0E5').
	self assert: (gplGrammar realExponentFormat end matches: '-0.1E5').
	self assert: (gplGrammar realExponentFormat end matches: '1.0E5').
	self assert: (gplGrammar realExponentFormat end matches: '1.0E-5').
	self assert: (gplGrammar real end matches: '0.1').
	self assert: (gplGrammar realFixedPart end matches: '0.1').

	"allow drop first zero 0.1 -> .1"
	self assert: (gplGrammar real end matches: '.1').
	self assert: (gplGrammar realFixedPart end matches: '.1').
	self assert: (gplGrammar real matches: '1.0').
	self assert: (gplGrammar realFixedPart matches: '1.0').

	"allow drop last zero 1.0 -> 1."
	self assert: (gplGrammar real end matches: '1.').
	self assert: (gplGrammar realFixedPart end matches: '1.').

	"can't use + sign"
	self
		deny: (gplGrammar real end matches: '+1.0')
		description: 'can''t use + sign'.
	self assert: (gplGrammar real end matches: '1E1').
	self assert: (gplGrammar real end matches: '1E-1').
	self assert: (gplGrammar real end matches: '-1E1').
	self assert: (gplGrammar real end matches: '-1E-1').
	self
		deny: (gplGrammar real end matches: '1E+1')
		description: 'can''t use plus sign in exponet part'.

	"originally disallow lowercase e. but..."
	self
		deny: (gplGrammar real end matches: '1e1')
		description: 'can''t use small capital e'.
	self assert: (gplGrammar real end matches: '1.0E5').
	self assert: (gplGrammar real end matches: '1.0E-5').
	self assert: (gplGrammar real end matches: '-.1E-5')
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testScalarLiteral [
	self parse: '0' rule: #natural.
	self fail: '-0' rule: #natural.
	self parse: '0' rule: #integer.
	self parse: '-1' rule: #integer.
	self fail: '+1.0' rule: #integer.
	self fail: '1.0' rule: #integer.
	self parse: '1.0' rule: #realFixedPart.
	self parse: '1.0' rule: #real.
	self parse: '-1.0' rule: #realFixedPart.
	self parse: '-1.0' rule: #real.
	self fail: '+1.0' rule: #real.
	self parse: '-1.' rule: #realFixedPart.
	self parse: '-1.' rule: #real.
	self parse: '-0.1' rule: #realFixedPart.
	self parse: '-0.1' rule: #real.
	self parse: '-.1' rule: #realFixedPart.
	self parse: '-.1' rule: #real.
	self parse: '1E-1' rule: #realExponentFormat.
	self fail: '1E+1' rule: #realExponentFormat.
	self parse: '-1E-1' rule: #realExponentFormat.
	self fail: '-1E+1' rule: #realExponentFormat.
	self parse: '1E-1' rule: #real.
	self parse: '1.0E-1' rule: #realExponentFormat.
	self fail: '1.0E+1' rule: #realExponentFormat.
	self parse: '-1.0E-1' rule: #realExponentFormat.
	self fail: '-1.0E+1' rule: #realExponentFormat.
	self parse: '1.0E-1' rule: #real
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testStringLiteral [
	"Tests GplLiteralGrammar>>#stringLiteral"

	self parse: '""' rule: #stringLiteral.
	self fail: '"1<hage>"' rule: #stringLiteral.
	self fail: '"<NUL"' rule: #stringLiteral.
	self fail: '"NUL>"' rule: #stringLiteral.
	self parse: '"<NUL>"' rule: #stringLiteral.
	self fail: '"<NUL>>"' rule: #stringLiteral.
	self fail: '"<<NUL>>"' rule: #stringLiteral.
	self parse: '"a"' rule: #stringLiteral
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testStringLiteral2 [
	"Tests GplLiteralGrammar>>#stringLiteral"

	| gplString |
	gplString := (GplLiteralGrammar new stringLiteral
		parse: '"*** <BRON>ERROR<BROFF>**<TAB>*"')
		ifNotNil: [ :arr | 
			GdsString
				withAll:
					(arr second
						collect: [ :charLiteral | 
							GdsCharacter
								fromAsciiValue:
									((charLiteral isKindOf: Character)
										ifTrue: [ "{ $< . 'CR' . $> }" charLiteral asciiValue ]
										ifFalse: [ GdsCharacter asciiValueInsideCharMarkLiteral: (charLiteral at: 2) ])
							"$a ..." ]) ]
]

{ #category : 'tests' }
GplLiteralGrammarTest >> testVectorLiteral [
	self parse: '1' rule: #scalarLiteral.
	self parse: '1' rule: #vectorLiteral.
	self parse: '0 0 0 0 0 0' rule: #vectorLiteral.
	"include TAB"
	self parse: '0 		0 0 0 0 0' rule: #vectorLiteral.
	self parse: '0 0 0 0 0 0' rule: #numberVectorLiteral.
	self fail: '0 0 0 0 0 0' rule: #scalarLiteral.
	self
		parse: '1 0 1.0 0 -1.0 1E-12 -0.1E-5 TRUE FALSE'
		rule: #vectorLiteral.
	self
		parse: '1 0 TRUE FALSE 1.0 0 -1.0 1E-12 -0.1E-5'
		rule: #vectorLiteral.
	self parse: 'TRUE FALSE' rule: #vectorLiteral
]
