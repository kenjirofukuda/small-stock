Class {
	#name : #GplCE,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplCE class >> methodName [
	^ 'CE'
]

{ #category : #handler }
GplCE >> evaluateToken: aToken [
	| arg1 gv1 sv1 xValues yValues |
	self mustStructureOpen.
	arg1 := evaluator popArg asGplValue.
	gv1 := arg1 asVector.
	self mustBeCoordinatable: gv1.
	gv1 size even
		ifFalse: [ ^ self onlyPairValues ].
	sv1 := gv1 asSmalltalkValue.
	xValues := OrderedCollection new.
	yValues := OrderedCollection new.
	self splitValues: sv1 xValuesOn: xValues yValuesOn: yValues.
	(1 to: xValues size)
		do: [ :i | self currentItem ceX: (xValues at: i) y: (yValues at: i) ].
	^ self nullVector
]

{ #category : #'as yet unclassified' }
GplCE >> onlyPairValues [
	^ self error: 'Only Pair Values: X1 Y1 X2 Y2 ... Xn Yn '
]

{ #category : #'as yet unclassified' }
GplCE >> splitValues: aValues xValuesOn: aXCollection yValuesOn: aYCollection [
	| indexes oddIndexes evenIndexes |
	indexes := (1 to: aValues size) asArray.
	oddIndexes := indexes select: [ :i | i odd ].
	evenIndexes := indexes select: [ :i | i even ].
	aXCollection addAll: (oddIndexes collect: [ :i | aValues at: i ]).
	aYCollection addAll: (evenIndexes collect: [ :i | aValues at: i ])
]
