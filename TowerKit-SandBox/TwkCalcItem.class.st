Class {
	#name : #TwkCalcItem,
	#superclass : #TwkNode,
	#instVars : [
		'value',
		'axisTags',
		'youngTags',
		'directionTags',
		'phaseTags',
		'fragmentLabel'
	],
	#category : #'TowerKit-SandBox'
}

{ #category : #'as yet unclassified' }
TwkCalcItem >> beC1 [
	phaseTags := #(#c1).
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beC2 [
	phaseTags := #(#c2).
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beC3 [
	phaseTags := #(#c3).
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beLR [
	self beLeftAndRight
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beLeft [
	directionTags := #(#left)
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beLeftAndRight [
	directionTags := #(#left #right)
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beOld [
	youngTags := #(#old)
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beRight [
	directionTags := #(#right)
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beX [
	axisTags := #( #x )
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beY [
	axisTags := #( #y )
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beYoung [
	youngTags := #(#young)
	
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> beYoungAndOld [
	youngTags := #(#young #old)
	
]

{ #category : #accessing }
TwkCalcItem >> checkUnit: aUnit [
	
]

{ #category : #accessing }
TwkCalcItem >> foo [
]

{ #category : #'as yet unclassified' }
TwkCalcItem >> fragmentLabel: aString [
	fragmentLabel := aString.
]

{ #category : #initialization }
TwkCalcItem >> initialize [
	super initialize.
	axisTags := #(#x #y).
	directionTags := #(#left #right).
	youngTags := #(#young #old).
	
	
]

{ #category : #accessing }
TwkCalcItem >> leftAndRight [
	directionTags := #(#left #right)
	
]

{ #category : #printing }
TwkCalcItem >> printOn: aStream [
	aStream nextPutAll: self printTitle.
	aStream nextPut: $(.
	self value printOn: aStream. 
	aStream nextPut: $). 	
]

{ #category : #printing }
TwkCalcItem >> printTitle [
	^ 'Calc'
]

{ #category : #accessing }
TwkCalcItem >> value [
	^ value
]

{ #category : #accessing }
TwkCalcItem >> value: aUnitValue [
	self assert: (aUnitValue isKindOf: UnitValue).	
	self checkUnit: aUnitValue unit baseUnits name. 
	value := aUnitValue.
]
