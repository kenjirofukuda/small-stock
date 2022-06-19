"
A KFSmalltalkBrowserTest is a test class for testing the behavior of KFSmalltalkBrowser
"
Class {
	#name : #KFSmalltalkBrowserTest,
	#superclass : #TestCase,
	#category : #'KFSeaside-Demos-Tests'
}

{ #category : #'tests-accessing' }
KFSmalltalkBrowserTest >> testVisibleMethods [
	| view |
	view := KFClassBrowserComponent new.
	self assert: view modelClass notNil.
	self assert: view children size = view visibleMethods size.
	view children first explore.
	"see: "
	RunArray >> #withStartStopAndValueDo:

	"startAnd~"
]
