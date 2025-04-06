Class {
	#name : 'GplASTLiteralNode',
	#superclass : 'GplASTValueNode',
	#instVars : [
		'gplValue'
	],
	#category : 'GplPetitParser-AST',
	#package : 'GplPetitParser',
	#tag : 'AST'
}

{ #category : 'accessing' }
GplASTLiteralNode >> gplValue: aGdsString [
	gplValue := aGdsString
]
