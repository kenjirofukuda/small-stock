Class {
	#name : #Gpl2NumberNode,
	#superclass : #Gpl2ExpressionNode,
	#instVars : [
		'value'
	],
	#category : #'GdsFeel-SmaCC'
}

{ #category : #generated }
Gpl2NumberNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitNumber: self
]

{ #category : #generated }
Gpl2NumberNode >> tokenVariables [

	^ #( #value #name )
]

{ #category : #generated }
Gpl2NumberNode >> value [

	^ value
]

{ #category : #generated }
Gpl2NumberNode >> value: aSmaCCToken [

	value := aSmaCCToken
]
