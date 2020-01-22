Extension { #name : #CommandShellTranscript }

{ #category : #'*GdsFeel-CLI-CommandShell-extension' }
CommandShellTranscript >> openAsMorphLabel: labelString [ 
	"Build a morph viewing this stream"

	| window textMorph |
	window := SystemWindow new model: self.
	textMorph := self shellWindowMorphClass
					on: self
					text: nil
					accept: nil
					readSelection: nil
					menu: #codePaneMenu:shifted:.
	textMorph acceptOnCR: true.
	window addMorph: textMorph frame: (0@0 corner: 1@1).
	self prompt.
	labelString ifNotNil: [self labelStringBlock: [labelString]].
	self changed: #relabel.
	^ window
]

{ #category : #'*GdsFeel-CLI-CommandShell-extension' }
CommandShellTranscript >> shellWindowMorphClass [
	^ShellWindowMorph 
]
