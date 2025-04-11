Class {
	#name : 'GdsListTest',
	#superclass : 'GdsTestCase',
	#category : 'GdsFeel-CLI-Test',
	#package : 'GdsFeel-CLI',
	#tag : 'Test'
}

{ #category : 'private' }
GdsListTest >> sampleList [
	^ evaluator evaluateLine: '"ABC" ; IOTA 3 ; 3 4 RESHAPE IOTA 12'
]

{ #category : 'tests' }
GdsListTest >> testAtSubscript [
	evaluator evaluateLine: 'L := "ABC"; IOTA 3'.
	self
		should: [ evaluator evaluateLine: 'L[0]' ]
		raise: GplRuntimeError.
	self
		should: [ evaluator evaluateLine: 'L[3]' ]
		raise: GplRuntimeError.
	self should: [ evaluator evaluateLine: 'L[]' ] raise: GplRuntimeError.
	self
		shouldnt: [ evaluator evaluateLine: 'L[1.0]' ]
		raise: GplRuntimeError.
	self
		should: [ evaluator evaluateLine: 'L[1.1]' ]
		raise: GplRuntimeError.
	self
		should: [ evaluator evaluateLine: 'L[2;2]' ]
		raise: GplRuntimeError.
	self
		shouldnt: [ evaluator evaluateLine: 'L[1]' ]
		raise: GplRuntimeError.
	self
		shouldnt: [ evaluator evaluateLine: 'L[2]' ]
		raise: GplRuntimeError
]

{ #category : 'tests' }
GdsListTest >> testIsList [
	self assert: self sampleList isList
]

{ #category : 'tests' }
GdsListTest >> testLength [
	self assert: self sampleList length = 3
]

{ #category : 'tests' }
GdsListTest >> testMode [
	self assert: self sampleList mode = 6
]

{ #category : 'tests' }
GdsListTest >> testShape [
	self should: [ self sampleList shape ] raise: GplError
]

{ #category : 'tests' }
GdsListTest >> testSize [
	self should: [ self sampleList size ] raise: GplError
]

{ #category : 'tests' }
GdsListTest >> testTypeString [
	self assert: self sampleList typeString = 'LIST'
]
