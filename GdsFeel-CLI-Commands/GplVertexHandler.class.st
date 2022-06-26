Class {
	#name : #GplVertexHandler,
	#superclass : #GplMultiHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplVertexHandler class >> associateArray [
	^ {('DVERT' -> #deleteVertex:).
	('DVERTI' -> #deleteVertexIndexed:)}
]

{ #category : #'as yet unclassified' }
GplVertexHandler class >> isFunctionAllowed: aCommandName [
	^ false
]

{ #category : #handler }
GplVertexHandler >> deleteVertex: aToken [
	| arg1 gv1 ce smVec analisysResult targetIndex |
	self mustStructureOpen.
	arg1 := evaluator popArg asGplValue.
	gv1 := arg1 asVector.
	self mustBeCoordinatable: gv1.
	gv1 size = 2
		ifFalse: [ ^ self illigalCoordinate ].
	smVec := gv1 asSmalltalkValue.
	ce := (smVec at: 1) @ (smVec at: 2).
	analisysResult := GeometryUtils
		analisysSegmentsAt: ce
		pointArray: self currentItem vertices.
	targetIndex := GeometryUtils lookupVertexIndex: analisysResult.
	self currentItem removeVertexAt: targetIndex.
	^ self nullVector
]

{ #category : #handler }
GplVertexHandler >> deleteVertexIndexed: aToken [
	| arg1 gv1 smVec targetIndex |
	self mustStructureOpen.
	arg1 := evaluator popArg asGplValue.
	gv1 := arg1 asVector.
	self mustBeCoordinatable: gv1.
	gv1 size = 1
		ifFalse: [ ^ self illigalCoordinate ].
	smVec := gv1 asSmalltalkValue.
	targetIndex := smVec at: 1.
	((1 to: self currentItem vertices size) includes: targetIndex)
		ifFalse: [ ^ self error: 'INDEX OUT OF RANGE' ].
	self currentItem removeVertexAt: targetIndex.
	^ self nullVector
]
