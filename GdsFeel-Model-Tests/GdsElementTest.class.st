"
A GdsElementTest is a test class for testing the behavior of GdsElement
"
Class {
	#name : #GdsElementTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-Model-Tests'
}

{ #category : #'tests-copying' }
GdsElementTest >> testCopy [
	| src dest |
	GdsStation default structure
		ifNotNil: [ :s | 
			s elements
				do: [ :e | 
					src := e.
					dest := src copy.
					self assert: src ~~ dest.
					self assert: dest state equals: #inStructure ] ]
]

{ #category : #'tests-copying' }
GdsElementTest >> testPostCopy [
]
