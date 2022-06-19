Class {
	#name : #GplDummy,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplDummy class >> methodName [
	^ 'DUMMY'
]

{ #category : #handler }
GplDummy >> evaluateToken: aToken [
	evaluator stdout nextPutAll: 'EnterLibrary name: '.
	evaluator stdout flush.

	"reply := evalustor stdin nextLine."
	[ Sensor shiftPressed ]
		whileFalse: [ Processor yield.
			Delay forSeconds: 1 ].
	^ self stringVector: 'this is a return value: '
]
