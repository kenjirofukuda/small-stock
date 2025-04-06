Class {
	#name : 'GplValueNode',
	#superclass : 'GplASTNode',
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplValueNode >> subscriptExpression [
	^ [ self at: #subscriptExpression ]
		on: Error
		do: [ nil ]
]

{ #category : 'as yet unclassified' }
GplValueNode >> subscriptExpression: aSubscriptExpression [
	self at: #subscriptExpression put: aSubscriptExpression
]
