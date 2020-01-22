Class {
	#name : #GdsAbstractServer,
	#superclass : #Object,
	#instVars : [
		'connectionSocket',
		'isRunning',
		'isRunningLock',
		'portNumber',
		'serviceName'
	],
	#category : #'GdsFeel-CLI-Service'
}

{ #category : #'as yet unclassified' }
GdsAbstractServer class >> startOn: portNumber named: serviceName [
	^self new portNumber: portNumber; serviceName: serviceName; start.
]

{ #category : #'as yet unclassified' }
GdsAbstractServer class >> workspace [
"| server |	
server := EchoServer new.
server start."

]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> defaultBacklogSize [
	^10.
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> defaultPortNumber [
	^9999
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> defaultServiceName [
	^'untitled'
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> initialize [
	super initialize.
	isRunningLock := Mutex new.
	self isRunning: false.
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> interactOnConnection [
	| interactionSocket |
	interactionSocket := connectionSocket waitForAcceptFor: 1 ifTimedOut: [ ^self ].
	[self interactUsing: interactionSocket] fork.
 
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> interactUsing: interactionSocket [
 	| reciveData |
	[reciveData := interactionSocket receiveDataTimeout: 5.
	reciveData crTrace.
	interactionSocket sendData: 'ECHO:', reciveData]
		ensure: [ interactionSocket closeAndDestroy ]
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> isRunning [
	^isRunningLock critical: [isRunning]
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> isRunning: aBoolean [
	isRunningLock critical: [isRunning := aBoolean]
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> portNumber [
	^portNumber ifNil: [ portNumber := self defaultPortNumber ]
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> portNumber: aPortNumber [
	self isRunning ifTrue: [ ^self error: 'can''t change port number on running.' ].
	portNumber := aPortNumber.
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> serve [
	[[self isRunning]
		whileTrue: [ self interactOnConnection ]]
		ensure: [ connectionSocket closeAndDestroy ]
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> serviceName [
	^serviceName ifNil: [ serviceName := self defaultServiceName ]
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> serviceName: aServiceName [
	self isRunning ifTrue: [ ^self error: 'can''t change service name on running.' ].
	serviceName := aServiceName.
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> start [
	isRunningLock critical: [
		self isRunning ifTrue: [^self].
		self isRunning: true.].
	connectionSocket := Socket newTCP.
	connectionSocket listenOn: self portNumber backlogSize: self defaultBacklogSize.
	[ self serve ] forkNamed: self serviceName.
]

{ #category : #'as yet unclassified' }
GdsAbstractServer >> stop [
	self isRunning: false.
]
