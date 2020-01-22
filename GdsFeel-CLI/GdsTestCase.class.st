Class {
	#name : #GdsTestCase,
	#superclass : #TestCase,
	#instVars : [
		'model',
		'evaluator'
	],
	#category : #'GdsFeel-CLI-Test'
}

{ #category : #running }
GdsTestCase >> setUp [
	super setUp.
	evaluator := GplEvaluator new.
	
]

{ #category : #running }
GdsTestCase >> tearDown [
	evaluator := nil.
	model := nil.
	
]
