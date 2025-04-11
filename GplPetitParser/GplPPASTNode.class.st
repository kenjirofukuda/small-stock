Class {
	#name : 'GplPPASTNode',
	#superclass : 'Object',
	#instVars : [
		'parent',
		'start',
		'stop',
		'source',
		'parentheses'
	],
	#category : 'GplPetitParser-AST',
	#package : 'GplPetitParser',
	#tag : 'AST'
}

{ #category : 'accessing' }
GplPPASTNode >> formatedCode [
	self source ifNil: [ ^ '***BINDERR***' ].
	^ self source copyFrom: self start to: self stop
]

{ #category : 'as yet unclassified' }
GplPPASTNode >> parent [
	^ parent
]

{ #category : 'as yet unclassified' }
GplPPASTNode >> parent: aGplASTNode [
	parent := aGplASTNode
]

{ #category : 'as yet unclassified' }
GplPPASTNode >> printOn: aSteam [
	super printOn: aSteam.
	aSteam nextPut: $(.
	aSteam nextPutAll: self formatedCode.
	aSteam nextPut: $)
]

{ #category : 'accessing' }
GplPPASTNode >> source [
	^ parent ifNil: [ source ] ifNotNil: [ parent source ]
]

{ #category : 'accessing' }
GplPPASTNode >> source: anObject [
	source := anObject
]

{ #category : 'accessing' }
GplPPASTNode >> start [
	self subclassResponsibility
]

{ #category : 'accessing' }
GplPPASTNode >> start: anObject [
	start := anObject
]

{ #category : 'accessing' }
GplPPASTNode >> stop [
	self subclassResponsibility
]

{ #category : 'accessing' }
GplPPASTNode >> stop: anObject [
	stop := anObject
]
