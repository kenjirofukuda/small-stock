Class {
	#name : #GplDeclNode,
	#superclass : #GplASTNode,
	#category : #'GdsFeel-CLI-AST'
}

{ #category : #accesing }
GplDeclNode >> dataType [
	^ self at: #dataType
		
]

{ #category : #printing }
GplDeclNode >> inspectString [
	^ ((self at: #nameList) isEmpty)
			ifTrue: [ '' ]
			ifFalse: [ (self at: #nameList) printString ]
]

{ #category : #accesing }
GplDeclNode >> isVariable [
	^ (self at: #kind) = #variable
]

{ #category : #accesing }
GplDeclNode >> methodKind [
	^ self at: #methodKind
		
]

{ #category : #testing }
GplDeclNode >> nameList [
	^ self at: #nameList
		
]

{ #category : #accesing }
GplDeclNode >> numArgs [
	self isVariable ifTrue: [ ^ self error: 'invalid call:' ].
	(#NILADIC = self paramType)
		ifTrue: [ ^ 0].
	(#MONADIC = self paramType)
		ifTrue: [ ^ 1].		
	(#DYADIC = self paramType)
		ifTrue: [ ^ 2].
	^ -1.					
]

{ #category : #accesing }
GplDeclNode >> paramType [
	^ self at: #paramType
		
]

{ #category : #accesing }
GplDeclNode >> storageScope [
	^ self at: #storageScope
		
]

{ #category : #accesing }
GplDeclNode >> storageScope: aSymbol [
	^ self at: #storageScope put: aSymbol
		
]

{ #category : #testing }
GplDeclNode >> subroutineNames [
	self isVariable ifTrue: [ ^ #() ].
	^ self nameList asArray
		
]

{ #category : #printing }
GplDeclNode >> tagPrefix [
	^ self isVariable
			ifTrue: [ ^ 'V' ]
			ifFalse: [ ^ 'M' ]
]

{ #category : #testing }
GplDeclNode >> variableNames [
	self isVariable ifFalse: [ ^ #() ].
	^ self nameList asArray
		
]
