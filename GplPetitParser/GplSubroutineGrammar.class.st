Class {
	#name : 'GplSubroutineGrammar',
	#superclass : 'GplStatementsGrammar',
	#instVars : [
		'functionHeader',
		'procedureHeader',
		'niladicFunctionHeader',
		'monadicFunctionHeader',
		'dyadicFunctionHeader',
		'paramName',
		'niladicProcedureHeader',
		'monadicProcedureHeader',
		'variableDeclare',
		'program',
		'subroutineHeader',
		'declare',
		'symbolList',
		'storageScope',
		'externalSubroutineDeclare',
		'declares'
	],
	#category : 'GplPetitParser-Grammar',
	#package : 'GplPetitParser',
	#tag : 'Grammar'
}

{ #category : 'grammar' }
GplSubroutineGrammar >> declare [
	^ externalSubroutineDeclare / variableDeclare
]

{ #category : 'grammar' }
GplSubroutineGrammar >> declares [
	^ (self sourceLineOf: [ declare ]) delimitedBy: #newline asParser
]

{ #category : 'grammar' }
GplSubroutineGrammar >> dyadicFunctionHeader [
	"
DYADIC FUNCTION RESULT := PARAM1 FOO PARAM2
"

	^ 'DYADIC' asParser , blankDelimiter , 'FUNCTION' asParser
		, blankDelimiter , paramName , ':=' asParser , blankDelimiter
		, paramName , blankDelimiter , subroutineName , blankDelimiter
		, paramName
]

{ #category : 'grammar' }
GplSubroutineGrammar >> externalSubroutineDeclare [
	^ 'EXTERNAL' asParser , blankDelimiter , subroutineType
		, blankDelimiter , symbolList
]

{ #category : 'grammar' }
GplSubroutineGrammar >> functionHeader [
	"
NILADIC FUNCTION RESULT := FOO
MONADIC FUNCTION RESULT := FOO PARAM1
DYADIC FUNCTION RESULT := PARAM1 FOO PARAM2
"

	^ niladicFunctionHeader / monadicFunctionHeader
		/ dyadicFunctionHeader
]

{ #category : 'grammar' }
GplSubroutineGrammar >> inlineComment [
	^ $| asParser / $` asParser , #any asParser star
]

{ #category : 'grammar-function' }
GplSubroutineGrammar >> monadicFunctionHeader [
	"
MONADIC FUNCTION RESULT := FOO PARAM1
"

	^ 'MONADIC' asParser , blankDelimiter , 'FUNCTION' asParser
		, blankDelimiter , paramName , blankDelimiter optional
		, ':=' asParser , blankDelimiter optional , subroutineName
		, blankDelimiter , paramName
]

{ #category : 'grammar-procedure' }
GplSubroutineGrammar >> monadicProcedureHeader [
	"
MONADIC PROCEDURE FOO PARAM1
"

	^ 'MONADIC' asParser , blankDelimiter , 'PROCEDURE' asParser
		, blankDelimiter , subroutineName , blankDelimiter , paramName
]

{ #category : 'grammar-function' }
GplSubroutineGrammar >> niladicFunctionHeader [
	"
NILADIC FUNCTION RESULT := FOO
"

	^ 'NILADIC' asParser , blankDelimiter , 'FUNCTION' asParser
		, blankDelimiter , paramName , blankDelimiter optional
		, ':=' asParser , blankDelimiter optional , subroutineName
]

{ #category : 'grammar-procedure' }
GplSubroutineGrammar >> niladicProcedureHeader [
	"
NILADIC PROCEDURE FOO
"

	^ 'NILADIC' asParser , blankDelimiter , 'PROCEDURE' asParser
		, blankDelimiter , subroutineName
]

{ #category : 'grammar' }
GplSubroutineGrammar >> paramName [
	^ gdsName flatten
]

{ #category : 'grammar' }
GplSubroutineGrammar >> procedureHeader [
	"
NILADIC PROCEDURE FOO
MONADIC PROCEDURE FOO PARAM1
"

	^ niladicProcedureHeader / monadicProcedureHeader
]

{ #category : 'grammar' }
GplSubroutineGrammar >> program [
	^ subroutineHeader , declares , codeBlock
		, (blankDelimiter star , #newline asParser plus) , 'ENDSUB' asParser
]

{ #category : 'grammar' }
GplSubroutineGrammar >> start [
	^ program end
]

{ #category : 'grammar' }
GplSubroutineGrammar >> storageScope [
	^ 'EXTERNAL' asParser / 'GLOBAL' asParser / 'LOCAL' asParser
]

{ #category : 'grammar' }
GplSubroutineGrammar >> subroutineHeader [
	^ (self sourceLineOf: [ functionHeader / procedureHeader ])
		, #newline asParser
]

{ #category : 'grammar' }
GplSubroutineGrammar >> subroutinePrototype1 [
	^ 'EXTERNAL' asParser , blankDelimiter , subroutineHeader
]

{ #category : 'grammar' }
GplSubroutineGrammar >> subroutinePrototype2 [
	| cammaDelimiter |
	cammaDelimiter := (#blank asParser star , $, asParser
		, #blank asParser star) flatten.
	^ 'EXTERNAL' asParser , blankDelimiter
		,
			((operatorType separatedBy: cammaDelimiter) , blankDelimiter
				, subroutineType separatedBy: cammaDelimiter) , blankDelimiter
		, subroutineName
]

{ #category : 'grammar' }
GplSubroutineGrammar >> symbolList [
	| semicolonDelimiter |
	semicolonDelimiter := (#blank asParser star , $; asParser
		, #blank asParser star) flatten.
	^ varName separatedBy: semicolonDelimiter
]

{ #category : 'grammar' }
GplSubroutineGrammar >> variableDeclare [
	^ storageScope , blankDelimiter , symbolList
]
