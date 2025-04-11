Class {
	#name : 'GdsTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'model',
		'evaluator'
	],
	#category : 'GdsFeel-CLI-Test',
	#package : 'GdsFeel-CLI',
	#tag : 'Test'
}

{ #category : 'running' }
GdsTestCase >> setUp [
	super setUp.
	evaluator := GplEvaluator new
]

{ #category : 'running' }
GdsTestCase >> tearDown [
	evaluator := nil.
	model := nil
]
