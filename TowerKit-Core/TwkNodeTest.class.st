"
A TwkNodeTest is a test class for testing the behavior of TwkNode
"
Class {
	#name : #TwkNodeTest,
	#superclass : #TestCase,
	#category : #'TowerKit-Core-Tests'
}

{ #category : #'tests-objects from disk' }
TwkNodeTest >> testStringCollectionToSymbols [
	| source actual expected |
	source := #('up' #('down' 'cross') 'upRight' 1) asOrderedCollection.
	expected := #(#up #(#down #cross) #upRight 1) asOrderedCollection.
	actual := TwkNode stringCollectionToSymbols: source.
	self assertCollection: actual equals: expected
	
]
