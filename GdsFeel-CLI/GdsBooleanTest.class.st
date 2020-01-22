Class {
	#name : #GdsBooleanTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #test }
GdsBooleanTest >> testAcceptableExpression [
	| input result expResult |
	input := '1'.
	expResult := true.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.

	input := '0'.
	expResult := true.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.
	
	input := 'TRUE'.
	expResult := true.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.

	input := 'FALSE'.
	expResult := true.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.
	
	input := '1.0'.
	expResult := false.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.		

	input := '0.0'.
	expResult := false.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.
	
	input := 'false'. "disallow lowercase"
	expResult := false.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.
	
	input := '1E-17'. "disallow floating point"
	expResult := false.
	result := GdsBoolean acceptableExpression: input.
	self assert: result = expResult.
	
]

{ #category : #test }
GdsBooleanTest >> testFoo [
	GdsBoolean initialize.
	(GdsBoolean fromLiteral: 'TRUE') class explore.
]

{ #category : #test }
GdsBooleanTest >> testFromLiteral [
	self assert: (GdsBoolean fromLiteral: 'TRUE') asSmalltalkValue = 1.
	self assert: (GdsBoolean fromLiteral: 'FALSE') asSmalltalkValue = 0.
	self assert: (GdsBoolean fromLiteral: '1') asSmalltalkValue = 1.		
	self assert: (GdsBoolean fromLiteral: '0') asSmalltalkValue = 0.	

	"only use 0 1 TRUE FALSE"
	self should: [(GdsBoolean fromLiteral: '2')] raise: GplSyntaxError.	
	self should: [(GdsBoolean fromLiteral: '0000000001')] raise: GplSyntaxError.	

	"cant ue real"
	self should: [(GdsBoolean fromLiteral: '1.0')] raise: GplSyntaxError.	
	self should: [(GdsBoolean fromLiteral: '0.0')] raise: GplSyntaxError.	

	"currently spec. only UPPECALSE"
	self should: [(GdsBoolean fromLiteral: 'true')] raise: GplSyntaxError.	
	self should: [(GdsBoolean fromLiteral: 'false')] raise: GplSyntaxError.	
	self should: [(GdsBoolean fromLiteral: 'True')] raise: GplSyntaxError.	
	self should: [(GdsBoolean fromLiteral: 'False')] raise: GplSyntaxError.	

	"currently spec. both side space is error"
	self should: [(GdsBoolean fromLiteral: ' 1')] raise: GplSyntaxError.	
	self should: [(GdsBoolean fromLiteral: '1 ')] raise: GplSyntaxError.	
	self should: [(GdsBoolean fromLiteral: ' 1 ')] raise: GplSyntaxError.	
					
]

{ #category : #test }
GdsBooleanTest >> testIsList [			
	self deny: (GdsBoolean fromLiteral: 'TRUE') isList.	
]

{ #category : #test }
GdsBooleanTest >> testLength [
	self assert: (true asGdsValue) length = 1.	
	self assert: (false asGdsValue) length = 1.		
		
]

{ #category : #test }
GdsBooleanTest >> testMode [		
	self assert: (GdsBoolean fromLiteral: 'TRUE') mode = 1.
	self assert: (GdsBoolean fromLiteral: 'FALSE') mode = 1.
	
]

{ #category : #test }
GdsBooleanTest >> testRank [			
	self assert: (GdsBoolean fromLiteral: 'TRUE') rank = 0.	
]

{ #category : #test }
GdsBooleanTest >> testShape [			
	self assert: (GdsBoolean fromLiteral: 'TRUE') shape = #().	
]

{ #category : #test }
GdsBooleanTest >> testSize [			
	self assert: (GdsBoolean fromLiteral: 'TRUE') size = 1.	
]

{ #category : #test }
GdsBooleanTest >> testTypeString [			
	self assert: (GdsBoolean fromLiteral: 'TRUE') typeString = 'LOGICAL'.
	self assert: (GdsBoolean fromLiteral: 'FALSE') typeString = 'LOGICAL'.
	
]
