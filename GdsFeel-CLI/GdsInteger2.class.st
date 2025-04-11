"
A GdsInteger2 is Integer number on GDSII.

storage cost: 4byte(2word) 16bit machine

4-byte integer:
SMMMMMMM MMMMMMMM MMMMMMMM MMMMMMMM



"
Class {
	#name : 'GdsInteger2',
	#superclass : 'GdsIntegral',
	#category : 'GdsFeel-CLI-DGL',
	#package : 'GdsFeel-CLI',
	#tag : 'DGL'
}

{ #category : 'accessing' }
GdsInteger2 class >> maxValue [
	"(2 raisedTo: (32 - 1)) - 1"

	^ 2147483647
]

{ #category : 'accessing' }
GdsInteger2 class >> minValue [
	"(2 raisedTo: (32 - 1)) negated"

	^ -2147483648
]

{ #category : 'accessing' }
GdsInteger2 class >> mode [
	^ 7
]

{ #category : 'accessing' }
GdsInteger2 class >> storageCost [
	^ 4
]
