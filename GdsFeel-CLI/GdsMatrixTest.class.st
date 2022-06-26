Class {
	#name : #GdsMatrixTest,
	#superclass : #GdsTestCase,
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #private }
GdsMatrixTest >> sampleMatrix [
	^ evaluator evaluateLine: '3 4 RESHAPE IOTA 12'
]

{ #category : #tests }
GdsMatrixTest >> testIsList [
	self deny: self sampleMatrix isList
]

{ #category : #tests }
GdsMatrixTest >> testLength [
	self assert: self sampleMatrix length = 1
]

{ #category : #tests }
GdsMatrixTest >> testMode [
	self assert: self sampleMatrix mode = 2
]

{ #category : #tests }
GdsMatrixTest >> testShape [
	self assert: self sampleMatrix shape = #(3 4)
]

{ #category : #tests }
GdsMatrixTest >> testSize [
	self assert: self sampleMatrix size = 12.
	evaluator evaluateLine: 'M := 3 4 RESHAPE IOTA 12'.
	"SIZE INVARIANT using MONADIC operators"
	self assert: (evaluator evaluateLine: 'SIZE M') asSmalltalkValue = 12.
	self
		assert: (evaluator evaluateLine: 'SIZE -M') asSmalltalkValue = 12.
	self
		assert: (evaluator evaluateLine: 'SIZE +M') asSmalltalkValue = 12.
	self
		assert: (evaluator evaluateLine: 'SIZE *M') asSmalltalkValue = 12.
	self
		assert: (evaluator evaluateLine: 'SIZE %M') asSmalltalkValue = 12
]

{ #category : #tests }
GdsMatrixTest >> testTypeString [
	self deny: self sampleMatrix typeString = 'MATRIX'.
	self assert: self sampleMatrix typeString = 'INTEGER'
]
