Class {
	#name : #GplMarkHandler,
	#superclass : #GplMultiHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #accessing }
GplMarkHandler class >> associateArray [
	^ {('KEYMARK' -> #keyMark:).
	('MARK' -> #mark:).
	('REMOVE' -> #remove:).
	('MARKELKEYS' -> #markElementKeys:)}
]

{ #category : #testing }
GplMarkHandler class >> isFunctionAllowed: aCommandName [
	^ false
]

{ #category : #handler }
GplMarkHandler >> keyMark: aToken [
	| arg1 keyNumbers |
	self mustStructureOpen.
	arg1 := evaluator popArg asGplValue.
	keyNumbers := arg1 asVector asSmalltalkValue.
	self markByKeys: keyNumbers.
	^ self nullVector
]

{ #category : #handler }
GplMarkHandler >> mark: aToken [
	| arg1 gv1 numRow mat points |
	self mustStructureOpen.
	arg1 := evaluator popArg asGplValue.
	gv1 := arg1 asVector.
	self mustBeCoordinatable: gv1.
	gv1 size \\ 2 = 0
		ifFalse: [ ^ self illigalCoordinate ].
	numRow := gv1 size // 2.
	mat := Array2D rows: numRow columns: 2 contents: gv1 asSmalltalkValue.
	self structureMorph setVisible: true forKey: #mark.
	points := OrderedCollection new.
	1 to: mat rowCount do:
		[ :rowIndex | points add: (mat at: rowIndex at: 1) @ (mat at: rowIndex at: 2) ].
	self markPoints: points.
	^ self nullVector
]

{ #category : #handler }
GplMarkHandler >> markElementKeys: aToken [
	self mustStructureOpen.
	self structureMorph markElementKeys.
	^ self nullVector
]

{ #category : #handler }
GplMarkHandler >> remove: aToken [
	self mustStructureOpen.
	self structureMorph clearMarker.
	^ self nullVector
]
