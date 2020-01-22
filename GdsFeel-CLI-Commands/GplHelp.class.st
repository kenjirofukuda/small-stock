Class {
	#name : #GplHelp,
	#superclass : #GplSingleHandler,
	#category : #'GdsFeel-CLI-Commands'
}

{ #category : #'as yet unclassified' }
GplHelp class >> expand: aString tabSize: tabSize [
	"self expand: '		aho		' tabSize: 4"
	|  s c o |
	o := WriteStream on: String new. 
	s := aString readStream.
	[s atEnd]
		whileFalse: [ 
			c := s next.			
			c = Character tab
				ifTrue: [ | step |
					step := tabSize - (s position \\ tabSize).
					step timesRepeat: [o nextPut: Character space].
					]
				ifFalse: [o nextPut: c].].
	^o contents
]

{ #category : #'as yet unclassified' }
GplHelp class >> expandTab: aString [
	^self expand: aString tabSize: 8.
	 
]

{ #category : #'as yet unclassified' }
GplHelp class >> methodName [
	^'HELP'
	
]

{ #category : #handler }
GplHelp >> evaluateToken: aToken [ 
	| arg1 helpName helpFile lines text |
	(evaluator numArgs: aToken) < 1 
		ifTrue: [^ self runtimeError: 'Usage: HELP "CommandName" '].

	arg1 := evaluator popArg asGplValue.
	self mustbeString: arg1.
	helpName := arg1 gplString.

	self helpFolder isDirectory
		ifFalse: [ ^self runtimeError: 'help document not setup.' ].
		
	helpFile := self helpFolder files 
		detect: [:fref | fref basenameWithoutExtension  sameAs: helpName] ifNone: [].
	helpFile ifNil: [ ^self runtimeError: ('Not found: ', helpName) ].
	
	OSProcess isWindows 
		ifFalse: [
			text :=(PipeableOSProcess command: 'tr "\r" "\n" < "',helpFile fullName , '" | expand ') upToEnd.
			^self strings: text lines].
	
	"expandTab: has BUG. but Windows..."	
	lines := helpFile readStream contents lines collect: [:line | self class expandTab: line].
	"lines explore."
	
	^self strings: lines.
]

{ #category : #handler }
GplHelp >> helpFolder [
	^FileLocator home / 'Dropbox' / 'gds' / 'calma4' / 'help'.

]
