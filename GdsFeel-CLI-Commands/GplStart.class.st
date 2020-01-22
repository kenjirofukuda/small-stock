Class {
	#name : #GplStart,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplStart class >> methodName [
	^'START'
]

{ #category : #accessing }
GplStart >> evaluateToken: aToken [
	self stationUIClass
		ifNotNil: [:clazz | clazz open.].
	^self nullVector.
]
