Class {
	#name : #Gpl2ArrayNode,
	#superclass : #Gpl2ExpressionNode,
	#instVars : [
		'vector',
		'number',
		'leftParenToken',
		'exp',
		'rightParenToken'
	],
	#category : #'GdsFeel-SmaCC'
}

{ #category : #generated }
Gpl2ArrayNode >> acceptVisitor: anExpressionVisitor [
	^ anExpressionVisitor visitArray: self
]

{ #category : #generated }
Gpl2ArrayNode >> exp [
	^ exp
]

{ #category : #generated }
Gpl2ArrayNode >> exp: aGpl2ExpressionNode [
	self exp notNil
		ifTrue: [ self exp parent: nil ].
	exp := aGpl2ExpressionNode.
	self exp notNil
		ifTrue: [ self exp parent: self ]
]

{ #category : #generated }
Gpl2ArrayNode >> leftParenToken [
	^ leftParenToken
]

{ #category : #generated }
Gpl2ArrayNode >> leftParenToken: aSmaCCToken [
	leftParenToken := aSmaCCToken
]

{ #category : #generated }
Gpl2ArrayNode >> nodeVariables [
	^ #(#exp)
]

{ #category : #generated }
Gpl2ArrayNode >> number [
	^ number
]

{ #category : #generated }
Gpl2ArrayNode >> number: aSmaCCToken [
	number := aSmaCCToken
]

{ #category : #generated }
Gpl2ArrayNode >> rightParenToken [
	^ rightParenToken
]

{ #category : #generated }
Gpl2ArrayNode >> rightParenToken: aSmaCCToken [
	rightParenToken := aSmaCCToken
]

{ #category : #generated }
Gpl2ArrayNode >> tokenVariables [
	^ #(#vector #number #leftParenToken #rightParenToken #name #hage #hoge)
]

{ #category : #generated }
Gpl2ArrayNode >> vector [
	^ vector
]

{ #category : #generated }
Gpl2ArrayNode >> vector: aSmaCCToken [
	vector := aSmaCCToken
]
