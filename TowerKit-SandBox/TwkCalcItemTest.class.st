"
A TwkCalcItemTest is a test class for testing the behavior of TwkCalcItem
"
Class {
	#name : #TwkCalcItemTest,
	#superclass : #TestCase,
	#category : #'TowerKit-SandBox-Tests'
}

{ #category : #'tests-as yet unclassified' }
TwkCalcItemTest >> testFoo [
	| item |
	item := TwkWeightItem new name: 'がいし重量'.
	item value: 60 kg.
"	item unit: #kg.	"
	item explore.
]

{ #category : #'tests-as yet unclassified' }
TwkCalcItemTest >> testSampleCableLength [
	| item |
	item := TwkLengthItem new name: '荷算径間'.
	item value: 46 m .
	"item unit: #m."
	item explore.
	
]

{ #category : #'tests-as yet unclassified' }
TwkCalcItemTest >> testSampleInsuratorWeight [
	| item |
	item := TwkWeightItem new name: 'がいし重量'.
	item value: 60 kg.
	"item unit: #kg.	"
	item explore.
]

{ #category : #'tests-as yet unclassified' }
TwkCalcItemTest >> testSampleWindPressure [
	| item |
	item := TwkForceItem  new name: 'がいし風圧'.
	item value: 60 N.
	"item unit: #N."
	"item per: #unit.	"
	item explore.
	
]
