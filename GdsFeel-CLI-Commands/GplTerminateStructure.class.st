Class {
	#name : #GplTerminateStructure,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplTerminateStructure class >> methodName [
	^'TSTRUCT'
]

{ #category : #handler }
GplTerminateStructure >> evaluateToken: aToken [
	self station structure ifNil: [^self error: 'NO STRUCTURE OPEN.'].
	self currentItem putEnabled
		ifTrue: [^self error: 'ITEM NOT EMPTY. TO USE [PUT] or [PUTALL] or [UNGET]']. 
	self  structure idSelection isEmpty
		ifFalse: [^self error: 'ELEMENTS STILL IN ID SPACE . TO USE [UNID] or [IDCLEAR]'].
	self station tstruct.	
	^self nullVector.
	
]
