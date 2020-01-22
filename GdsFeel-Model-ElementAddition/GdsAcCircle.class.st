Class {
	#name : #GdsAcCircle,
	#superclass : #GdsAcPoint,
	#instVars : [
		'radius'
	],
	#category : #'GdsFeel-Model-ElementAddition'
}

{ #category : #accessing }
GdsAcCircle class >> type [
	^ #circle
]

{ #category : #'objects from disk' }
GdsAcCircle >> attributesFrom: aDictionary [
	super attributesFrom: aDictionary.
	self radius: (aDictionary at: 'radius' ifAbsent: [ 0 ]) asNumber. 
	
]

{ #category : #'xml/json data exchange' }
GdsAcCircle >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'radius' put: self radius asString.
	
]

{ #category : #'accessing-points' }
GdsAcCircle >> dataOutlinePoints [
	^ self dataOutlinePointsStepAngle: 5. 
]

{ #category : #'accessing-points' }
GdsAcCircle >> dataOutlinePointsStartAngle: aStartAngle endAngle: aEndAngle stepAngle: stepAngle [
	| stepDegress r cx cy rad |
	r := self radius.
	cx := self centerPoint x. 
	cy := self centerPoint y. 
	stepDegress := stepAngle.
	^ Array streamContents: [ :s |
		aStartAngle to: aEndAngle by: stepDegress do: [ :deg | | x y |
		rad := deg degreesToRadians.
		x := cx + (r * (rad cos)).
		y := cy + (r * (rad sin)).
		s nextPut: (x @ y) ] ] 
]

{ #category : #'accessing-points' }
GdsAcCircle >> dataOutlinePointsStepAngle: stepAngle [
	| angle |
	angle := self endAngleDegress - self startAngleDegress.
	angle negative 
		ifTrue: [ angle := 360 + angle ]. 
	^ self 
		dataOutlinePointsStartAngle: self startAngleDegress  
			endAngle: self startAngleDegress + angle 
			stepAngle: stepAngle.
]

{ #category : #'as yet unclassified' }
GdsAcCircle >> dist: aPoint [ 
	^ self basicDistance: aPoint
]

{ #category : #accessing }
GdsAcCircle >> endAngleDegress [
	^ 360.0
]

{ #category : #'initailize-release' }
GdsAcCircle >> initialize [
	super initialize.
	self radius: 0.0.
]

{ #category : #accessing }
GdsAcCircle >> radius [
	^ radius
]

{ #category : #accessing }
GdsAcCircle >> radius: aNumber [
	radius := aNumber asFloat.
]

{ #category : #accessing }
GdsAcCircle >> startAngleDegress [
	^ 0.0
]
