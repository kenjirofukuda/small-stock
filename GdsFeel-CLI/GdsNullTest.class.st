Class {
	#name : #GdsNullTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #test }
GdsNullTest >> testAcceptableExpression [
	| input result expResult |
	input := '""'.
	expResult := true.
	result := GdsNull acceptableExpression: input.
	self assert: result = expResult.
	
	input := 'NULL'. "not represents NULL"
	expResult := false.
	result := GdsNull acceptableExpression: input.
	self assert: result = expResult.
	
	input := ''''''. "not single qute"
	expResult := false.
	result := GdsNull acceptableExpression: input.
	self assert: result = expResult.

	input := '" "'. "not inside space"
	expResult := false.
	result := GdsNull acceptableExpression: input.
	self assert: result = expResult.

]

{ #category : #test }
GdsNullTest >> testAtSubscript [
	self should: [GdsNull instance atSubscript: (1 asGdsValue)] raise: GplRuntimeError.
	self should: [GdsNull instance atSubscript: (#(1 2) asGdsValue)] raise: GplRuntimeError.
	self should: [evaluator evaluateLine: '""[1]' ] raise: GplRuntimeError.

]

{ #category : #test }
GdsNullTest >> testFromLiteral [
	self 
		should: [ GdsNull fromLiteral: '0' ]
		raise: GplSyntaxError .
	self 
		should: [ GdsNull fromLiteral: 'NULL' ]
		raise: GplSyntaxError.
	self 
		should: [ GdsNull fromLiteral: 'nil' ]
		raise: GplSyntaxError.
	self 
		should: [ GdsReal fromLiteral: '" "' ]
		raise: GplSyntaxError.
	self 
		should: [ GdsReal fromLiteral: '"' ]
		raise: GplSyntaxError.
	self 
		should: [ GdsReal fromLiteral: '''''' ]
		raise: GplSyntaxError.
	self 
		should: [ GdsReal fromLiteral: $" ]
		raise: GplSyntaxError.
	self 
		should: [ GdsReal fromLiteral: $' ]
		raise: GplSyntaxError.
	self assert:  (GdsNull fromLiteral: '""') == GdsNull instance 
]

{ #category : #test }
GdsNullTest >> testIsList [			
	self deny: GdsNull instance isList.	

]

{ #category : #test }
GdsNullTest >> testMode [			
	self assert: (GdsNull instance) mode = 5.	
]

{ #category : #test }
GdsNullTest >> testRank [			
	self assert: GdsNull instance rank = 1.		

]

{ #category : #test }
GdsNullTest >> testShape [			
	self assert: GdsNull instance shape = #().		

]

{ #category : #test }
GdsNullTest >> testSize [			
	| result expResult |
	self assert: GdsNull instance size = 0.		

	expResult := 0.	
	result := (GdsString fromLiteral: '""') size.
	self assert: result = expResult.	
]

{ #category : #test }
GdsNullTest >> testTypeString [			
	self assert: (GdsNull instance) typeString = 'NULL'.	
]
