Class {
	#name : #KFAbstractChunk,
	#superclass : #Object,
	#instVars : [
		'chunkFile'
	],
	#classVars : [
		'Head',
		'Tail'
	],
	#category : #'KFCodeMange-Pharo'
}

{ #category : #'accessing - structure variables' }
KFAbstractChunk class >> head [
	^ Head
]

{ #category : #initialization }
KFAbstractChunk class >> initialize [
	Head := KFDummyChunk new setIsHead: true.
	Tail := KFDummyChunk new setIsHead: false.	
	
]

{ #category : #'accessing - structure variables' }
KFAbstractChunk class >> tail [
	^ Tail
]

{ #category : #accessing }
KFAbstractChunk >> chunkFile: aGdsChunkFile [ 
	chunkFile := aGdsChunkFile.
]

{ #category : #testing }
KFAbstractChunk >> isClassClassDefinition [

	^ false
]

{ #category : #testing }
KFAbstractChunk >> isClassDefinition [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isClassMethodHeader [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isCommentBody [
	^ false 
]

{ #category : #testing }
KFAbstractChunk >> isCommentLiteral [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isCommentStamp [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isDummy [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isEmpty [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isHead [ 
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isInstanceMethodHeader [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isMethodBody [
	^ false 
]

{ #category : #testing }
KFAbstractChunk >> isMethodHeader [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isStringLiteral [
	^ false
]

{ #category : #testing }
KFAbstractChunk >> isTail [
	^ false
]

{ #category : #accessing }
KFAbstractChunk >> next [
	^ nil
]

{ #category : #accessing }
KFAbstractChunk >> prev [
	^ nil
]

{ #category : #testing }
KFAbstractChunk >> rejectable [
	^ false
]
