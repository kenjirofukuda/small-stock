Class {
	#name : #GplDyadicOperatorNode,
	#superclass : #GplOperatorNode,
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #initialize }
GplDyadicOperatorNode >> initialize [
	super initialize.
	self at: #numArgs put: 2
]

{ #category : #printing }
GplDyadicOperatorNode >> printOn: aStream [
	aStream nextPutAll: self param1 printString.
	aStream nextPutAll: ' '.
	aStream nextPutAll: self opName.
	aStream nextPutAll: ' '.
	aStream nextPutAll: self param2 printString
]
