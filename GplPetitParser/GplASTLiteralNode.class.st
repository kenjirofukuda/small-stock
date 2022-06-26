Class {
	#name : #GplASTLiteralNode,
	#superclass : #GplASTValueNode,
	#instVars : [
		'gplValue'
	],
	#category : #'GplPetitParser-AST'
}

{ #category : #accessing }
GplASTLiteralNode >> gplValue: aGdsString [
	gplValue := aGdsString
]
