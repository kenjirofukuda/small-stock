"
An OkbWireInputTest is a test class for testing the behavior of OkbWireInput
"
Class {
	#name : #TwkWireInputTest,
	#superclass : #TestCase,
	#category : #'TowerKit-Magritte'
}

{ #category : #'tests-initialization' }
TwkWireInputTest >> testAsComponent [
	| inst |
	inst := TwkWireInput new.
	inst degress1: 30.
	inst magritteDescription explore.
]

{ #category : #'tests-initialization' }
TwkWireInputTest >> testInitialize [
	| inst |
	inst := TwkWireInput new.
	inst explore.
]

{ #category : #'tests-initialization' }
TwkWireInputTest >> testOpenAsMorph [
	| inst |
	inst := TwkWireInput new.
	inst maEdit.
	inst explore.
]
