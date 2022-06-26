Class {
	#name : #GdsRealTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #test }
GdsRealTest >> testAcceptableExpression [
	| input result expResult |
	input := '1'.
	expResult := true.
	result := GdsReal acceptableExpression: input.
	self assert: result = expResult.
	input := '-1'.
	expResult := true.
	result := GdsReal acceptableExpression: input.
	self assert: result = expResult.
	input := '+1'.
	expResult := false.	"cant use +sign "
	result := GdsReal acceptableExpression: input.
	self assert: result = expResult.
	input := '1.0'.
	expResult := true.
	result := GdsReal acceptableExpression: input.
	self assert: result = expResult.
	input := '1E-17'.
	expResult := true.
	result := GdsReal acceptableExpression: input.
	self assert: result = expResult.
	input := '1E+17'.
	expResult := true.
	result := GdsReal acceptableExpression: input.
	self
		deny: [ result = expResult ]
		description: 'can''t use exponensial + sign'.
	input := '-1.0E+17'.
	expResult := true.
	result := GdsReal acceptableExpression: input.
	self deny: result = expResult.
	input := '-1.0e+17'.	"disallow lowercase e on GPL"
	expResult := false.
	result := GdsReal acceptableExpression: input.
	self assert: result = expResult
]

{ #category : #test }
GdsRealTest >> testFromLiteral [
	self
		assert: ((GdsReal fromLiteral: '1') asSmalltalkValue isKindOf: Float).
	self should: [ GdsReal fromLiteral: 'TRUE' ] raise: GplSyntaxError.
	self should: [ GdsReal fromLiteral: '+1.0' ] raise: GplSyntaxError.
	self shouldnt: [ GdsReal fromLiteral: '-1.0' ] raise: GplSyntaxError.
	self shouldnt: [ GdsReal fromLiteral: '1E16' ] raise: GplSyntaxError.
	self should: [ GdsReal fromLiteral: '1E+16' ] raise: GplSyntaxError.
	self should: [ GdsReal fromLiteral: '1e-16' ] raise: GplSyntaxError.

	"dot start. dot end"
	self assert: (GdsReal fromLiteral: '.5') asSmalltalkValue = 0.5.
	self assert: (GdsReal fromLiteral: '5.') asSmalltalkValue = 5.0.

	"trim Zero"
	self assert: (GdsReal fromLiteral: '1.000000') gplString = '1.'.
	self assert: (GdsReal fromLiteral: '0.000000') gplString = '0.'.
	self assert: (GdsReal fromLiteral: '0.1234') gplString = '.1234'
]

{ #category : #test }
GdsRealTest >> testIsList [
	self deny: (GdsReal fromLiteral: '1.0') isList
]

{ #category : #test }
GdsRealTest >> testLength [
	self assert: 1.0 asGdsValue length = 1
]

{ #category : #test }
GdsRealTest >> testMode [
	self assert: (GdsReal fromLiteral: '1.0') mode = 3
]

{ #category : #test }
GdsRealTest >> testRank [
	self assert: (GdsReal fromLiteral: '1.0') rank = 0.
	self
		assert:
			(GdsReal fromLiteral: '1.0') rank
				= (GdsReal fromLiteral: '1E-16') rank
]

{ #category : #test }
GdsRealTest >> testShape [
	self assert: (GdsReal fromLiteral: '1.0') shape = #()
]

{ #category : #test }
GdsRealTest >> testSize [
	self assert: (GdsReal fromLiteral: '1.0') size = 1
]

{ #category : #test }
GdsRealTest >> testTypeString [
	self assert: (GdsReal fromLiteral: '1.0') typeString = 'REAL'
]
