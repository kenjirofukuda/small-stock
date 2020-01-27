Class {
	#name : #TwkTrussPoint,
	#superclass : #TwkTrussElement,
	#instVars : [
		'position'
	],
	#category : #'TowerKit-Diagram'
}

{ #category : #accessing }
TwkTrussPoint >> angleDegress [
	^ self position angleDegress degressNormalized 
]

{ #category : #accessing }
TwkTrussPoint >> angleDegressFarRange [
	^ self rangeAngle: self angleDegress startOffset: -90 endOffset: 0. 

]

{ #category : #accessing }
TwkTrussPoint >> angleDegressNearRange [
	^ self rangeAngle: self angleDegress startOffset: 0 endOffset: 90. 

]

{ #category : #converting }
TwkTrussPoint >> asPoint [
	^ self position
]

{ #category : #accessing }
TwkTrussPoint >> basicAngleInRange: anInterval [
	^ (#(0 90 180 270 360)
		detect: [ :each | each between: anInterval first and: anInterval last ])
			degressNormalized  
]

{ #category : #accessing }
TwkTrussPoint >> farAngle [
	^ self basicAngleInRange: self angleDegressFarRange. 
		
]

{ #category : #initialization }
TwkTrussPoint >> initialize [
	super initialize.
	position := 0 @ 0.
]

{ #category : #accessing }
TwkTrussPoint >> nearAngle [
	^ self basicAngleInRange: self angleDegressNearRange. 

]

{ #category : #accessing }
TwkTrussPoint >> position [
	^ position
]

{ #category : #accessing }
TwkTrussPoint >> position: aPoint [
	position := aPoint
]

{ #category : #accessing }
TwkTrussPoint >> rangeAngle: anAngle startOffset: aStartOffsetAngle endOffset: aEndOffsetAngle [
	| range |
	range := (anAngle + aStartOffsetAngle) degressNormalized to: ((anAngle + aEndOffsetAngle) degressNormalized).
	range first > range last
		ifTrue: [ ^ range first to: range last + 360.0 ].
	^ range	
]

{ #category : #accessing }
TwkTrussPoint >> topLetter [
	^ 'P'
]
