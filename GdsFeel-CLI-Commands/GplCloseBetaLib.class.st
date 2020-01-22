Class {
	#name : #GplCloseBetaLib,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplCloseBetaLib class >> methodName [
	"@deprecated "
	^''
]

{ #category : #handler }
GplCloseBetaLib >> evaluateToken: aToken [
	| clazz instances|
	self station structure
		ifNotNil: [self call: 'TSTRUCT'].
	clazz := self stationUIClass.
	clazz 
		ifNotNil: [
			instances := clazz noGarbageTargetInstances. 
			instances do: [:each | each delete.].
			Smalltalk garbageCollect ].
	^self nullVector.
]
