Class {
	#name : #Gpl2MonadicExpressionNode,
	#superclass : #Gpl2ExpressionNode,
	#instVars : [
		'operator',
		'rhs',
		'whiteTokens'
	],
	#category : #'GdsFeel-SmaCC'
}

{ #category : #generated }
Gpl2MonadicExpressionNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitMonadicExpression: self
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> compositeTokenVariables [

	^ #( #whiteTokens )
]

{ #category : #'generated-initialize-release' }
Gpl2MonadicExpressionNode >> initialize [
	super initialize.
	whiteTokens := OrderedCollection new: 2.
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> nodeVariables [

	^ #( #rhs )
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> operator [

	^ operator
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> operator: aSmaCCToken [

	operator := aSmaCCToken
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> rhs [

	^ rhs
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> rhs: aGpl2ExpressionNode [

	self rhs notNil ifTrue: [ self rhs parent: nil ].
	rhs := aGpl2ExpressionNode.
	self rhs notNil ifTrue: [ self rhs parent: self ]
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> tokenVariables [

	^ #( #operator #name )
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> whiteTokens [

	^ whiteTokens
]

{ #category : #generated }
Gpl2MonadicExpressionNode >> whiteTokens: anOrderedCollection [

	whiteTokens := anOrderedCollection
]
