"
A GdsBooleanPropertyTest is a test class for testing the behavior of GdsBooleanProperty
"
Class {
	#name : #GdsBooleanPropertyTest,
	#superclass : #TestCase,
	#category : #'GdsFeel-Foundation-Tests'
}

{ #category : #tests }
GdsBooleanPropertyTest >> testSetValue [
	| prop |	
	prop := GdsBooleanProperty named: 'example' owner: nil.	
	self should: [ prop setValue: 1 ] raise: Exception. 
	self should: [ prop setValue: #true ] raise: Exception. 
	self should: [ prop setValue: nil ] raise: Exception. 
	self should: [ prop setValue: #() ] raise: Exception. 
	self should: [ prop setValue: 'true' ] raise: Exception. 
	
	self shouldnt: [ prop setValue: true ] raise: Exception. 
	self shouldnt: [ prop setValue: false ] raise: Exception. 
	
]

{ #category : #tests }
GdsBooleanPropertyTest >> testToggle [
	| prop |	
	prop := GdsBooleanProperty named: 'example' owner: nil.	
	self assert: prop getValue = false.
	prop toggle.
	self assert: prop getValue = true.
	prop toggle.
	self assert: prop getValue = false.
		
]
