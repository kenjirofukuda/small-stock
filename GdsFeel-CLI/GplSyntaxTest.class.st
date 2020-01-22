Class {
	#name : #GplSyntaxTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #'as yet unclassified' }
GplSyntaxTest >> check: aGplStatement [
	| tokens |
	tokens := GplScanner tokensFrom: aGplStatement.
	model checkFromTokens: tokens.
]

{ #category : #running }
GplSyntaxTest >> setUp [
	super setUp.
	model := GplSyntax new.
	evaluator evaluateLine: 'A:=1'.
	model model: evaluator.
	
]

{ #category : #tests }
GplSyntaxTest >> testAssignCheck [

	"not presents ':=' "
	self shouldnt: [self check: 'PAN  0 0'] raise: GplSyntaxError .

	"missing both"
	self should: [self check: ':='] raise: GplSyntaxError .
	"missing right"
	self should: [self check: 'A :='] raise: GplSyntaxError .		
	"missing left"
	self should: [self check: ':= 1'] raise: GplSyntaxError .		
	"method name"
	self should: [self check: 'COORDS := 1'] raise: GplSyntaxError .	
	"method name with subscript "
	self should: [self check: 'COORDS[1] := 1'] raise: GplSyntaxError .		
	"left operand has function call"
	self should: [self check: '(A) := 1'] raise: GplSyntaxError .	
	"left operand has function call with subscript"
	self should: [self check: '(A)[1] := 1'] raise: GplSyntaxError .			
	"right operand has non return value operation like as procedure"
	self should: [self check: 'A := CLOSELIB'] raise: GplSyntaxError .
	self should: [self check: 'A := PAN'] raise: GplSyntaxError .
	self should: [self check: 'A := MARK'] raise: GplSyntaxError .
	
	"bi context handlers"
	self shouldnt: [self check: 'A := SETVIEW'] raise: GplSyntaxError .

	"function only"
	self shouldnt: [self check: 'A := DAY'] raise: GplSyntaxError .
	self shouldnt: [self check: 'A := TOD'] raise: GplSyntaxError .

	
]

{ #category : #tests }
GplSyntaxTest >> testDeclareCheck [

	self shouldnt: [self check: ''] raise: GplSyntaxError .
	self shouldnt: [self check: String tab] raise: GplSyntaxError .
	self shouldnt: [self check: String tab] raise: GplSyntaxError .
	
	self should: [self check: 'A := B'] raise: GplSyntaxError .
	self shouldnt: [self check: 'A[1] := 1'] raise: GplSyntaxError .
	self shouldnt: [self check: 'B := 1'] raise: GplSyntaxError .
	self shouldnt: [self check: '(1 2 3)[1]'] raise: GplSyntaxError .
	self shouldnt: [self check: 'A := (1 + 1)'] raise: GplSyntaxError .
	
	"not a command"
	self should: [self check: '(SETVIEW2)'] raise: GplSyntaxError .
	self should: [self check: 'CORDS'] raise: GplSyntaxError .


]

{ #category : #tests }
GplSyntaxTest >> testDepthCheck [

	
	"not presents ':=' "
	self shouldnt: [self check: 'PAN  0 0'] raise: GplSyntaxError .

	"corect case"
	self shouldnt: [self check: '([A + 1])'] raise: GplSyntaxError .

	"missing right parlen"
	self should: [self check: '([A + 1]'] raise: GplSyntaxError .

	"missing left parlen"
	self should: [self check: '[A + 1])'] raise: GplSyntaxError .

	"missing right subscript"
	self should: [self check: '([A + 1)'] raise: GplSyntaxError .

	"missing left subscript"
	self should: [self check: '(A + 1])'] raise: GplSyntaxError .

	"empty paren"
	self should: [self check: '(   )[A]'] raise: GplSyntaxError .
	self should: [self check: '()[A]'] raise: GplSyntaxError .

	"empty subscript"
	self should: [self check: '(A)[ ]'] raise: GplSyntaxError .
	self should: [self check: '(A)[    ]'] raise: GplSyntaxError .
	
	"mismatch "
	self should: [self check: '[(A + 1])'] raise: GplSyntaxError .

	"mismatch "
	self should: [self check: '([A + 1)]'] raise: GplSyntaxError .


]
