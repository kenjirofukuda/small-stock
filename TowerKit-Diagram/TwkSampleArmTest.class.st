"
A TwkSampleArmTest is a test class for testing the behavior of TwkSampleArm
"
Class {
	#name : #TwkSampleArmTest,
	#superclass : #TestCase,
	#category : #'TowerKit-Diagram-Tests'
}

{ #category : #'tests-accessing' }
TwkSampleArmTest >> testBodyPoints [
	| arm |
	arm := TwkSampleArm new.
	self inform: (arm bodyPositions ) asString
]

{ #category : #'tests-accessing' }
TwkSampleArmTest >> testReactionForce [
	| arm |
	arm := TwkSampleArm new.
	self inform: (arm reactionForce ) asString
]
