Class {
	#name : #TwkLengthItem,
	#superclass : #TwkCalcItem,
	#category : #'TowerKit-SandBox'
}

{ #category : #'as yet unclassified' }
TwkLengthItem >> checkUnit: aString [
	self assert: (#('metre') includes: aString).
]

{ #category : #'as yet unclassified' }
TwkLengthItem >> printTitle [
	^ 'Length'
]
