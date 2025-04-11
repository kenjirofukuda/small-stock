Class {
	#name : #Gpl2VectorNode,
	#superclass : #Gpl2ExpressionNode,
	#instVars : [
		'numbers',
		'whiteTokens'
	],
	#category : #'GdsFeel-SmaCC'
}

{ #category : #generated }
Gpl2VectorNode >> acceptVisitor: anExpressionVisitor [

	^ anExpressionVisitor visitVector: self
]

{ #category : #generated }
Gpl2VectorNode >> compositeNodeVariables [

	^ #( #numbers )
]

{ #category : #generated }
Gpl2VectorNode >> compositeTokenVariables [

	^ #( #whiteTokens )
]

{ #category : #'generated-initialize-release' }
Gpl2VectorNode >> initialize [
	super initialize.
	numbers := OrderedCollection new: 2.
	whiteTokens := OrderedCollection new: 2.
]

{ #category : #generated }
Gpl2VectorNode >> numbers [

	^ numbers
]

{ #category : #generated }
Gpl2VectorNode >> numbers: anOrderedCollection [

	self setParents: self numbers to: nil.
	numbers := anOrderedCollection.
	self setParents: self numbers to: self
]

{ #category : #generated }
Gpl2VectorNode >> whiteTokens [

	^ whiteTokens
]

{ #category : #generated }
Gpl2VectorNode >> whiteTokens: anOrderedCollection [

	whiteTokens := anOrderedCollection
]
