Class {
	#name : 'GdsNumberProperty',
	#superclass : 'GdsObjectProperty',
	#category : 'GdsFeel-Foundation-Property',
	#package : 'GdsFeel-Foundation-Property'
}

{ #category : 'instance creation' }
GdsNumberProperty class >> typeClass [
	^Number
]

{ #category : 'actions' }
GdsNumberProperty >> down [
	self down: 1.
]

{ #category : 'actions' }
GdsNumberProperty >> down: aStepValue [
	self setValue: (self getValue - aStepValue abs)
]

{ #category : 'initialize-release' }
GdsNumberProperty >> initialize [
	super initialize.
	initialValue := 0.
	
]

{ #category : 'actions' }
GdsNumberProperty >> up [
	self up: 1.
]

{ #category : 'actions' }
GdsNumberProperty >> up: aStepValue [
	self setValue: (self getValue + aStepValue abs)
]
