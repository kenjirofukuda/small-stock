Class {
	#name : #TwkAngleItem,
	#superclass : #TwkCalcItem,
	#category : #'TowerKit-SandBox'
}

{ #category : #initialization }
TwkAngleItem >> initialize [
	super initialize.
	self value: 0 arcdegree 
]

{ #category : #printing }
TwkAngleItem >> printTitle [
	^ 'Angle'
]
