"
A GdsInteger is Integer number on GDSII.

storage cost: 2byte(1word) 16bit machine

2-byte integer:
SMMMMMMM MMMMMMM

"
Class {
	#name : #GdsInteger,
	#superclass : #GdsIntegral,
	#category : #'GdsFeel-CLI-DGL'
}

{ #category : #accessing }
GdsInteger class >> maxValue [
	"(2 raisedTo: (16 - 1)) - 1"

	^ 32767
]

{ #category : #accessing }
GdsInteger class >> minValue [
	"(2 raisedTo: (16 - 1)) negated"

	^ -32768
]

{ #category : #accessing }
GdsInteger class >> mode [
	^ 2
]

{ #category : #accessing }
GdsInteger class >> precisionRank [
	^ 2
]

{ #category : #accessing }
GdsInteger class >> storageCost [
	^ 2
]
