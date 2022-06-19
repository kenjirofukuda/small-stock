"
A GdsConsole is Gds depend console.
"
Class {
	#name : #GdsConsole,
	#superclass : #KFConsole,
	#instVars : [
		'evaluator'
	],
	#category : #'GdsFeel-CLI-Console'
}

{ #category : #accessing }
GdsConsole >> eventFetcherClass [
	^ GdsEventFetcher
]

{ #category : #initialize }
GdsConsole >> handleCommandLine: aCommandLine [
	| result |
	result := aCommandLine trim
		ifNotEmpty: [ [ evaluator evaluateConsoleLine: aCommandLine ]
				on: Error
				do: [ :ex | ex asString ] ]
		ifEmpty: [ '' ].
	result ifNotEmpty: [ self puts: result ]
]

{ #category : #initialize }
GdsConsole >> initialize [
	super initialize.
	evaluator := GplEvaluator new
		console: self;
		yourself
]
