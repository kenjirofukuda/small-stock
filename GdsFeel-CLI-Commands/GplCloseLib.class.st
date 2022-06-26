Class {
	#name : #GplCloseLib,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplCloseLib class >> methodName [
	^ 'CLOSELIB'
]

{ #category : #'as yet unclassified' }
GplCloseLib >> evaluateToken: aToken [
	self station structure ifNotNil: [ self call: 'TSTRUCT' ].
	self library isOpen
		ifTrue: [ evaluator console
				ifNotNil: [ self station closeLibrary ]
				ifNil: [ self stationUI closelib ] ].
	^ self nullVector
]
