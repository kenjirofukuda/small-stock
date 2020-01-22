Class {
	#name : #GdsCommandShell,
	#superclass : #CommandShell,
	#instVars : [
		'evaluator'
	],
	#category : #'GdsFeel-CLI-CommandShell'
}

{ #category : #'as yet unclassified' }
GdsCommandShell class >> example [
	"self example"
	self open.
]

{ #category : #defaults }
GdsCommandShell >> defaultPromptString [

	^ '? '
]

{ #category : #defaults }
GdsCommandShell >> evaluationProxyFor: aCommandString input: in output: out error: err [
	"Answer a PipeableEvaluator on a doIt command, or nil."

	"GdsCommandShell new evaluationProxyFor: 'Smalltalk' input: nil output: nil error: nil"
	"GdsCommandShell new evaluationProxyFor: 'BOGUS' input: nil output: nil error: nil"

	| proxy |
	proxy := GdsExpressionEvaluator
				command: aCommandString
				pipeFrom: in
				pipeTo: out
				errorPipelineStream: err.
	proxy gplEvaluator: evaluator. 
	^ proxy

]

{ #category : #'initialize-release' }
GdsCommandShell >> initialize [
	super initialize.
	evaluator := GplEvaluator new.
	
]

{ #category : #defaults }
GdsCommandShell >> processCommand: aCommandString echo: showCommand [
	"self halt."
	super processCommand: aCommandString echo: showCommand.
]

{ #category : #accessing }
GdsCommandShell >> shellSyntax [
	"A pluggable instance of a command processing syntax"

	^ shellSyntax ifNil: [shellSyntax := GdsShellSyntax new]
]
