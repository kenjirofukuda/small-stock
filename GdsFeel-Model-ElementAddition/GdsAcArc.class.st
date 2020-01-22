Class {
	#name : #GdsAcArc,
	#superclass : #GdsAcCircle,
	#instVars : [
		'startAngleDegress',
		'endAngleDegress'
	],
	#category : #'GdsFeel-Model-ElementAddition'
}

{ #category : #accessing }
GdsAcArc class >> type [
	^ #arc
]

{ #category : #'objects from disk' }
GdsAcArc >> attributesFrom: aDictionary [
	super attributesFrom: aDictionary.
	self startAngleDegress: (aDictionary at: 'startAngle' ifAbsent: [0]) asNumber.
	self endAngleDegress: (aDictionary at: 'endAngle' ifAbsent: [0]) asNumber.	
]

{ #category : #'xml/json data exchange' }
GdsAcArc >> attributesOn: aDictionary [
	super attributesOn: aDictionary.
	aDictionary at: 'startAngle' put: self startAngleDegress asString.
	aDictionary at: 'endAngle' put: self endAngleDegress asString.	
]

{ #category : #accessing }
GdsAcArc >> endAngleDegress [
	^ endAngleDegress 
]

{ #category : #accessing }
GdsAcArc >> endAngleDegress: aNumber [
	^ endAngleDegress := aNumber asFloat.
]

{ #category : #'initailize-release' }
GdsAcArc >> initialize [
	super initialize.
	self startAngleDegress: 0.0.
	self endAngleDegress: 0.0.	
]

{ #category : #accessing }
GdsAcArc >> startAngleDegress [
	^ startAngleDegress
]

{ #category : #accessing }
GdsAcArc >> startAngleDegress: aNumber [
	startAngleDegress := aNumber asFloat.
]
