Class {
	#name : #TwkTrussJoint,
	#superclass : #TwkTrussPoint,
	#instVars : [
		'type',
		'forces'
	],
	#category : #'TowerKit-Diagram'
}

{ #category : #utility }
TwkTrussJoint class >> sortForces: aTwkForceCollection orderSymbolArray: aSymbolArray [
	^ aTwkForceCollection sort: [ :a :b |  (aSymbolArray indexOf: a hvSymbol) < (aSymbolArray indexOf: b hvSymbol)]
]

{ #category : #adding }
TwkTrussJoint >> addForce: aTwkForce [
	forces add: aTwkForce.
	aTwkForce parent: self
	
]

{ #category : #accessing }
TwkTrussJoint >> forces [
	^ forces
]

{ #category : #accessing }
TwkTrussJoint >> forcesCompositOrdered [
	| hValuePoint vValuePoint hForce vForce |
	self forces ifEmpty: [ ^ #() ].
	hValuePoint := (self forces collect: [ :each | each loadValueOfHorizontal ]) sum @ 0.
	vValuePoint := 0 @ ((self forces collect: [ :each | each loadValueOfVertical ]) sum).
	hForce := (TwkForce new
		loadValue: hValuePoint r;
		angleDegress: hValuePoint angleDegress;
		yourself) reversed.
	vForce := (TwkForce new
		loadValue: vValuePoint r;
		angleDegress: vValuePoint angleDegress;
		yourself) reversed.
	^ self class sortForces: { hForce . vForce } orderSymbolArray: self hvOrderOfForce  
]

{ #category : #accessing }
TwkTrussJoint >> forcesOrdered [
	^ self class sortForces: self forces orderSymbolArray: self hvOrderOfForce. 
]

{ #category : #testing }
TwkTrussJoint >> hasForce [
	^ self forces notEmpty
]

{ #category : #accessing }
TwkTrussJoint >> horizontalForce [
	^ (self forcesCompositOrdered select: [ :each | each isHorizontal ]) sum
]

{ #category : #accessing }
TwkTrussJoint >> hvOrderOfForce [
	((self nearAngle closeTo: 0) or: [ self nearAngle closeTo: 180 ])
		ifTrue: [ ^ Array with: #horizontal with: #vertical ].
	^ Array with: #vertical with: #horizontal
		
]

{ #category : #initialization }
TwkTrussJoint >> initialize [
	super initialize.
	type := #normal.
	forces := OrderedCollection new.

]

{ #category : #accessing }
TwkTrussJoint >> ownerMembers [
	^ self world members select: [ :each | each hasJointName: self name ]
]

{ #category : #accessing }
TwkTrussJoint >> ownerMembersBaseAngle: aDegress [
	^ self ownerMembersBaseAngle: aDegress ccw: false
]

{ #category : #accessing }
TwkTrussJoint >> ownerMembersBaseAngle: aDegress ccw: ccw [
	^ self ownerMembers 
		sort: [ :a :b |
			| angle1 angle2 |
			angle1 := ((a angleDegressBaseNamed: self name) - aDegress) degressNormalized.
			angle2 := ((b angleDegressBaseNamed: self name) - aDegress) degressNormalized.
			((angle2 closeTo: 0.0) and: [ ccw ])
			 ifTrue: [ angle1 < angle2 ] ifFalse: [ angle1 > angle2 ] ]
]

{ #category : #accessing }
TwkTrussJoint >> topLetter [
	^ 'J'
]

{ #category : #accessing }
TwkTrussJoint >> type [
	^ type
	
]

{ #category : #accessing }
TwkTrussJoint >> type: aSymbol [
	self assert: ( #(#normal #pin #roller fixed #force) includes: aSymbol).
	type := aSymbol.
]

{ #category : #accessing }
TwkTrussJoint >> verticalForce [
	^ (self forcesCompositOrdered select: [ :each | each isVertical ]) sum
]
