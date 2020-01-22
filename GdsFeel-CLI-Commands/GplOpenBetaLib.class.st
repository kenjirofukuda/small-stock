Class {
	#name : #GplOpenBetaLib,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplOpenBetaLib class >> methodName [
	"@deprecated"
	^''
]

{ #category : #handler }
GplOpenBetaLib >> evaluateToken: aToken [
	| clazz |
	clazz := self stationUIClass.
	clazz 
		ifNotNil: [clazz openWithInform: false].
	^self nullVector.
]
