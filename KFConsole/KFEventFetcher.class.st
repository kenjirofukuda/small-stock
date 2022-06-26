"
A KFEventFetcher is generic event fetch class.

"
Class {
	#name : #KFEventFetcher,
	#superclass : #Object,
	#instVars : [
		'eventHandlers',
		'everyBegin',
		'fetcherProcess',
		'quitSignal',
		'sema'
	],
	#category : #'KFConsole-Model'
}

{ #category : #adding }
KFEventFetcher >> addHandler: handler [
	sema critical: [ self eventHandlers add: handler ]
]

{ #category : #accessing }
KFEventFetcher >> eventBody [
	everyBegin ifNotNil: [ everyBegin value ].
	(Delay forMilliseconds: 500) wait.
	self popHandler
		ifNotNil: [ :handler | 
			handler value.
			(Delay forMilliseconds: 100) wait ]
]

{ #category : #accessing }
KFEventFetcher >> eventHandlers [
	^ eventHandlers ifNil: [ eventHandlers := OrderedCollection new ]
]

{ #category : #events }
KFEventFetcher >> eventLoop [
	[ (Delay forMilliseconds: 100) wait.
	self eventBody ]
		doWhileFalse: [ quitSignal and: [ self eventHandlers isEmpty ] ]
]

{ #category : #accessing }
KFEventFetcher >> everyBegin: handler [
	everyBegin := handler
]

{ #category : #accessing }
KFEventFetcher >> fetcherProcess [
	^ fetcherProcess
]

{ #category : #initialize }
KFEventFetcher >> initialize [
	super initialize.
	eventHandlers := nil.
	everyBegin := nil.
	fetcherProcess := nil.
	quitSignal := nil.
	sema := Semaphore forMutualExclusion
]

{ #category : #'initialize-release' }
KFEventFetcher >> installEventLoop [
	"Initialize the event loop process. Terminate the old process if any."

	"InputEventFetcher default installEventLoop"

	self terminateEventLoop.
	quitSignal := false.
	fetcherProcess := [ self eventLoop ]
		forkAt: Processor userSchedulingPriority.
	fetcherProcess name: self processName
]

{ #category : #'as yet unclassified' }
KFEventFetcher >> popHandler [
	| result |
	sema
		critical: [ self eventHandlers
				ifEmpty: [ result := nil ]
				ifNotEmpty: [ result := self eventHandlers last.
					eventHandlers := self eventHandlers allButLast ] ].
	^ result
]

{ #category : #accessing }
KFEventFetcher >> processName [
	^ 'Generic Event Fetcher'
]

{ #category : #'private protocol' }
KFEventFetcher >> quit [
	quitSignal := true
]

{ #category : #'as yet unclassified' }
KFEventFetcher >> quitAfter: aBlock [
	self quit.
	[ [ self fetcherProcess isTerminated ]
		whileFalse: [ (Delay forSeconds: 1) wait ].
	aBlock value ] fork
]

{ #category : #controlling }
KFEventFetcher >> restart [
	self fetcherProcess isTerminated
		ifTrue: [ self installEventLoop ]
]

{ #category : #accessing }
KFEventFetcher >> size [
	| result |
	sema critical: [ result := self eventHandlers size ].
	^ result
]

{ #category : #'initialize-release' }
KFEventFetcher >> terminateEventLoop [
	"Terminate the event loop process. Terminate the old process if any."

	"InputEventFetcher default terminateEventLoop"

	fetcherProcess ifNotNil: [ fetcherProcess terminate ]
]

{ #category : #handlers }
KFEventFetcher >> unregisterHandler: handler [
	self eventHandlers remove: handler ifAbsent: [  ]
]
