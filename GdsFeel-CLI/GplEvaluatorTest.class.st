Class {
	#name : 'GplEvaluatorTest',
	#superclass : 'GdsTestCase',
	#category : 'GdsFeel-CLI-Test',
	#package : 'GdsFeel-CLI',
	#tag : 'Test'
}

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluateConsoleLine [
	| input result expResult |
	input := '1'.
	expResult := '1'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := '1.00000000'.
	expResult := '1.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := '0.0'.
	expResult := '0.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := '0.01'.
	expResult := '.01'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := 'FALSE'.
	expResult := '0'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := 'TRUE'.
	expResult := '1'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := 'true'.	"disallow lowercase"
	expResult := '1'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result ~= expResult.
	input := 'false'.	"disallow lowercase"
	expResult := '0'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result ~= expResult.
	input := '"GDSII"'.
	expResult := 'GDSII'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := '"GDSII"[1]'.
	expResult := 'G'.
	result := evaluator evaluateConsoleLine: input.
	self
		assert: result = expResult
		description: 'vector [] operation must impiment'.
	input := '1 + 1'.
	expResult := '2'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result ~= expResult.
	input := '1 + 1'.
	expResult := '2.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := '+ 1.0'.
	expResult := '1'.	"monadic + is most compact value "
	result := evaluator evaluateConsoleLine: input.
	self
		assert: result = expResult
		description: 'monadic + must implement'.
	input := '5 - 9'.
	expResult := '-4.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := '5-9'.
	expResult := '5 -9'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult.
	input := '5- 9'.
	expResult := '-4.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluateJoinVector [
	self should: [ evaluator evaluateLine: '"ABC" ,1' ] raise: GplError.
	self should: [ evaluator evaluateLine: '1, "ABC"' ] raise: GplError.
	self
		assert: (evaluator evaluateLine: '1, 1.0 2') gplString = '1. 1. 2.'.
	self assert: (evaluator evaluateLine: '1 1, 2') gplString = '1 1 2'.
	self
		assert: (evaluator evaluateLine: '"ABC", "DEF"') gplString = 'ABCDEF'
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePower1 [
	self
		shouldnt: [ evaluator evaluateLine: '2 POWER 16' ]
		raise: GplRuntimeError
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePower2 [
	self
		shouldnt: [ evaluator evaluateLine: '2 POWER 32' ]
		raise: GplRuntimeError
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePower3 [
	self
		should: [ evaluator evaluateLine: 'POWER ' ]
		raise: GplRuntimeError
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePower4 [
	"missing right"

	self
		should: [ evaluator evaluateLine: '2 POWER ' ]
		raise: GplRuntimeError
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePower5 [
	"missing left"

	self
		should: [ evaluator evaluateLine: 'POWER 32' ]
		raise: GplRuntimeError
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePowerScalar1 [
	| input result expResult |
	input := '2 POWER 5'.
	expResult := '32.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePowerScalar2 [
	| input result expResult |
	input := '13 POWER 2'.
	expResult := '169.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePowerScalar3 [
	| input result expResult |
	input := '5 POWER 3'.
	expResult := '125.'.
	result := evaluator evaluateConsoleLine: input.
	self assert: result = expResult
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluatePowerVector1 [
	| input result expResult |
	input := '2 13 5 POWER 5 2 3'.
	expResult := '32. 169. 125.'.
	"result := evaluator evaluateConsoleLine: input."
	result := evaluator evaluateLine: input.
	self assert: result = expResult
]

{ #category : 'tests' }
GplEvaluatorTest >> testEvaluateReshape [
	self
		should: [ evaluator evaluateLine: 'RESHAPE ' ]
		raise: GplRuntimeError.

	"missing right"
	self
		should: [ evaluator evaluateLine: '2 3 RESHAPE ' ]
		raise: GplRuntimeError.

	"missing left"
	self
		should: [ evaluator evaluateLine: 'RESHAPE IOTA 3' ]
		raise: GplRuntimeError.

	"NULL Vector"
	self
		should: [ evaluator evaluateLine: '"" RESHAPE IOTA 3' ]
		raise: GplRuntimeError.

	"Real mode Vector"
	self
		should: [ evaluator evaluateLine: '2.0 3.5 RESHAPE IOTA 3' ]
		raise: GplRuntimeError.

	"Character mode Vector"
	self
		should: [ evaluator evaluateLine: '"A B" RESHAPE IOTA 3' ]
		raise: GplRuntimeError.

	"left operands vector max size  =  2"
	self
		should: [ evaluator evaluateLine: '2 3 4 RESHAPE IOTA 3' ]
		raise: GplRuntimeError.

	"not a array"
	self
		should: [ evaluator evaluateLine: '2 3 RESHAPE ("ABC" ; 1 2 3) ' ]
		raise: GplRuntimeError
]

{ #category : 'tests' }
GplEvaluatorTest >> testMonadicPlusSign [
	| input result expResult |
	input := '+ 1'.
	expResult := '1'.	"http://gdsfeel.com/yota/?IdentifyOperator"
	result := evaluator evaluateConsoleLine: input.
	self
		assert: result = expResult
		description: 'monadic + must implement'.
	input := '+ 1.'.
	expResult := '1'.
	result := evaluator evaluateConsoleLine: input.
	self
		assert: result = expResult
		description: 'monadic + must implement'.
	input := '+1 -3'.
	expResult := '1 -3'.
	result := evaluator evaluateConsoleLine: input.
	self
		assert: result = expResult
		description: 'monadic + must implement'
]
