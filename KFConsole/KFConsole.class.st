"
Console abstract class.

override eventFetcherClass.

"
Class {
	#name : #KFConsole,
	#superclass : #Object,
	#instVars : [
		'eventFetcher',
		'getUserInput',
		'promptString',
		'stdOut',
		'announcer',
		'handlerTarget',
		'handlerSelector'
	],
	#category : #'KFConsole-Model'
}

{ #category : #'as yet unclassified' }
KFConsole class >> puts: anObject [
	self this puts: anObject
]

{ #category : #'as yet unclassified' }
KFConsole class >> this [
	^ KFConsoleMorph allInstances first model
]

{ #category : #accessing }
KFConsole >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #drawing }
KFConsole >> clearPrompt [
	getUserInput := nil
]

{ #category : #initialize }
KFConsole >> echoCommandLine: aCommandLine [
	self puts: aCommandLine
]

{ #category : #initialize }
KFConsole >> eventFetcher [
	^ eventFetcher
]

{ #category : #accessing }
KFConsole >> eventFetcherClass [
	^ KFEventFetcher
]

{ #category : #initialize }
KFConsole >> handleCommandLine: aCommandLine [
	| reply |
	reply := handlerTarget
		perform: handlerSelector
		withEnoughArguments:
			{aCommandLine.
			self}.
	self puts: reply
]

{ #category : #accessing }
KFConsole >> handleSelector: anSymbol [
	handlerSelector := anSymbol
]

{ #category : #accessing }
KFConsole >> handlerTarget: anObject [
	handlerTarget := anObject
]

{ #category : #initialize }
KFConsole >> initialize [
	super initialize.
	promptString := '$ ' asValueHolder.
	self eventFetcherClass
		ifNotNil: [ :clazz | 
			eventFetcher := clazz new.
			eventFetcher installEventLoop.
			eventFetcher everyBegin: [ self prompt ] ].
	self installSmalltalkREPL
]

{ #category : #initialize }
KFConsole >> installDefaultHandler [
	self handlerTarget: self.
	self handleSelector: #echoCommandLine:
]

{ #category : #initialize }
KFConsole >> installSmalltalkREPL [
	self
		handlerTarget: [ :cmd :console | 
			[ (Smalltalk evaluate: cmd) printString ]
				on: Error
				do: [ :ex | ex asString ] ].
	self handleSelector: #value:value:
]

{ #category : #initialize }
KFConsole >> postCommandLine: aCommandLine [
	eventFetcher
		ifNil: [ self handleCommandLine: aCommandLine.
			self clearPrompt.
			^ self inform: 'eventFetcher not installed: Only echo' ].
	eventFetcher
		addHandler: [ self handleCommandLine: aCommandLine.
			self clearPrompt ]
]

{ #category : #drawing }
KFConsole >> prompt [
	self prompt: self promptString
]

{ #category : #drawing }
KFConsole >> prompt: aString [
	getUserInput
		ifNil: [ self stdOut
				nextPutAll: aString;
				endEntry.
			getUserInput := 'DUMMY' ]
]

{ #category : #accessing }
KFConsole >> promptString [
	^ promptString value
]

{ #category : #accessing }
KFConsole >> promptString: aString [
	promptString value: aString
]

{ #category : #drawing }
KFConsole >> puts: aString [
	self stdOut
		nextPutAll: aString;
		ensureEndsWith: Character cr;
		endEntry
]

{ #category : #accessing }
KFConsole >> stdOut [
	^ stdOut ifNil: [ stdOut := ThreadSafeTranscript new ]
]
