Class {
	#name : #KFDummyChunk,
	#superclass : #KFAbstractChunk,
	#instVars : [
		'isHead'
	],
	#category : #'KFCodeMange-Pharo'
}

{ #category : #accessing }
KFDummyChunk >> index [
	self isHead ifTrue: [ ^ 0 ].
	self isTail ifTrue: [ ^ chunkFile chunks size + 1 ].
	^ -1	
]

{ #category : #testing }
KFDummyChunk >> isDummy [
	^ true
]

{ #category : #accessing }
KFDummyChunk >> isHead [ 
	^ isHead 
]

{ #category : #accessing }
KFDummyChunk >> isTail [
	^ isHead not
]

{ #category : #printing }
KFDummyChunk >> printOn: aStream [
	self isHead ifTrue: [ ^ aStream nextPutAll: 'HEAD' ].
	self isTail ifTrue: [ ^ aStream nextPutAll: 'TAIL' ].
	^ super printOn: aStream 
]

{ #category : #'instance creation' }
KFDummyChunk >> setIsHead: aBoolean [ 
	isHead := aBoolean
]
