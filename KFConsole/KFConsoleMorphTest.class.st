"
A GdsConsoleMorphTest is a test class for testing the behavior of GdsConsoleMorph
"
Class {
	#name : #KFConsoleMorphTest,
	#superclass : #TestCase,
	#category : #'KFConsole-Tests'
}

{ #category : #'tests-as yet unclassified' }
KFConsoleMorphTest >> testDrawOn [
	| m |
	m := KFConsoleMorph new.
	(m embeddedInMorphicWindowLabeled: 'Console')
		ifNotNil: [ :w |
			 w openInWorld ].
]
