Class {
	#name : #GdsCommandShellTranscript,
	#superclass : #CommandShellTranscript,
	#category : #'GdsFeel-CLI-CommandShell'
}

{ #category : #'as yet unclassified' }
GdsCommandShellTranscript class >> defaultWindowName [

	^ 'GDS II Shell'
]

{ #category : #'as yet unclassified' }
GdsCommandShellTranscript >> cliShell [
	"Answer the value of cliShell"

	^ cliShell ifNil: [cliShell := GdsCommandShell new]
]

{ #category : #'as yet unclassified' }
GdsCommandShellTranscript >> shellWindowMorphClass [
	^GdsShellWindowMorph 
]
