Class {
	#name : #TwkRangedAngle,
	#superclass : #TwkNode,
	#instVars : [
		'angle',
		'range'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #accessing }
TwkRangedAngle >> angle: aUnitValue [
	angle value: aUnitValue
	
]

{ #category : #'as yet unclassified' }
TwkRangedAngle >> initalize [
	angle := TwkAngleItem new.
	range := TwkAngleItem new.
	angle value: 0 deg.
	range value: 0 deg.
]

{ #category : #accessing }
TwkRangedAngle >> range: aUnitValue [
	range value: aUnitValue
	
]
