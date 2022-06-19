Class {
	#name : #GplStatementNode,
	#superclass : #GplASTNode,
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #'as yet unclassified' }
GplStatementNode >> printOn: aStream [
	(self at: #value) printOn: aStream
]
