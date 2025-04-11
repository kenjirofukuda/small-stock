Class {
	#name : 'GdsIntegerTest',
	#superclass : 'GdsTestCase',
	#category : 'GdsFeel-CLI-Test',
	#package : 'GdsFeel-CLI',
	#tag : 'Test'
}

{ #category : 'test' }
GdsIntegerTest >> testAcceptableExpression [
	| input result expResult |
	input := '1'.
	expResult := true.
	result := GdsInteger acceptableExpression: input.
	self assert: result = expResult.
	input := '1.0'.
	expResult := false.
	result := GdsInteger acceptableExpression: input.
	self assert: result = expResult.
	input := '+1'.
	expResult := true.
	result := GdsInteger acceptableExpression: input.
	self deny: result = expResult description: 'can''t use + sign'.
	input := '32767'.
	expResult := true.
	result := GdsInteger acceptableExpression: input.
	self assert: result = expResult.
	input := '32768'.	"overflow "
	expResult := false.
	result := GdsInteger acceptableExpression: input.
	self assert: result = expResult.
	input := '-32768'.	" "
	expResult := true.
	result := GdsInteger acceptableExpression: input.
	self assert: result = expResult.
	input := '-32769'.	" "
	expResult := false.
	result := GdsInteger acceptableExpression: input.
	self assert: result = expResult.
	input := '1E-17'.	"disallow floating point"
	expResult := false.
	result := GdsInteger acceptableExpression: input.
	self assert: result = expResult
]

{ #category : 'test' }
GdsIntegerTest >> testFromLiteral [
	self assert: (GdsInteger fromLiteral: '1') asSmalltalkValue = 1.
	self assert: (GdsInteger fromLiteral: '0') asSmalltalkValue = 0.
	self
		assert: (GdsInteger fromLiteral: '0000000001') asSmalltalkValue = 1.
	self
		assert: (GdsInteger fromLiteral: '-32768') asSmalltalkValue = -32768.

	"cant use + sign"
	self
		should: [ GdsInteger fromLiteral: '+32767' ]
		raise: GplSyntaxError.
	self should: [ GdsInteger fromLiteral: '1.0' ] raise: GplSyntaxError.

	"currently spec. both side space is error"
	self should: [ GdsInteger fromLiteral: ' 1' ] raise: GplSyntaxError.
	self should: [ GdsInteger fromLiteral: '1 ' ] raise: GplSyntaxError.
	self should: [ GdsInteger fromLiteral: ' 1 ' ] raise: GplSyntaxError
]

{ #category : 'test' }
GdsIntegerTest >> testIsList [
	self deny: (GdsInteger fromLiteral: '1') isList
]

{ #category : 'test' }
GdsIntegerTest >> testMode [
	self assert: (GdsInteger fromLiteral: '1') mode = 2
]

{ #category : 'test' }
GdsIntegerTest >> testRank [
	self assert: (GdsInteger fromLiteral: '1') rank = 0
]

{ #category : 'test' }
GdsIntegerTest >> testShape [
	self assert: (GdsInteger fromLiteral: '1') shape = #()
]

{ #category : 'test' }
GdsIntegerTest >> testSize [
	self assert: (GdsInteger fromLiteral: '1') size = 1
]

{ #category : 'test' }
GdsIntegerTest >> testTypeString [
	self assert: (GdsInteger fromLiteral: '1') typeString = 'INTEGER'
]
