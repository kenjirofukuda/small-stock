"
A GplLanguageTest is a test class for testing the behavior of GplLanguage
"
Class {
	#name : 'GplLanguageTest',
	#superclass : 'TestCase',
	#category : 'GdsFeel-CLI-Tests',
	#package : 'GdsFeel-CLI',
	#tag : 'Tests'
}

{ #category : 'tests-as yet unclassified' }
GplLanguageTest >> testInitializeKeywords [
	GplLanguage new explore
]
