Class {
	#name : #GplASTNode,
	#superclass : #GdsObject,
	#instVars : [
		'nodes',
		'tags',
		'property',
		'parent'
	],
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #adding }
GplASTNode >> addSubNode: aGplTreeNode [
	nodes add: aGplTreeNode.
	aGplTreeNode parent: self
]

{ #category : #adding }
GplASTNode >> addTag: aSymbol [
	tags add: aSymbol
]

{ #category : #accessing }
GplASTNode >> at: aKey [
	^ property at: aKey
]

{ #category : #accessing }
GplASTNode >> at: aKey put: aValue [
	property at: aKey put: aValue
]

{ #category : #accessing }
GplASTNode >> condition [
	^ self at: #condition
]

{ #category : #accessing }
GplASTNode >> condition: node [
	self at: #condition put: node
]

{ #category : #initialize }
GplASTNode >> initialize [
	super initialize.
	nodes := OrderedCollection new.
	tags := OrderedCollection new.
	property := Dictionary new.
	self at: #kind put: #defaultClass
]

{ #category : #printing }
GplASTNode >> inspectString [
	^ (self at: #kind) printString
]

{ #category : #accessing }
GplASTNode >> kind [
	^ self at: #kind
]

{ #category : #accessing }
GplASTNode >> kind: aToken [
	self at: #kind put: aToken
]

{ #category : #adding }
GplASTNode >> nodes [
	^ nodes
]

{ #category : #accessing }
GplASTNode >> parent: aGplTreeNode [
	parent := aGplTreeNode
]

{ #category : #printing }
GplASTNode >> printOn: aStream [
	aStream nextPutAll: self tagPrefix.
	aStream nextPutAll: '['.
	aStream nextPutAll: self inspectString.
	aStream nextPutAll: ']'
]

{ #category : #printing }
GplASTNode >> tagPrefix [
	^ 'N'
]

{ #category : #accessing }
GplASTNode >> token [
	^ self at: #token
]

{ #category : #accessing }
GplASTNode >> token: aToken [
	self at: #token put: aToken
]
