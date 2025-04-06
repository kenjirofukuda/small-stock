Class {
	#name : #GplExpressionGrammarTest,
	#superclass : #PPCompositeParserTest,
	#category : #'GplPetitParser-Tests'
}

{ #category : #tests }
GplExpressionGrammarTest >> ignoreTestDyadicCall [
	"Tests GplExpressionGrammar>>#dyadicCall"

	self parse: '2 3 RESHAPE IOTA 10' rule: #dyadicCall.
	self parse: '(2 3) RESHAPE 			(IOTA 10)' rule: #dyadicCall.
	"self parse: '(2 3)RESHAPE(IOTA 10)' rule: #dyadicCall."
	self fail: '2 3RESHAPEIOTA 10' rule: #dyadicCall.
	self fail: '2 3 RESHAPE' rule: #dyadicCall.
	self fail: 'RESHAPE' rule: #dyadicCall.
	self fail: 'RESHAPE IOTA 10' rule: #dyadicCall
]

{ #category : #tests }
GplExpressionGrammarTest >> ignoreTestMonadicCall [
	"Tests GplExpressionGrammar>>#monadicCall"

	"self parse: '+1' rule: #monadicCall.
	self parse: '+ 1' rule: #monadicCall.
	self parse: '+ 1 1 1' rule: #monadicCall.
	self parse: '+ 1 2 3' rule: #monadicCall.
	self fail: '-1' rule: #monadicCall."

	self parse: 'IOTA 10' rule: #monadicCall.
	self parse: 'IOTA 1 10' rule: #monadicCall.
	self parse: 'IOTA 1 2 10' rule: #monadicCall.
	"self parse: 'IOTA(10)' rule: #monadicCall."
	self fail: 'IOTA[10]' rule: #monadicCall.
	self fail: 'IOTA)10(' rule: #monadicCall.
	self fail: 'IOTA10' rule: #monadicCall.
	self fail: '10 IOTA 10' rule: #monadicCall.
	self fail: 'IOTA' rule: #monadicCall.
	self fail: '10 IOTA' rule: #monadicCall
]

{ #category : #tests }
GplExpressionGrammarTest >> ignoreTestNiladicCall [
	"Tests GplExpressionGrammar>>#niladicCall"

	self parse: 'TOD' rule: #niladicCall.
	self fail: 'TOD 1' rule: #niladicCall.
	self fail: '1 TOD 1' rule: #niladicCall.
	self fail: '1 TOD' rule: #niladicCall.
	self fail: 'RESHAPE' rule: #niladicCall
]

{ #category : #accessing }
GplExpressionGrammarTest >> parserClass [
	^ GplExpressionGrammar
]

{ #category : #tests }
GplExpressionGrammarTest >> testAddition [
	"Tests GplExpressionGrammar>>#addition"

	self parse: '1+1' rule: #addition.
	self parse: '(1+1)+1' rule: #addition.
	self parse: '1+(1+1)' rule: #addition.
	self parse: '1+1+1' rule: #expression.
	self parse: '1 +1' rule: #addition.
	self parse: '1+ 1' rule: #addition.
	self parse: '1 + 1' rule: #addition.
	self parse: '1+1 2 3 4' rule: #addition.
	self parse: '1 2 3 4 + 1.0' rule: #addition.
	self parse: 'A + 1' rule: #addition
]

{ #category : #tests }
GplExpressionGrammarTest >> testArrayConcatenate [
	"Tests GplExpressionGrammar>>#arrayConcatenate"

	self parse: '1,1' rule: #arrayConcatenate.
	self parse: '1 ,	1' rule: #arrayConcatenate.
	self parse: '1,2,3' rule: #expression
]

{ #category : #tests }
GplExpressionGrammarTest >> testAssignment [
	"Tests GplExpressionGrammar>>#assignment"

	self parse: 'A := 1' rule: #assignment.
	self parse: 'A := B := C := 1' rule: #assignment.
	self parse: 'A := IOTA 10' rule: #assignment.
	self parse: 'A:=1' rule: #assignment.
	self parse: 'A[1]:=1' rule: #assignment.
	self parse: 'A[1;2]:=1' rule: #assignment.
	self parse: 'A[B]:=1' rule: #assignment.
	self parse: 'A[B] := "GPLII"' rule: #assignment.
	self parse: 'AA := AA + 1' rule: #assignment.

	"can't assign"
	"Literal"
	self fail: '3 4 := AA + 1' rule: #assignment.
	"FlowControl"
	self fail: 'IF := 1' rule: #assignment.
	self fail: 'THEN := 1' rule: #assignment.
	"storage scope"
	self fail: 'EXTERNAL := 1' rule: #assignment.
	self fail: 'LOCAL := 1' rule: #assignment.
	"data type"
	self fail: 'BOOLEAN := 1' rule: #assignment.

	"builtin operator"
	self fail: 'IOTA := 1' rule: #assignment.
	self fail: 'RESHAPE := 1' rule: #assignment
]

{ #category : #tests }
GplExpressionGrammarTest >> testAssignment2 [
	self parse: 'A:=1' rule: #assignment
]

{ #category : #tests }
GplExpressionGrammarTest >> testAssignment3 [
	self parse: ' A:=1' rule: #assignment
]

{ #category : #tests }
GplExpressionGrammarTest >> testAssignment4 [
	self parse: ' A:=1 ' rule: #assignment
]

{ #category : #tests }
GplExpressionGrammarTest >> testAssignment5 [
	self
		parse:
			' A 
:= 1 '
		rule: #assignment
]

{ #category : #tests }
GplExpressionGrammarTest >> testBuiltinOperatorNames [
	"Tests GplExpressionGrammar>>#prec015"

	GplExpressionGrammar new builtinOperatorNames inspect
]

{ #category : #tests }
GplExpressionGrammarTest >> testExpression [
	"Tests GplExpressionGrammar>>#value"

	self parse: '1+1+1' rule: #expression.
	self parse: '1 + 2 + 3' rule: #expression.
	self parse: '1*1*1' rule: #expression.
	self parse: '1 * 2 * 3' rule: #expression.
	self parse: '1;1;1' rule: #expression.
	self parse: '1 ; 1 ; 1' rule: #expression
]

{ #category : #tests }
GplExpressionGrammarTest >> testGdsName [
	self parse: 'A' rule: #gdsName.

	"can't use lowercase. but..."
	self fail: 'a' rule: #gdsName.
	self fail: '1A' rule: #gdsName.

	"disallow top _"
	self fail: '_MACRO_LIKE_' rule: #gdsName.
	self parse: 'MACRO_LIKE_' rule: #gdsName.
	self fail: '$' rule: #gdsName.	"really?"
	self parse: 'A$NAME' rule: #gdsName.

	"over 32"
	self
		fail:
			'A$NAME121212121212121111111111111111111111111111111111111111111111111111111111111'
		rule: #gdsName
]

{ #category : #tests }
GplExpressionGrammarTest >> testList [
	"Tests GplExpressionGrammar>>#list"

	self parse: '1;1' rule: #list.
	self parse: '1;1;1' rule: #expression.
	self parse: '1;(1;1)' rule: #list.
	self parse: '(1; 1);1' rule: #list
]

{ #category : #tests }
GplExpressionGrammarTest >> testListLiteral [
	"Tests GplLiteralGrammar>>#listLiteral"

	self parse: '1;2' rule: #listLiteral.
	self parse: '1 ;2' rule: #listLiteral.
	self parse: '1 ; 2' rule: #listLiteral.
	self parse: '1 ; 2; 3' rule: #listLiteral.
	self parse: '"HOGE" ; 2; 1.0 2.0' rule: #listLiteral
]

{ #category : #tests }
GplExpressionGrammarTest >> testMultiplication [
	"Tests GplExpressionGrammar>>#multiplication"

	self parse: '1*1' rule: #multiplication.
	self parse: '1 *1' rule: #multiplication.
	self parse: '1* 1' rule: #multiplication.
	self parse: '1 * 1' rule: #multiplication.
	self parse: '1*1 2 3 4' rule: #multiplication.
	self parse: '1 2 3 4 * 1.0' rule: #multiplication
]

{ #category : #tests }
GplExpressionGrammarTest >> testParlen [
	"Tests GplExpressionGrammar>>#parlen"

	self fail: '()' rule: #parenthesis.
	self parse: '(1)' rule: #parenthesis.
	self parse: '( 1)' rule: #parenthesis.
	self parse: '(1 )' rule: #parenthesis.
	self parse: '((1 + 1) * 3)' rule: #parenthesis.
	self parse: '(1 + 1 * 3)' rule: #parenthesis
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec007 [
	"Tests GplExpressionGrammar>>#prec007"

	self parse: '2 RESHAPE 4' rule: #prec007.
	self parse: '2 3 RESHAPE 1 2 3 4 5' rule: #prec007.
	self parse: '1 2 INDEXOF 1 2 3 4 5' rule: #prec007
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec010 [
	"Tests GplExpressionGrammar>>#prec010"

	self parse: 'IOTA 10' rule: #prec010.
	self parse: 'SHAPE 1' rule: #prec010.
	self parse: 'LENGTH "DARKER THAN BLACK"' rule: #prec010
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec012 [
	"Tests GplExpressionGrammar>>#prec012"

	self parse: '3 OR 4' rule: #prec012.
	self parse: '3 XOR 4' rule: #prec012.
	self parse: '3 NOR 4' rule: #prec012
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec013 [
	"Tests GplExpressionGrammar>>#prec013"

	self parse: '1 EQ 1' rule: #prec013.
	self parse: '1 GEQ 1' rule: #prec013.
	self parse: '1 GT 1' rule: #prec013.
	self parse: '1 IN 1 2 3 4 5' rule: #prec013.
	self parse: '1 LEQ 1' rule: #prec013.
	self parse: '1 NEQ 1' rule: #prec013.
	self parse: '1 = TRUE' rule: #prec013.
	self parse: '1 < 1' rule: #prec013.
	self parse: '1 > 1' rule: #prec013.
	self parse: '1 < 1' rule: #prec013.
	self parse: '1 >= 1' rule: #prec013.
	self parse: '1 <> 1' rule: #prec013
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec015 [
	"Tests GplExpressionGrammar>>#prec015"

	self parse: '1 + 2' rule: #prec015.
	self parse: '1+2' rule: #prec015.
	self parse: '1 - 2' rule: #prec015.
	self parse: '1-2' rule: #prec015	"Error"
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec016 [
	"Tests GplExpressionGrammar>>#prec016"

	self parse: '1 * 1' rule: #prec016.
	self parse: '1 % 1' rule: #prec016
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec017 [
	"Tests GplExpressionGrammar>>#prec017"

	self parse: '1 LOGBASE 10' rule: #prec017.
	self parse: '1 POWER 10' rule: #prec017
]

{ #category : #tests }
GplExpressionGrammarTest >> testPrec020 [
	"Tests GplExpressionGrammar>>#prec020"

	self parse: '+ 1 2 3' rule: #prec020.
	self parse: '- 1 2 3' rule: #prec020.
	self parse: '* 1 2 3' rule: #prec020.
	self parse: '% 1 2 3' rule: #prec020.
	self parse: 'ABS 1 2 3' rule: #prec020.
	self parse: 'SIN 90.' rule: #prec020.
	self parse: 'COS 90.' rule: #prec020.
	self parse: 'TAN 90.' rule: #prec020
]

{ #category : #tests }
GplExpressionGrammarTest >> testSubscript [
	"Tests GplExpressionGrammar>>#subscript"

	self parse: '[VARIABLE_NAME]' rule: #subscript.
	self parse: '[ VARIABLE_NAME ]' rule: #subscript.
	self parse: '[1]' rule: #subscript.
	self parse: '[1 2 3]' rule: #subscript.
	self parse: '[1;3]' rule: #subscript.
	self parse: '[ 1;3 ]' rule: #subscript.
	self parse: '[ 1 ;3 ]' rule: #subscript.
	self fail: '[ VARIABLE_NAME' rule: #subscript.
	self fail: 'VARIABLE_NAME]' rule: #subscript
]

{ #category : #tests }
GplExpressionGrammarTest >> testSubtraction [
	"Tests GplExpressionGrammar>>#subtraction"

	self parse: '1-1' rule: #subtraction.
	self parse: '1 -1' rule: #numberVectorLiteral.
	self parse: '1- 1' rule: #subtraction.
	self parse: '1 - 1' rule: #subtraction.
	self parse: '1-1 2 3 4' rule: #subtraction.
	self parse: '1 2 3 4 - 1.0' rule: #subtraction
]

{ #category : #tests }
GplExpressionGrammarTest >> testVarName [
	self parse: 'A' rule: #varName.

	"builtin operator dissallow"
	self fail: 'IOTA' rule: #varName.
	self fail: 'RESHAPE' rule: #varName.

	"reserved keyword "
	self fail: 'IF' rule: #varName.
	self fail: 'BOOLEAN' rule: #varName.

	"can't use lowercase. but..."
	self fail: 'a' rule: #varName.
	self fail: '1A' rule: #varName.

	"disallow top _"
	self fail: '_MACRO_LIKE_' rule: #varName.
	self parse: 'MACRO_LIKE_' rule: #varName.
	self fail: '$' rule: #varName.	"really?"
	self parse: 'A$NAME' rule: #varName.

	"over 32"
	self
		fail:
			'A$NAME121212121212121111111111111111111111111111111111111111111111111111111111111'
		rule: #varName
]
