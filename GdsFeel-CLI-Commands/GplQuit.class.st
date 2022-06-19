Class {
	#name : #GplQuit,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplQuit class >> methodName [
	^ 'QUIT'
]

{ #category : #handler }
GplQuit >> evaluateToken: aToken [
	| clazz instances |
	self station structure ifNotNil: [ self call: 'TSTRUCT' ].
	clazz := self stationUIClass.
	clazz
		ifNotNil: [ instances := clazz noGarbageTargetInstances.
			instances do: [ :each | each delete ].
			Smalltalk garbageCollect ].
	^ self nullVector
]
