"
A GdsEventFetcher is xxxxxxxxx.

"
Class {
	#name : #GdsEventFetcher,
	#superclass : #KFEventFetcher,
	#category : #'GdsFeel-CLI-Console'
}

{ #category : #'as yet unclassified' }
GdsEventFetcher >> addHandler: handler [
	sema critical: [ self eventHandlers add: handler ]
]

{ #category : #accessing }
GdsEventFetcher >> eventBody [
	everyBegin ifNotNil: [ everyBegin value ].
	(Delay forMilliseconds: 500) wait.
	self popHandler
		ifNotNil: [ :handler | 
			handler value.
			(Delay forMilliseconds: 100) wait ]
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> eventHandlers [
	^ eventHandlers ifNil: [ eventHandlers := OrderedCollection new ]
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> eventLoop [
	[ (Delay forMilliseconds: 100) wait.
	self eventBody ]
		doWhileFalse: [ quitSignal and: [ self eventHandlers isEmpty ] ]
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> everyBegin: handler [
	everyBegin := handler
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> fetcherProcess [
	^ fetcherProcess
]

{ #category : #initialize }
GdsEventFetcher >> initialize [
	super initialize.
	eventHandlers := nil.
	everyBegin := nil.
	fetcherProcess := nil.
	quitSignal := nil.
	sema := Semaphore forMutualExclusion
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> installEventLoop [
	"Initialize the event loop process. Terminate the old process if any."

	"InputEventFetcher default installEventLoop"

	self terminateEventLoop.
	quitSignal := false.
	fetcherProcess := [ self eventLoop ]
		forkAt: Processor userSchedulingPriority.
	fetcherProcess name: 'Gds Event Fetcher Process'
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> popHandler [
	| result |
	sema
		critical: [ self eventHandlers
				ifEmpty: [ result := nil ]
				ifNotEmpty: [ result := self eventHandlers last.
					eventHandlers := self eventHandlers allButLast ] ].
	^ result
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> processName [
	^ 'Gds Event Fetcher'
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> quit [
	quitSignal := true
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> quitAfter: aBlock [
	self quit.
	[ [ self fetcherProcess isTerminated ]
		whileFalse: [ (Delay forSeconds: 1) wait ].
	aBlock value ] fork
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> restart [
	self fetcherProcess isTerminated
		ifTrue: [ self installEventLoop ]
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> size [
	| result |
	sema critical: [ result := self eventHandlers size ].
	^ result
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> terminateEventLoop [
	"Terminate the event loop process. Terminate the old process if any."

	"InputEventFetcher default terminateEventLoop"

	fetcherProcess ifNotNil: [ fetcherProcess terminate ]
]

{ #category : #'as yet unclassified' }
GdsEventFetcher >> unregisterHandler: handler [
	self eventHandlers remove: handler ifAbsent: [  ]
]
