"
A KFMethodViewComponentTest is a test class for testing the behavior of KFMethodViewComponent
"
Class {
	#name : #KFMethodViewComponentTest,
	#superclass : #TestCase,
	#category : #'KFSeaside-Demos-Tests'
}

{ #category : #'tests-accessing' }
KFMethodViewComponentTest >> testFillShoutRanges [
	| view items |
	"comment here"
	view := KFMethodViewComponent new
		compiledMethod: KFMethodViewComponent >> #compiledMethod:;
		yourself.
	items := view fillShoutRanges
		collect: [ :range | 
			| fragment |
			fragment := view displaySourceCode
				copyFrom: range start
				to: range end.
			fragment
				->
					{range type.
					(range start to: range end)} ].
	items explore
]

{ #category : #'tests-accessing' }
KFMethodViewComponentTest >> testLookupShoutRanges [
	| view items |
	"comment here"
	view := KFMethodViewComponent new
		compiledMethod: self class >> #testLookupShoutRanges;
		yourself.
	items := view lookupShoutRanges
		collect: [ :range | 
			| fragment |
			fragment := view displaySourceCode
				copyFrom: range start
				to: range end.
			fragment
				->
					{range type.
					(range start to: range end)} ].
	items explore
]

{ #category : #'tests-rendering' }
KFMethodViewComponentTest >> testStyle [
	| view |
	view := KFMethodViewComponent new
		compiledMethod: self class >> #testLookupShoutRanges;
		yourself.
	view style explore
]

{ #category : #'tests-accessing' }
KFMethodViewComponentTest >> testText [
	"comment hear"

	| view words |
	view := KFMethodViewComponent new
		compiledMethod: self class >> #testText;
		yourself.
	words := Array
		streamContents: [ :s | 
			view text runs
				withStartStopAndValueDo:
					[ :start :stop :values | s nextPut: (view displaySourceCode copyFrom: start to: stop) -> values ] ].
	words explore
]
