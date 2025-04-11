Class {
	#name : 'GplMonadicOperatorNode',
	#superclass : 'GplOperatorNode',
	#category : 'GdsFeel-CLI-AST',
	#package : 'GdsFeel-CLI',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplMonadicOperatorNode >> initialize [
	super initialize.
	self at: #numArgs put: 1
]

{ #category : 'as yet unclassified' }
GplMonadicOperatorNode >> printOn: aStream [
	aStream nextPutAll: self opName.
	aStream nextPutAll: ' '.
	aStream nextPutAll: self param1 printString
]
