"
A GdsConsoleTest is a test class for testing the behavior of GdsConsole
"
Class {
	#name : #KFConsoleTest,
	#superclass : #TestCase,
	#category : #'KFConsole-Tests'
}

{ #category : #tests }
KFConsoleTest >> testFoo [
	| console |
	console := KFConsole new.
	self inform: console printString
]
