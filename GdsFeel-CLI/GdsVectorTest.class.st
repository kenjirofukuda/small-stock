Class {
	#name : #GdsVectorTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #tests }
GdsVectorTest >> testApplySymbolTo [
	| expResult result |	
	"{vector} {scalr}"
	expResult := #(2.0 3.0 4.0).
	result := ((#(1 2 3) asGdsValue)  applySymbol: #+ to: (1 asGdsValue) ) asSmalltalkValue.
	self assert: result = expResult.

	"{vector} {vector}"
	expResult := #(5.0 7.0 9.0).
	result := ((#(1 2 3) asGdsValue)  applySymbol: #+ to: (#(4 5 6) asGdsValue) ) asSmalltalkValue.
	self assert: result = expResult.

	"{vector} {scalr}"
	expResult := #(0.0 1.0 2.0).
	result := ((#(1 2 3) asGdsValue)  applySymbol: #- to: (1 asGdsValue) ) asSmalltalkValue.
	self assert: result = expResult.

	"{vector} {vector}"
	expResult := #(-3.0 -3.0 -3.0).
	result := ((#(1 2 3) asGdsValue)  applySymbol: #- to: (#(4 5 6) asGdsValue) ) asSmalltalkValue.
	self assert: result = expResult.

	"{illigal data}"
	self should: [(#(1 2 3) asGdsValue)  applySymbol: #- to: GdsNull instance ] raise: GplError.

	"{illigal data}"
	self should: [(#(1 2 3) asGdsValue)  applySymbol: #- to: (GdsString fromLiteral: '"ABC"') ] raise: GplError.
	
	"{illigal size}"
	self should: [(#(1 2 3) asGdsValue)  applySymbol: #- to: (#(4 5 6 7) asGdsValue) ] raise: GplError

]

{ #category : #tests }
GdsVectorTest >> testAtSubscript [
	self assert: ((GdsVector fromLiteral: '1 2 3') atSubscript: (1 asGdsValue)) asSmalltalkValue = 1.
	self shouldnt: [evaluator evaluateLine: '(1 2 3)[1]' ] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '(1 2 3)[]' ] raise: GplRuntimeError.
	self shouldnt: [evaluator evaluateLine: '(1 2 3)[1.0]' ] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '(1 2 3)[""]' ] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '(1 2 3)[0]' ] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '(1 2 3)[4]' ] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '(1 2 3)[-1]' ] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '(1 2 3)[1;]' ] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '(1 2 3)[;1]' ] raise: GplRuntimeError.

	evaluator evaluateLine: 'V := IOTA 3'.	
	"out of range"	
	self should: [evaluator evaluateLine: 'V[0]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V[4]'] raise: GplRuntimeError.
	"empty sabscript"
	self should: [evaluator evaluateLine: 'V[]'] raise: GplRuntimeError.

	"illigal data mode"
	self should: [evaluator evaluateLine: 'V[""]'] raise: GplRuntimeError.
	self shouldnt: [evaluator evaluateLine: 'V[1.0]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V[1.1]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V["ABC"]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V["1 2 3"]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V[2 1 RESHAPE 1]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V[1 2 RESHAPE 1]'] raise: GplRuntimeError.

	"list access"
	self should: [evaluator evaluateLine: 'V[;]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V[3;]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V[;4]'] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: 'V[3;4]'] raise: GplRuntimeError.

]

{ #category : #tests }
GdsVectorTest >> testFromLiteral [
	| result expResult |
	expResult := GdsVector fromLiteral: '1. 1. 0. 1.'.
	result := GdsVector fromLiteral: '1 TRUE FALSE 1.0'.
	self assert: result = expResult.
	self should: [GdsVector fromLiteral: '""'] raise: GplSyntaxError .
	self should: [GdsVector fromLiteral: '"ABC"'] raise: GplSyntaxError
]

{ #category : #tests }
GdsVectorTest >> testIsAcceptableSmalltalkObject [
	self assert: [(GdsVector isAcceptableSmalltalkObject: 1) = false]
		description: 'Vector not aceptable scalar value'.
	self assert: 
			[(GdsVector isAcceptableSmalltalkObject: #(
						1
						$a
						'abc'
						#baka
					)) 
				= false]
		description: 'Vector not aceptable non number value'.
	self 
		assert: [(GdsVector isAcceptableSmalltalkObject: #(false true false )) = true]
		description: 'Vector not aceptable boolean collection'.
	self assert: 
			[(GdsVector isAcceptableSmalltalkObject: #(
						1
						2
						3
						4
						5.0
						6.0
					)) 
				= true]
		description: 'Vector not aceptable non number value'.
	self assert: [(GdsVector isAcceptableSmalltalkObject: #()) = false]
		description: 'Vector not aceptable empty collection'
]

{ #category : #tests }
GdsVectorTest >> testIsList [
	self deny: (GdsVector fromLiteral: '1 1 1 1') isList.

]

{ #category : #tests }
GdsVectorTest >> testLength [
	self assert: (GdsVector fromLiteral: '1 ') length = 1.
	self assert: (GdsVector fromLiteral: '1 1 ') length = 1.
	self assert: (GdsVector fromLiteral: '1 1 1') length = 1.

]

{ #category : #tests }
GdsVectorTest >> testMode [
	self assert: (GdsVector fromLiteral: '1 1 1 1') mode = 1.
	self assert: (GdsVector fromLiteral: '1 1 1 1.0') mode = 3
]

{ #category : #tests }
GdsVectorTest >> testShape [
	self assert: (GdsVector fromLiteral: '1 1 1 1') shape = 4.
	self assert: (GdsVector fromLiteral: '1 1 1 1.0 5.0') shape = 5
]

{ #category : #tests }
GdsVectorTest >> testSign [
	| result expResult |
	expResult := GdsVector fromLiteral: '-1 0 1 1'.
	result := (GdsVector fromLiteral: '-1 0 8 3') sign.
	self assert: result = expResult.

]

{ #category : #tests }
GdsVectorTest >> testSize [
	self assert: (GdsVector fromLiteral: '1 1 1 1') size = 4.
	self assert: (GdsVector fromLiteral: '1 1 1 1.0 5.0') size = 5
]

{ #category : #tests }
GdsVectorTest >> testTypeString [
	self assert: (GdsVector fromLiteral: '1 1 1 1') typeString = 'LOGICAL'.
	self assert: (GdsVector fromLiteral: '1 1 1 1.0 5.0') typeString = 'REAL'.
	self assert: (GdsVector fromLiteral: '1 1 256 1') typeString = 'INTEGER'
]
