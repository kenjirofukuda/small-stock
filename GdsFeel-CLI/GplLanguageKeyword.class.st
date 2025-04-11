Class {
	#name : 'GplLanguageKeyword',
	#superclass : 'GplSyntaxEntity',
	#instVars : [
		'parent'
	],
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplLanguageKeyword class >> specText [
	^ '
ABS
ARCTAN
BOOLEAN
COS
DROP
EQ
EXTERNAL
ENDSWITCH
FUNCTION
GRASEDOWN
GLOBAL
IN
LN
LT
MAX
MASK
NEQ
NOT
PI
RANK
RESHAPE
(*) SIGNUM
SORT
SCALAR
THEN
XOR
WHILE
NILADIC
SCALAR
REAL
LOGICAL
ENDSUB
(+) ADDITION 
(:=) ASSIGNMENT
CEILING
DEC
DYADIC 
EXP
ELIF 
FALSE 
FILE
GRADEUP
GOTO
INDEXOF
LOGBASE
LIST
MIN
MOD
NOR
MONADIC
POWER
(,) RAVEL
REAL 
SIN
SORTDOWN 
(-) SUBTRACTION 
TAKE
UNTIL
SWITCH 
INTEGER
OF 
TRUE 
VECTOR
AND
ARRAY 
CHAR 
(%) DIVISION 
DO 
ENDDO 
ELSE 
FLOOR 
GEQ 
GT 
(+) IDENTITY 
IOTA 
(;) LIST CONCATENATION 
LOCAL 
(*) MULTIPLICATION 
NAND 
(-) (II) NEGATION 
OR 
PROCEDURE 
(%) RECIPROCAL 
SHAPE 
SIZE 
[] SUBSCRIPTION 
TAN 
TYPEOF 
(,) VECTOR CONCATENATION 
OUT 
CASE 
ERRTRAP 
ENDIF 
CASE 

	'
]

{ #category : 'as yet unclassified' }
GplLanguageKeyword >> foo [
	
]

{ #category : 'as yet unclassified' }
GplLanguageKeyword >> parent: aGplLanguageKeyword [
	parent := aGplLanguageKeyword
]

{ #category : 'as yet unclassified' }
GplLanguageKeyword >> printOn: aStream [
	aStream nextPutAll: 'KW['.
	aStream nextPutAll: self string printString.
	aStream nextPutAll: ']'
]
