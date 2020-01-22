"
A GdsNumberPropertyTest is a test class for testing the behavior of GdsNumberProperty
"
Class {
	#name : #GdsNumberPropertyTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-Foundation-Tests'
}

{ #category : #tests }
GdsNumberPropertyTest >> testDown [
	| prop |
	
	prop := GdsNumberProperty new.	
	self assert: prop getValue = 0.	
	prop down.
	self assert: prop getValue = -1.	
	prop down.
	prop down.
	self assert: prop getValue = -3.	
	prop down: 5.
	self assert: prop getValue = -8.	
	prop down: -5. 
	self assert: prop getValue = -13 description: 'value convert to absolute'.	
	
]

{ #category : #tests }
GdsNumberPropertyTest >> testUp [
	| prop |
	
	prop := GdsNumberProperty new.	
	self assert: prop getValue = 0.	
	prop up.
	self assert: prop getValue = 1.	
	prop up.
	prop up.
	self assert: prop getValue = 3.	
	prop up: 5.
	self assert: prop getValue = 8.	
	prop up: -5. 
	self assert: prop getValue = 13 description: 'value convert to absolute'.	
	
]
