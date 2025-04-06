Class {
	#name : 'GplASTBinaryNode',
	#superclass : 'GplASTValueNode',
	#instVars : [
		'operator',
		'left',
		'right'
	],
	#category : 'GplPetitParser-AST',
	#package : 'GplPetitParser',
	#tag : 'AST'
}

{ #category : 'accessing' }
GplASTBinaryNode >> formatedCodeOld [
	^ {left formatedCode.
	operator formatedCode.
	right formatedCode} joinUsing: ' '
]

{ #category : 'accessing' }
GplASTBinaryNode >> left [
	^ left
]

{ #category : 'accessing' }
GplASTBinaryNode >> left: anObject [
	left := anObject
]

{ #category : 'accessing' }
GplASTBinaryNode >> operator [
	^ operator
]

{ #category : 'accessing' }
GplASTBinaryNode >> operator: anObject [
	operator := anObject
]

{ #category : 'accessing' }
GplASTBinaryNode >> right [
	^ right
]

{ #category : 'accessing' }
GplASTBinaryNode >> right: anObject [
	right := anObject
]
