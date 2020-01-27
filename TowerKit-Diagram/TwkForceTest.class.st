"
A TwkForceTest is a test class for testing the behavior of TwkForce
"
Class {
	#name : #TwkForceTest,
	#superclass : #TestCase,
	#category : #'TowerKit-Diagram-Tests'
}

{ #category : #'tests-accessing' }
TwkForceTest >> sampleForces [
	^ (0 to: 360 by: 45) collect: [ :each | TwkForce new angleDegress: each ].

]

{ #category : #'tests-as yet unclassified' }
TwkForceTest >> testAdd [
	| f1 f2 sum |
	f1 := TwkForce new angleDegress: 0. 
	f2 := TwkForce new angleDegress: 180.
	sum := f1 + f2.
	self assert: (sum loadValue closeTo: 0).

	f1 := TwkForce new angleDegress: 0. 
	f2 := TwkForce new angleDegress: 0.
	sum := f1 + f2.
	self assert: (sum loadValue closeTo: 2).

	f1 := TwkForce new angleDegress: 45. 
	f2 := TwkForce new angleDegress: -45.
	sum := f1 + f2.
	self assert: (sum angleDegress closeTo: 0).
		
]

{ #category : #'tests-accessing' }
TwkForceTest >> testAngleDegress [
	self assert: ((TwkForce angleDegress: 365) angleDegress closeTo: 5.0).
	self assert: ((TwkForce angleDegress: -5) angleDegress closeTo: 355.0).
	self assert: ((TwkForce angleDegress: -45) angleDegress closeTo: 315.0).		
	self assert: ((TwkForce angleDegress: 360) angleDegress closeTo: 0.0).
	
]

{ #category : #'tests-accessing' }
TwkForceTest >> testAnglePoint [
	(self sampleForces do: [ :each | (each -> each anglePoint) traceCr])
]

{ #category : #'tests-as yet unclassified' }
TwkForceTest >> testReversed [
	self assert: (((TwkForce angleDegress: 0) reversed) angleDegress closeTo: 180).
	self assert: (((TwkForce angleDegress: 45) reversed) angleDegress closeTo: 225).
	self assert: (((TwkForce angleDegress: 90) reversed) angleDegress closeTo: 270).
	self assert: (((TwkForce angleDegress: 135) reversed) angleDegress closeTo: 315).
	self assert: (((TwkForce angleDegress: 180) reversed) angleDegress closeTo: 0).
	self assert: (((TwkForce angleDegress: 225) reversed) angleDegress closeTo: 45).
	self assert: (((TwkForce angleDegress: 270) reversed) angleDegress closeTo: 90).
	self assert: (((TwkForce angleDegress: 315) reversed) angleDegress closeTo: 135).
	Transcript cr.
	(self sampleForces do: [ :each | (each -> each reversed) traceCr])		
	
]

{ #category : #'tests-as yet unclassified' }
TwkForceTest >> testSubtract [
	| f1 f2 sum |
	f1 := TwkForce new angleDegress: 0. 
	f2 := TwkForce new angleDegress: 180.
	sum := f1 - f2.
	self assert: (sum loadValue closeTo: 2).

	f1 := TwkForce new angleDegress: 0. 
	f2 := TwkForce new angleDegress: 0.
	sum := f1 - f2.
	self assert: (sum loadValue closeTo: 0).

	f1 := TwkForce new angleDegress: 45. 
	f2 := TwkForce new angleDegress: -45.
	sum := f1 - f2.
	self assert: (sum angleDegress closeTo: 90).
		
]

{ #category : #'tests-accessing' }
TwkForceTest >> testVector [
	(self sampleForces do: [ :each | (each -> each vector) traceCr])	
]

{ #category : #'tests-accessing' }
TwkForceTest >> testVectorSign [
	self assert: (TwkForce angleDegress: 0) vectorSign = (-1 @ 0).
	self assert: (TwkForce angleDegress: 45) vectorSign = (-1 @ -1).
	self assert: (TwkForce angleDegress: 90) vectorSign = (0 @ -1).
	self assert: (TwkForce angleDegress: 135) vectorSign = (1 @ -1).
	self assert: (TwkForce angleDegress: 180) vectorSign = (1 @ 0).
	self assert: (TwkForce angleDegress: 225) vectorSign = (1 @ 1).
	self assert: (TwkForce angleDegress: 270) vectorSign = (0 @ 1).
	self assert: (TwkForce angleDegress: 315) vectorSign = (-1 @ 1).
	(self sampleForces do: [ :each | (each -> each vectorSign) traceCr])	
]
