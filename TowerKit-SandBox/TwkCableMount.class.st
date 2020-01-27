Class {
	#name : #TwkCableMount,
	#superclass : #TwkNode,
	#instVars : [
		'height',
		'offset',
		'angle',
		'range',
		'farAxis',
		'length',
		'cable'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #'as yet unclassified' }
TwkCableMount class >> example [
	<example>
	TwkCableMount new 		
		yourself
		explore.
	
]

{ #category : #accessing }
TwkCableMount >> angle: aUnitValue [
	angle value: aUnitValue
]

{ #category : #accessing }
TwkCableMount >> cable: aTwkCable [
	cable := aTwkCable.
]

{ #category : #accessing }
TwkCableMount >> height: aUnitValue [
	height value: aUnitValue.
]

{ #category : #initialization }
TwkCableMount >> initialize [
	height := TwkLengthItem new.
	offset:= TwkLengthItem new.
	farAxis := TwkLengthItem new.

	angle := TwkAngleItem new.
	range := TwkAngleItem new.

	offset value: 0 mm.
	height value: 0 mm.
	farAxis value: 0 mm.

	angle value: 0 arcdegree.
	range value: 0 arcdegree.	
	
]

{ #category : #accessing }
TwkCableMount >> length [
	^ length value
]

{ #category : #accessing }
TwkCableMount >> length: aUnitValue [
	length value: aUnitValue
	
]

{ #category : #accessing }
TwkCableMount >> offset: aUnitValue [
	offset value: aUnitValue.
]

{ #category : #printing }
TwkCableMount >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	angle printOn: aStream.
	aStream nextPut: $).
	
]

{ #category : #accessing }
TwkCableMount >> range: aUnitValue [
	range value: aUnitValue
	
]
