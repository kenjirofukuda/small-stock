Class {
	#name : #Gpl2ExpressionNode,
	#superclass : #SmaCCParseNode,
	#instVars : [
		'name'
	],
	#category : #'GdsFeel-SmaCC'
}

{ #category : #generated }
Gpl2ExpressionNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitExpression: self
]

{ #category : #generated }
Gpl2ExpressionNode >> name [

	^ name
]

{ #category : #generated }
Gpl2ExpressionNode >> name: aSmaCCToken [

	name := aSmaCCToken
]

{ #category : #generated }
Gpl2ExpressionNode >> tokenVariables [

	^ #( #name )
]
