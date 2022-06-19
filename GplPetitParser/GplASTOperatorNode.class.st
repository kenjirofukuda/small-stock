Class {
	#name : #GplASTOperatorNode,
	#superclass : #GplPPASTNode,
	#instVars : [
		'operator'
	],
	#category : #'GplPetitParser-AST'
}

{ #category : #'as yet unclassified' }
GplASTOperatorNode >> formatedCode [
	^ operator asString
]

{ #category : #'as yet unclassified' }
GplASTOperatorNode >> operator: aString [
	operator := aString
]
