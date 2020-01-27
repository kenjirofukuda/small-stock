"
A TwkBlockEntryTest is a test class for testing the behavior of TwkBlockEntry
"
Class {
	#name : #TwkTaperTest,
	#superclass : #TestCase,
	#category : #'TowerKit-SandBox-Tests'
}

{ #category : #'tests-accessing - block entry' }
TwkTaperTest >> sampleEntry1 [
	| ent |
	ent := TwkTaper new.
	ent firstValue: 0.
	ent lastValue: 947.368421.
	ent interVolume: 2500.
	^ ent

]

{ #category : #'tests-accessing - block entry' }
TwkTaperTest >> testKorobi [
	| ent |
	ent := self sampleEntry1.
	self assert: (ent korobi closeTo: 0.18947368).

]

{ #category : #'tests-accessing - block entry' }
TwkTaperTest >> testNobi [
	| ent |
	ent := self sampleEntry1.
	self assert: (ent nobi closeTo: 1.01779186).

]
