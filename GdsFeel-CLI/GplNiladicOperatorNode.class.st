Class {
	#name : 'GplNiladicOperatorNode',
	#superclass : 'GplOperatorNode',
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplNiladicOperatorNode >> initialize [
	super initialize.
	self at: #numArgs put: 0
]

{ #category : 'as yet unclassified' }
GplNiladicOperatorNode >> printOn: aStream [
	aStream nextPutAll: self opName
]
