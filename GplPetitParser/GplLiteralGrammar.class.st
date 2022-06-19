Class {
	#name : #GplLiteralGrammar,
	#superclass : #PPCompositeParser,
	#instVars : [
		'natural',
		'e',
		'integer',
		'real',
		'scalarLiteral',
		'realFixedPart',
		'vectorLiteral',
		'realExponentFormat',
		'arrayLiteral',
		'logical',
		'charMnemonicLiteral',
		'charOctalLiteral',
		'charNormalLiteral',
		'charLiteral',
		'nullLiteral',
		'stringLiteral',
		'blankDelimiter',
		'numberVectorLiteral',
		'start',
		'expression'
	],
	#category : #'GplPetitParser-Grammar'
}

{ #category : #'as yet unclassified' }
GplLiteralGrammar class >> exampleWorkSpace [
	| gg |
	gg := GplLiteralGrammar new.
	gg real parse: '.0'.
	gg real parse: '-1.'.
	gg scalarLiteral parse: '1E-3'.
	gg logical matches: 'TRUE'.
	gg flatten parse: '0 0 0 0 0 0 0'.
	gg parse: '* -10 1 1E-3 TRUE'.
	gg parse: '1E3'.
	gg integer end parse: '1'.
	gg parse: '1 -1 	1.0 -1.0 2.   .2 1E-4 2E3'.
	"{'1'. {Character space}. '-1'. {Character space. Character tab}. '1.0'. {Character space}. '-1.0'. {Character space}. '2.'. {Character space. Character space. Character space}. '.2'. {Character space}. '1E-4'. {Character space}. '2E3'}"
	gg real parse: '1.0'.
	" #('1' $. '0')"
	gg real parse: '1.'.
	"#('1' $. nil)"
	gg real parse: '.1'
	"#(nil $. '1') "
]

{ #category : #grammar }
GplLiteralGrammar >> arrayLiteral [
	^ vectorLiteral / scalarLiteral
]

{ #category : #utility }
GplLiteralGrammar >> asToken: aParser [
	^ aParser gplPPToken
]

{ #category : #grammar }
GplLiteralGrammar >> blankDelimiter [
	^ #blank asParser plus flatten
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> charLiteral [
	^ charNormalLiteral / charMnemonicLiteral / charOctalLiteral
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> charMnemonicLiteral [
	^ $< asParser
		,
			('NUL' asParser / 'BEL' asParser / 'HT' asParser / 'TAB' asParser
				/ 'LF' asParser / 'FF' asParser / 'CR' asParser / 'NL' asParser
				/ 'ESC' asParser / 'QT' asParser / 'DEL' asParser
				/ 'BRON' asParser / 'BROFF' asParser) , $> asParser
	" I hope LT, GT without 74, 76"
	"'LT' asParser / "
	"'GT' asParser / "
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> charNormalLiteral [
	^ PPPredicateObjectParser anyExceptAnyOf: '"<>'
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> charOctalLiteral [
	"TODO: currenty 177 over check not implemented"

	^ ($< asParser , (#octalDigit asParser min: 1 max: 3) flatten
		, $> asParser)
		==> [ :token | 
			| v |
			token crLog.
			v := Integer readFrom: token second radix: 8.
			((0 to: 127) includes: v)
				ifFalse: [ PPFailure message: 'octal constants MAX: <177>' ]
				ifTrue: [ token ] ]
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> e [
	^ $E asParser , integer
]

{ #category : #grammar }
GplLiteralGrammar >> expression [
	^ arrayLiteral
]

{ #category : #grammar }
GplLiteralGrammar >> integer [
	^ ($- asParser optional , natural) flatten
]

{ #category : #grammar }
GplLiteralGrammar >> logical [
	^ ('TRUE' asParser / 'FALSE' asParser / $1 asParser / $0 asParser)
		flatten
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> natural [
	^ #digit asParser plus flatten
]

{ #category : #grammar }
GplLiteralGrammar >> nullLiteral [
	^ '""' asParser
]

{ #category : #grammar }
GplLiteralGrammar >> numberVectorLiteral [
	^ (scalarLiteral separatedBy: blankDelimiter) withoutSeparators
]

{ #category : #grammar }
GplLiteralGrammar >> real [
	^ realExponentFormat / realFixedPart
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> realExponentFormat [
	^ realFixedPart / integer , e
]

{ #category : #'grammar-parts' }
GplLiteralGrammar >> realFixedPart [
	^ $- asParser optional
		,
			((natural , $. asParser , natural optional)
				/ (natural optional , $. asParser , natural))	"1.   <- 1.0"	" .1  <- 0.1"
]

{ #category : #grammar }
GplLiteralGrammar >> scalarLiteral [
	^ (real / integer / logical) flatten
]

{ #category : #grammar }
GplLiteralGrammar >> start [
	^ expression end
]

{ #category : #grammar }
GplLiteralGrammar >> stringLiteral [
	^ ($" asParser , charLiteral star , $" asParser) / nullLiteral
]

{ #category : #utility }
GplLiteralGrammar >> tokenFor: aString [
	| p |
	p := aString asString asParser.
	(aString asString allSatisfy: [ :c | c isLetter ])
		ifTrue: [ p := p , #word asParser not ].
	^ self asToken: p
]

{ #category : #grammar }
GplLiteralGrammar >> vectorLiteral [
	^ numberVectorLiteral / stringLiteral
]
