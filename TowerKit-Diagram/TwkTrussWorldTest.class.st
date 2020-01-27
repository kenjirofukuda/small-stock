Class {
	#name : #TwkTrussWorldTest,
	#superclass : #TestCase,
	#category : #'TowerKit-Diagram-Tests'
}

{ #category : #'as yet unclassified' }
TwkTrussWorldTest >> sampleWorld [
	| world  |
	world := TwkTrussWorld new.
	world fillSampleArm. 
	^ world
	
]

{ #category : #'tests-accessing' }
TwkTrussWorldTest >> testAxisMembers [
	| members f1 f2 ff |
	members := self sampleWorld axisMembers. 
	members do: [ :each |
		Transcript cr; show: '-------------------------'; cr.
		ff := (each asLineSegment isHorizontal)
			ifTrue: [
				f1 := each fromJoint horizontalForce.
				f2 := each toJoint horizontalForce.
				f1 - f2 ]
			ifFalse: [
				f1 := each fromJoint verticalForce.
				f2 := each toJoint verticalForce.
				f1 - f2 ].
		(each -> ff) traceCr.
	 		].

]

{ #category : #'as yet unclassified' }
TwkTrussWorldTest >> testFillSampleArm [
	self sampleWorld explore
]

{ #category : #'tests-accessing' }
TwkTrussWorldTest >> testForcesCompositeOrdered [
	Transcript cr; show: '-------------'; cr.
	self sampleWorld joints do: [ :each |
		| forces |
		forces := each forcesCompositOrdered.
		forces do: [ :f |
			(each -> f ) traceCr.]
		 ]
]

{ #category : #'tests-as yet unclassified' }
TwkTrussWorldTest >> testLoadDictionaryPoints [
	| map |
	map := self sampleWorld loadDictionaryPoints .
	(map keys sort: [ :a :b | a number < b number ]) 
		do: [ :key |
			(key -> (map at: key)) traceCr ]
]

{ #category : #'tests-accessing' }
TwkTrussWorldTest >> testLoadValuesHorizontal [
	self assert: (self sampleWorld loadValuesHorizontal sum closeTo: 0)
]

{ #category : #'tests-accessing' }
TwkTrussWorldTest >> testLoadValuesVertical [
	self assert: (self sampleWorld loadValuesHorizontal sum closeTo: 0)
]

{ #category : #'tests-instance creation' }
TwkTrussWorldTest >> testNewJointTyped [
	| world |
	world := TwkTrussWorld new.
	world newJointTyped: #pin.
	self assert: world notNil
]

{ #category : #'as yet unclassified' }
TwkTrussWorldTest >> testOwnerMembers [
	Transcript cr; show: '-------------'; cr.
	self sampleWorld joints do: [ :eachJoint |
		eachJoint traceCr.
		eachJoint ownerMembers do: [ :eachMember |
			(eachMember  -> (eachMember angleDegressBaseNamed: eachJoint name)) traceCr. ].	
			Transcript cr; show: '-------------'; cr.]
]

{ #category : #'as yet unclassified' }
TwkTrussWorldTest >> testOwnerMembersAngleBased [
	Transcript cr; show: '-------------'; cr.
	self sampleWorld joints do: [ :eachJoint |
		eachJoint traceCr.
		(eachJoint ownerMembersBaseAngle: 0)  do: [ :eachMember |
			(eachMember  -> (eachMember angleDegressBaseNamed: eachJoint name)) traceCr. ].	
			Transcript cr; show: '-------------'; cr.]
]

{ #category : #'as yet unclassified' }
TwkTrussWorldTest >> testSampleArm2 [
	| world arm |
	world := TwkTrussWorld  new.
	arm := TwkSampleArm new.
	world newPin.
	world newPin.
	world newPin.
	world newPin.
	world newForce.	
	world explore.
]
