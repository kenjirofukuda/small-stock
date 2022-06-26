"
A GdsReal is Real number on GDSII.

storage cost: 8byte(4word) 16bit machine

8-byte real:
SEEEEEEE MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM


"
Class {
	#name : #GdsReal,
	#superclass : #GdsFloating,
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #accessing }
GdsReal class >> precisionRank [
	^ 3
]

{ #category : #accessing }
GdsReal class >> storageCost [
	^ 8
]

{ #category : #accessing }
GdsReal class >> typeString [
	^ 'REAL'
]
