Class {
	#name : #GdsScalarTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #tests }
GdsScalarTest >> testApplySymbolTo [
	| expResult result |
	
	"not a GdsDataStructure"
	self should: [(1 asGdsValue applySymbol: #+ to: 1) ] raise: Exception.

	"not a GdsDataStructure"
	self should: [(1 asGdsValue applySymbol: #+ to: GdsNull instance) ] raise: Exception.

	
	"{scalar} {scalar}"
	expResult := 2.0.
	result := (1 asGdsValue applySymbol: #+ to: (1 asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.
	
	"{scalar} {vector}"
	expResult := #(2.0 3.0).
	result := (1 asGdsValue applySymbol: #+ to: (#(1 2) asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.

	"{scalar} {scalar}"
	expResult := 0.0.
	result := (1 asGdsValue applySymbol: #- to: (1 asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.
	
	"{scalar} {vector}"
	expResult := #(0.0 -1.0).
	result := (1 asGdsValue applySymbol: #- to: (#(1 2) asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.

	"{scalar} {scalar}"
	expResult := 1.0.
	result := (1 asGdsValue applySymbol: #* to: (1 asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.
	
	"{scalar} {vector}"
	"? 2 * 1 2"
	"2. 4."
	expResult := #(2.0 4.0).
	result := (2 asGdsValue applySymbol: #* to: (#(1 2) asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.

	"{scalar} {scalar}"
	"? 1 % 1"
	"1."
	expResult := 1.0.
	result := (1 asGdsValue applySymbol: #% to: (1 asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.
	
	"{scalar} {vector}"
	"? 1 % 1 2"
	"1.0 0.5"
	expResult := #(1.0 0.5).
	result := (1 asGdsValue applySymbol: #% to: (#(1 2) asGdsValue)) asSmalltalkValue.
	self assert: result = expResult.

	"other alithmetic operator"
	self should: [(1 asGdsValue applySymbol: #/ to: (1 asGdsValue)) ] raise: Exception.
	self should: [(1 asGdsValue applySymbol: #// to: (1 asGdsValue)) ] raise: Exception.
	self should: [(1 asGdsValue applySymbol: #\\ to: (1 asGdsValue)) ] raise: Exception.
	

]

{ #category : #tests }
GdsScalarTest >> testAtSubscript [
	self should: [1 asGdsValue atSubscript: (1 asGdsValue)] raise: GplRuntimeError.
	self should: [1.0 asGdsValue atSubscript: (#(1 2) asGdsValue)] raise: GplRuntimeError.
	self should: [$a asGdsValue atSubscript: (GdsNull instance)] raise: GplRuntimeError.
	
	evaluator evaluateLine: 'S := 1'.	
	self should: [evaluator evaluateLine: 'S[1]'] raise: GplRuntimeError.


]

{ #category : #tests }
GdsScalarTest >> testIsList [			
	self deny: (1.0 asGdsValue)  isList.
]

{ #category : #tests }
GdsScalarTest >> testLength [
	self assert: (1 asGdsValue) length = 1.
	self assert: (1.0 asGdsValue) length = 1.	
	self assert: (true asGdsValue) length = 1.	
	self assert: (false asGdsValue) length = 1.		
	self assert: ($a asGdsValue) length = 1.		
		
]

{ #category : #tests }
GdsScalarTest >> testMostCompactValue [
	self assert:  0.0 asGdsValue mostCompactValue = (false asGdsValue).
	self assert:  0.1 asGdsValue mostCompactValue = (0.1 asGdsValue).
	self assert:  1.0 asGdsValue mostCompactValue = (true asGdsValue).
	self assert:  1.1 asGdsValue mostCompactValue = (1.1 asGdsValue).
	self assert:  2.0 asGdsValue mostCompactValue = (2 asGdsValue).
	self assert:  2.1 asGdsValue mostCompactValue = (2.1 asGdsValue).
	
	

]

{ #category : #tests }
GdsScalarTest >> testSign [
	self assert:  0.0 asGdsValue sign = (GdsInteger fromSmalltalk: 0).
	self assert:  0 asGdsValue sign = (GdsInteger fromSmalltalk: 0).
	self assert:  -100 asGdsValue sign = (GdsInteger fromSmalltalk: -1).
	self assert:  100 asGdsValue sign = (GdsInteger fromSmalltalk: 1).
	

]
