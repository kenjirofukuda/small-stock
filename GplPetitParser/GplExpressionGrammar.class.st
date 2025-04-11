Class {
	#name : 'GplExpressionGrammar',
	#superclass : 'GplLiteralGrammar',
	#instVars : [
		'statement',
		'operatorType',
		'gdsNameRest',
		'gdsNameHead',
		'gdsName',
		'varName',
		'assignVariableNameExpr',
		'assignment',
		'subscript',
		'list',
		'scalar',
		'listConcatenationOperator',
		'listLiteral',
		'prec005',
		'prec006',
		'prec007',
		'arrayConcatenate',
		'precMax',
		'prec377',
		'prec015',
		'addition',
		'multiplication',
		'prec016',
		'prec011',
		'prec012',
		'prec020',
		'division',
		'subtraction',
		'prec013',
		'prec010',
		'prec017',
		'prec000',
		'parenthesis',
		'subroutineName',
		'subroutineType',
		'cantAssignNames'
	],
	#category : 'GplPetitParser-Grammar',
	#package : 'GplPetitParser',
	#tag : 'Grammar'
}

{ #category : 'grammar-arithmetic-dyadic' }
GplExpressionGrammar >> addition [
	^ self left: prec016 op: $+ right: prec015
]

{ #category : 'grammar' }
GplExpressionGrammar >> arrayConcatenate [
	^ self left: prec007 op: $, right: prec006
]

{ #category : 'grammar' }
GplExpressionGrammar >> assignVariableNameExpr [
	"precendence 8r0"

	^ (varName , (blankDelimiter star , subscript) optional) / varName
]

{ #category : 'grammar' }
GplExpressionGrammar >> assignment [
	^ self left: assignVariableNameExpr op: ':=' right: expression
]

{ #category : 'accessing' }
GplExpressionGrammar >> builtinOperatorNames [
	^ Array
		streamContents: [ :s | 
			s nextPutAll: self keys007.
			s nextPutAll: self keys010.
			s nextPutAll: self keys011.
			s nextPutAll: self keys012.
			s nextPutAll: self keys013.
			s nextPutAll: self keys016.
			s nextPutAll: self keys017.
			s nextPutAll: self keys020 ]
]

{ #category : 'accessing' }
GplExpressionGrammar >> cantAssignNames [
	^ PPChoiceParser
		withAll:
			(self builtinOperatorNames , self reservedNames
				collect: [ :s | s asParser ])
]

{ #category : 'grammar' }
GplExpressionGrammar >> dataType [
	^ (self tokenFor: 'LOGICAL') / (self tokenFor: 'CHAR')
		/ (self tokenFor: 'INTEGER2') / (self tokenFor: 'INTEGER')
		/ (self tokenFor: 'REAL2') / (self tokenFor: 'REAL')
]

{ #category : 'grammar-arithmetic-dyadic' }
GplExpressionGrammar >> division [
	^ self left: prec017 op: $% right: prec016
]

{ #category : 'grammar' }
GplExpressionGrammar >> expression [
	^ prec000
]

{ #category : 'grammar' }
GplExpressionGrammar >> gdsName [
	"gdsName ::= regex/[A-Z$]([A-Z0-9$_]){0,31}/"

	^ gdsNameHead , (gdsNameRest min: 0 max: 31)
]

{ #category : 'grammar' }
GplExpressionGrammar >> gdsNameHead [
	^ #uppercaseLetter asParser	"/ $$ asParser"
]

{ #category : 'grammar-parts' }
GplExpressionGrammar >> gdsNameRest [
	^ gdsNameHead / #letter asParser / #digit asParser / $_ asParser / $$ asParser
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys000 [
	^ #(':=')	"assignment"
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys005 [
	^ #(';')	"list separator"
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys006 [
	^ #(',') "dyadic array concatenation"
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys007 [
	^ #('INDEXOF' 'RESHAPE' 'DROP' 'SAVE' 'SUBSTRING' 'DSELECT' 'INDICES_OF')
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys010 [
	^ #('IOTA' 'SHAPE' 'LENGTH' 'SIZE' 'TYPEOF' 'RANK')	"', (monadic)'"
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys011 [
	^ #('AND' 'NAND')
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys012 [
	^ #('OR' 'XOR' 'NOR')
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys013 [
	^ #('EQ' 'GEQ' 'GT' 'IN' 'LEQ' 'NEQ' '=' '<' '>' '<=' '>=' '<>')
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys016 [
	^ #('MAX' 'MIN' 'MOD')
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys017 [
	^ #('LOGBASE' 'POWER')
]

{ #category : 'precedence' }
GplExpressionGrammar >> keys020 [
	^ #('ABS' 'ARCTAN' 'CEILING' 'COS' 'FLOOR' 'GRADEDOWN' 'GRADEUP' 'LN' 'NOT' 'PI' 'SIN' 'SORT' 'SORTDOWN' 'TAN' '+' '-' '*' '%')
]

{ #category : 'private' }
GplExpressionGrammar >> left: aLargerPrecParser op: op right: aOwnPrecParser [
	| blanks opParser |
	blanks := blankDelimiter star.
	op asString isAllAlphaNumerics
		ifTrue: [ blanks := blankDelimiter plus ].
	blanks := blanks flatten.
	opParser := self tokenFor: op.
	^ ((self asToken: aLargerPrecParser) , opParser
		, (self asToken: aOwnPrecParser)) memoized
	"blanks, "
	"blanks,"
]

{ #category : 'grammar-dyadic' }
GplExpressionGrammar >> list [
	^ self left: prec006 op: $; right: prec005
]

{ #category : 'grammar' }
GplExpressionGrammar >> listConcatenationOperator [
	"precendence 8r5"

	^ blankDelimiter star , $; asParser , blankDelimiter star
]

{ #category : 'grammar' }
GplExpressionGrammar >> listLiteral [
	^ arrayLiteral separatedBy: listConcatenationOperator
]

{ #category : 'grammar-arithmetic-dyadic' }
GplExpressionGrammar >> multiplication [
	^ self left: prec017 op: $* right: prec016
]

{ #category : 'private' }
GplExpressionGrammar >> op: op right: aLargerPrecParser [
	| blanks opParser |
	blanks := blankDelimiter star.
	opParser := self tokenFor: op.
	op asString isAllAlphaNumerics
		ifTrue: [ blanks := blankDelimiter plus ].
	^ (opParser , (self asToken: aLargerPrecParser)) memoized	"blanks, "
]

{ #category : 'grammar' }
GplExpressionGrammar >> operatorType [
	^ (self tokenFor: 'NILADIC') / (self tokenFor: 'MONADIC')
		/ (self tokenFor: 'DYADIC')
]

{ #category : 'grammar' }
GplExpressionGrammar >> parenthesis [
	^ (self tokenFor: $() , expression , (self tokenFor: $))
	"blankDelimiter star,"
	"blankDelimiter star,"
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec000 [
	^ assignment / prec005
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec005 [
	^ list / prec006
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec006 [
	^ arrayConcatenate / prec007
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec007 [
	^ (PPChoiceParser
		withAll:
			(self keys007
				collect: [ :op | self left: prec010 op: op right: prec007 ]))
		/ prec010
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec010 [
	^ (PPChoiceParser
		withAll: (self keys010 collect: [ :op | self op: op right: prec011 ]))
		/ prec011
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec011 [
	^ (PPChoiceParser
		withAll:
			(self keys011
				collect: [ :op | self left: prec012 op: op right: prec011 ]))
		/ prec012
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec012 [
	^ (PPChoiceParser
		withAll:
			(self keys012
				collect: [ :op | self left: prec013 op: op right: prec012 ]))
		/ prec013
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec013 [
	^ (PPChoiceParser
		withAll:
			(self keys013
				collect: [ :op | self left: prec015 op: op right: prec013 ]))
		/ prec015
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec015 [
	^ addition / subtraction / prec016
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec016 [
	^ (PPChoiceParser
		withAll:
			(self keys016
				collect: [ :op | self left: prec017 op: op right: prec016 ]))
		/ multiplication / division / prec017
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec017 [
	^ (PPChoiceParser
		withAll:
			(self keys017
				collect: [ :op | self left: prec020 op: op right: prec017 ]))
		/ prec020
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec020 [
	^ (PPChoiceParser
		withAll: (self keys020 collect: [ :op | self op: op right: prec377 ]))
		/ prec377
]

{ #category : 'precedence' }
GplExpressionGrammar >> prec377 [
	^ subscript / precMax
]

{ #category : 'precedence' }
GplExpressionGrammar >> precMax [
	^ super expression / varName / parenthesis
]

{ #category : 'accessing' }
GplExpressionGrammar >> reservedNames [
	^ #('EXTERNAL' 'LOCAL' 'GLOBAL' 'NILADIC' 'MONADIC' 'DYADIC' 'PROCEDURE' 'FUNCTION' 'BOOLEAN' 'CHAR' 'INTEGER' 'INTEGER2' 'REAL' 'REAL2' 'IF' 'THEN' 'ELSE' 'ENDIF' 'DO' 'ENDDO' 'WHILE' 'UNTIL' 'SWITCH' 'OF' 'CASE' 'OUT' 'GOTO' 'ENDSUB')
]

{ #category : 'grammar' }
GplExpressionGrammar >> scalar [
	^ varName / scalarLiteral
]

{ #category : 'grammar' }
GplExpressionGrammar >> start [
	^ expression end
]

{ #category : 'grammar' }
GplExpressionGrammar >> statement [
	^ expression
]

{ #category : 'grammar' }
GplExpressionGrammar >> subroutineName [
	^ gdsName flatten
]

{ #category : 'grammar' }
GplExpressionGrammar >> subroutineType [
	^ (self tokenFor: 'PROCEDURE') / (self tokenFor: 'FUNCTION')
]

{ #category : 'grammar' }
GplExpressionGrammar >> subscript [
	"precendence 8r377"

	^ (self tokenFor: $[) , (list / numberVectorLiteral / scalar)
		, (self tokenFor: $])	"blankDelimiter star , "
	"blankDelimiter star, "
]

{ #category : 'grammar-arithmetic-dyadic' }
GplExpressionGrammar >> subtraction [
	^ self left: prec016 op: $- right: prec015
]

{ #category : 'grammar' }
GplExpressionGrammar >> varName [
	^ cantAssignNames not and , gdsName
]
