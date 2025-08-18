"
A GdsAcPointTest is a test class for testing the behavior of GdsAcPoint
"
Class {
	#name : #GdsAcPointTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-Model-ElementAddition-Tests'
}

{ #category : #'tests-accessing' }
GdsAcPointTest >> testCenterPoint [
]

{ #category : #'tests-accessing' }
GdsAcPointTest >> testDefaultInstance [
	GdsAcPoint basicNew initialize inspect.
]
