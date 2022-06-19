Class {
	#name : #Mandara,
	#superclass : #Object,
	#instVars : [
		'sides',
		'extent',
		'i',
		'j',
		'break',
		'strokes',
		'radius'
	],
	#classVars : [
		'Pi2',
		'Pih'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #'as yet unclassified' }
Mandara class >> initialize [
	"self initialize."

	Pi2 := Float pi * 2.
	Pih := Float pi / 2.0
]

{ #category : #'as yet unclassified' }
Mandara >> countUp [
	j := j + 1.
	j >= sides
		ifTrue: [ i := i + 1.
			i >= (sides - 1)
				ifTrue: [ i := 0.
					break := true ].
			j := i + 1 ]
]

{ #category : #accessing }
Mandara >> extent [
	^ extent
]

{ #category : #accessing }
Mandara >> extent: anExtent [
	extent := anExtent.
	strokes := nil.
	radius := nil
]

{ #category : #'initialize-release' }
Mandara >> initialize [
	sides := 16.
	extent := 300 @ 300.
	i := 0.
	j := 1.
	break := false
]

{ #category : #'as yet unclassified' }
Mandara >> lookupRadius [
	^ (extent x min: extent y) / 2.0
]

{ #category : #'as yet unclassified' }
Mandara >> lookupStrokes [
	| paths |
	paths := OrderedCollection new.
	break := false.
	[ break ] whileFalse: [ paths add: self strokeStep ].
	^ paths
]

{ #category : #'as yet unclassified' }
Mandara >> pointAtIndex: anIndex [
	| inter x r y |
	r := self radius.
	inter := anIndex / sides * Pi2 + Pih.
	x := inter cos * r + r.
	y := inter sin negated * r + r.
	^ x @ y
]

{ #category : #accessing }
Mandara >> radius [
	radius ifNil: [ radius := self lookupRadius ].
	^ radius
]

{ #category : #accessing }
Mandara >> sides [
	^ sides
]

{ #category : #accessing }
Mandara >> sides: anInteger [
	sides := anInteger.
	strokes := nil
]

{ #category : #'as yet unclassified' }
Mandara >> strokeStep [
	| path |
	path := StrokeRecorder new.
	path moveToPoint: (self pointAtIndex: i).
	path lineToPoint: (self pointAtIndex: j).
	self countUp.
	^ path
]

{ #category : #accessing }
Mandara >> strokes [
	^ self lookupStrokes
]
