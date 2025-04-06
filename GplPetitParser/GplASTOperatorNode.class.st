Class {
	#name : 'GplASTOperatorNode',
	#superclass : 'GplPPASTNode',
	#instVars : [
		'operator'
	],
	#category : 'GplPetitParser-AST',
	#package : 'GplPetitParser',
	#tag : 'AST'
}

{ #category : 'as yet unclassified' }
GplASTOperatorNode >> formatedCode [
	^ operator asString
]

{ #category : 'as yet unclassified' }
GplASTOperatorNode >> operator: aString [
	operator := aString
]
