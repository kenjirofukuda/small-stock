"
A TwkArmTest is a test class for testing the behavior of TwkArm
"
Class {
	#name : #TwkArmTest,
	#superclass : #TestCase,
	#category : #'TowerKit-SandBox-Tests'
}

{ #category : #'as yet unclassified' }
TwkArmTest >> sampleInstance [
	^ TwkArm new name: 'C1R';
		yourself.
]

{ #category : #'tests-accessing' }
TwkArmTest >> testHeight [
	| inst |
	inst := self sampleInstance.
	self should: [inst length: 100] raise: Error.
	self should: [inst length: -1] raise: Error.

]

{ #category : #tests }
TwkArmTest >> testInstance [
	| inst |
	inst := self sampleInstance.
	inst length: 100 cm.
	inst explore
	
]

{ #category : #'tests-accessing' }
TwkArmTest >> testLength [
	| inst |
	inst := self sampleInstance.
	inst length: 18900 mm / 2.
	self assert: (inst length as m value closeTo: 9.45). 
	self should: [ inst length: 100 g  ] raise: Error.	

]

{ #category : #'tests-accessing' }
TwkArmTest >> testPhase [
	| inst |
	inst := self sampleInstance.
	self  should: [inst phase: 0] raise: AssertionFailure .
	
	"out of range"	
	self  should: [inst phase: 7] raise: AssertionFailure .
	
	"only integer"
	self  should: [inst phase: 1.1] raise: AssertionFailure .

	self  shouldnt: [inst phase: 1] raise: AssertionFailure .	
	self  shouldnt: [inst phase: 2] raise: AssertionFailure .	
	self  shouldnt: [inst phase: 3] raise: AssertionFailure .	
	self  shouldnt: [inst phase: 4] raise: AssertionFailure .
	self  shouldnt: [inst phase: 5] raise: AssertionFailure .	
	self  shouldnt: [inst phase: 6] raise: AssertionFailure .
	
					
]
