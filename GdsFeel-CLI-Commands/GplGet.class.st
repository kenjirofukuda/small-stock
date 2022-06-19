Class {
	#name : #GplGet,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplGet class >> methodName [
	^ 'GET'
]

{ #category : #handler }
GplGet >> evaluateToken: aToken [
	| gv1 vec smVec element |
	self mustStructureOpen.
	self currentItem getEnabled
		ifFalse: [ ^ self error: 'ITEM NOT EMPTY' ].
	gv1 := evaluator popArg asGplValue.
	vec := gv1 asVector.
	(#(1 2) includes: vec size)
		ifFalse: [ ^ self error: self usage ].
	smVec := vec asSmalltalkValue.
	smVec size = 2
		ifTrue: [ element := self structure
				findNearestElementByPoint: smVec first @ smVec second.
			element
				ifNil: [ ^ self
						error:
							('CANNT GET ELEMENT AT: <1s> <2s>'
								expandMacrosWith: smVec first
								with: smVec second asString) ]
				ifNotNil: [ self currentItem get: element ] ].
	smVec size = 1
		ifTrue: [ element := self findElementByKeyNumber: smVec first.
			self currentItem get: element ].
	^ self nullVector
]

{ #category : #'as yet unclassified' }
GplGet >> usage [
	^ 'usage:
 GET {X} {Y}
  or
 GET {KEY}'
]
