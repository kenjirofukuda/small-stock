Class {
	#name : #GplStatementsGrammar,
	#superclass : #GplExpressionGrammar,
	#instVars : [
		'codeBlock',
		'ifPart',
		'elifPart',
		'elsePart',
		'gotoStatement',
		'ifStatement',
		'switchStatement',
		'doStatement',
		'labelDest',
		'inlineComment',
		'sourceLine',
		'flowControl',
		'emptyStatement',
		'restOfFlow'
	],
	#category : #'GplPetitParser-Grammar'
}

{ #category : #'grammar-if-private' }
GplStatementsGrammar >> basicIfPart: aIfOrElif [
	^ (self tokenFor: aIfOrElif) , expression , (self tokenFor: 'THEN')
		, statement
]

{ #category : #grammar }
GplStatementsGrammar >> codeBlock [
	^ (sourceLine delimitedBy: #newline asParser) / sourceLine
]

{ #category : #'grammar-flow' }
GplStatementsGrammar >> doStatement [
	" 4 pattern:
FOR variable RANGE vector DO block ENDDO 
WHILE expression DO block ENDDO
DO block UNTIL expression ENDDO
DO block ENDDO
	
	"

	
]

{ #category : #'grammar-if-private' }
GplStatementsGrammar >> elifPart [
	^ self basicIfPart: 'ELIF'
]

{ #category : #'grammar-if-private' }
GplStatementsGrammar >> elsePart [
	^ (elifPart , elsePart) / elifPart
		/ ((self tokenFor: 'ELSE') , statement)
]

{ #category : #grammar }
GplStatementsGrammar >> emptyStatement [
	^ blankDelimiter star optional
]

{ #category : #grammar }
GplStatementsGrammar >> flowControl [
	^ ifStatement	"(gotoStatement / "	"/ switchStatement / doStatement)"
]

{ #category : #grammar }
GplStatementsGrammar >> gotoStatement [
	^ (self tokenFor: 'GOTO') , labelDest
]

{ #category : #'grammar-if-private' }
GplStatementsGrammar >> ifPart [
	^ self basicIfPart: 'IF'
]

{ #category : #'grammar-flow' }
GplStatementsGrammar >> ifStatement [
	^ (ifPart , elsePart , (self tokenFor: 'ENDIF'))
		/ (ifPart , (self tokenFor: 'ENDIF'))
]

{ #category : #grammar }
GplStatementsGrammar >> inlineComment [
	^ $| asParser / $` asParser , #newline asParser negate star flatten
]

{ #category : #'grammar-dyadic' }
GplStatementsGrammar >> label [
	^ labelDest , ':'
]

{ #category : #'grammar-dyadic' }
GplStatementsGrammar >> labelDest [
	^ gdsName flatten
]

{ #category : #utility }
GplStatementsGrammar >> restOfFlow [
	^ blankDelimiter optional , inlineComment optional
		, #newline asParser optional
]

{ #category : #grammar }
GplStatementsGrammar >> sourceLine [
	^ self
		sourceLineOf:
			[ ((self tokenFor: 'ENDSUB') asParser not and , statement) ==> #second ]
]

{ #category : #utility }
GplStatementsGrammar >> sourceLineOf: aBlock [
	^ blankDelimiter star flatten , aBlock value
		, blankDelimiter star flatten , inlineComment optional
]

{ #category : #grammar }
GplStatementsGrammar >> start [
	^ codeBlock end
]

{ #category : #grammar }
GplStatementsGrammar >> statement [
	^ (codeBlock / (self sourceLineOf: flowControl)
		/ (self sourceLineOf: super statement) / emptyStatement) memoized
]

{ #category : #'grammar-flow' }
GplStatementsGrammar >> switchStatement [
	
]
