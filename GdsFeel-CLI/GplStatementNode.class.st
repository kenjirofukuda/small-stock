Class {
	#name : 'GplStatementNode',
	#superclass : 'GplASTNode',
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplStatementNode >> printOn: aStream [
	(self at: #value) printOn: aStream
]
