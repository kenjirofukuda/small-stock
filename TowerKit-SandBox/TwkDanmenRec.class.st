Class {
	#name : #TwkDanmenRec,
	#superclass : #TwkExternalRec,
	#instVars : [
		'materialNumber',
		'vvLength',
		'masterLength',
		'lengthMode',
		'bendLength',
		'boltName',
		'boltCount'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #accessing }
TwkDanmenRec >> bendLength: aNumber [
	bendLength := aNumber.

]

{ #category : #accessing }
TwkDanmenRec >> boltCount: aNumber [
	boltCount := aNumber.
]

{ #category : #accessing }
TwkDanmenRec >> boltName: aString [
	boltName := aString.
]

{ #category : #accessing }
TwkDanmenRec >> masterLength [
	^ masterLength
]

{ #category : #accessing }
TwkDanmenRec >> masterLength: anObject [
	masterLength := anObject
]

{ #category : #accessing }
TwkDanmenRec >> materialNumber: aNumber [
	materialNumber := aNumber
]

{ #category : #accessing }
TwkDanmenRec >> vvLength: aNumber [
	masterLength := aNumber.
	lengthMode := #vv.
]

{ #category : #accessing }
TwkDanmenRec >> xxLength: aNumber [
	masterLength := aNumber.
	lengthMode := #xx.
]
