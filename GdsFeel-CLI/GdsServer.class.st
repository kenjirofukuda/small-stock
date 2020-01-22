"
A GdsServer is xxxxxxxxx.

Instance Variables
	evaluter:		<GplEvaluter>
	sessionMap:		<Dictionary<Integer,GdsIoSession>>

evaluter
	- xxxxx

sessionMap
	- xxxxx

"
Class {
	#name : #GdsServer,
	#superclass : #GdsAbstractServer,
	#instVars : [
		'sessionMap',
		'evaluator'
	],
	#classInstVars : [
		'server'
	],
	#category : #'GdsFeel-CLI-Service'
}

{ #category : #convert }
GdsServer class >> chomp: aString [
	| lastIndex index|
	aString isEmpty ifTrue: [^''].
	lastIndex :=  aString size.
	index := lastIndex.
	[index >= 1]
		whileTrue: [
			| c |
			c := aString at: index.
			((c = Character lf) or: [c = Character cr])
				ifFalse: [^aString copyFrom: 1 to: index].
			index := index - 1.].
	^aString.
]

{ #category : #constant }
GdsServer class >> eoString [
	^(Character value: 0) asString
]

{ #category : #accessing }
GdsServer class >> showsLog: aBoolean [
	server ifNotNil: [server showsLog: aBoolean].
]

{ #category : #accessing }
GdsServer class >> start [
	"self start"
	server ifNotNil: [
		'!!! Server already running !!!' crTrace. 
		^self]. 
	server := self startOn: 9999 named: 'gds'.
	
]

{ #category : #accessing }
GdsServer class >> stop [
	server ifNil: [
		Transcript cr; show: '!!! Server already stopped !!!'. 
		^self]. 
	server stop.
	server := nil.
	
]

{ #category : #'development support' }
GdsServer class >> workspace [

GdsServer start.



GdsServer stop.

]

{ #category : #conversation }
GdsServer >> clearSession [
	sessionMap := nil.
	evaluator flushContextStacks.
		
]

{ #category : #accessing }
GdsServer >> debugLog: aObject [
	evaluator debugLog: aObject.
]

{ #category : #conversation }
GdsServer >> endSession [
	self clearSession


		
]

{ #category : #conversation }
GdsServer >> getReciveSession: aGdsInRecord [
	| session |
	session := self sessionOfNumber: aGdsInRecord session.
	session addRecord: aGdsInRecord.
	^session
]

{ #category : #conversation }
GdsServer >> implementedMethodNames [
	| col |
	col := OrderedCollection new.
	col addAll: GplHandler commandNames.
	col addAll: GplToken implementedMonadicMethods.
	col addAll: GplToken implementedDyadicMethods.
	^col asSet asArray.
]

{ #category : #initialization }
GdsServer >> initialize [
	super initialize.
	evaluator := GplEvaluator new.
]

{ #category : #conversation }
GdsServer >> interactUsing: interactionSocket [
	self serve: interactionSocket
]

{ #category : #conversation }
GdsServer >> send: aString on: aSocket [
	aSocket sendData: ((self class chomp: aString), self class eoString) .
	self debugLog: (self class chomp: aString).

]

{ #category : #conversation }
GdsServer >> serve: aSocket [ 
	| reciveData bytes |
	reciveData := aSocket receiveData. 
	bytes := reciveData asByteArray.

	WorldState addDeferredUIMessage: [	
		(bytes isEmpty not and: [(#(0 1 2) includes: (bytes first))]) 
			ifTrue: [self serveNew: aSocket reciveData: reciveData]
			ifFalse: [self serveClassic: aSocket reciveData: reciveData].].
]

{ #category : #conversation }
GdsServer >> serveClassic: aSocket reciveData: reciveData [
	| data |
	data := self class chomp: reciveData.
	data ifEmpty: [^self].
	self debugLog: (Time now printString, ': ' ,'<',data,'>').
	[| reply | 
	  reply := evaluator evaluateConsoleLine: data.
	 self send: reply on: aSocket .]
		on: Error do: [:ex | self send: ex asString on: aSocket].
]

{ #category : #conversation }
GdsServer >> serveNew: aSocket reciveData: reciveData [ 
	| ioForInspect session replySession reply isPrompt arg evaluateBlock |
	ioForInspect := GdsIoRecive fromByteArray: reciveData asByteArray.
	ioForInspect isSessionEnter
		ifTrue: [^ self startSession: aSocket].	
				
	ioForInspect isSessionExit
		ifTrue: [^ self endSession].		
	session := self getReciveSession: ioForInspect.
	session hasMoreData ifTrue: [^ self].

	arg := session asString.
	evaluateBlock := [:arg1 | evaluator evaluateConsoleLine: arg1].
	ioForInspect isTypePromptReply 
		ifTrue: [ 
			evaluator pushResult:  session asString.
			evaluateBlock := [:arg1 | 
				evaluator evaluateAsString: [evaluator resume]]].

	replySession := GdsReplySession new session: session session.
	isPrompt := false.

	self debugLog: Time now printString , ': ' , '<' , arg asString, '>'.
	reply := [evaluateBlock value: arg] on: Error
				do: 
					[:ex | 
					(ex isKindOf: GplPromptException) 
						ifTrue: 
							[isPrompt := true.
							ex messageText]
						ifFalse: [ex asString]].
	reply isNil ifTrue: [reply := ''].
	self debugLog: Time now printString , ': ' , '[' , reply , ']'.
	replySession setPrommptState: isPrompt.
	replySession message: reply.
	self 
		debugLog: Time now printString , ': ' , '(' , replySession message , ')'.
	replySession send: aSocket
]

{ #category : #accessing }
GdsServer >> sessionOfNumber: aNumber [
	sessionMap ifNil: [sessionMap := Dictionary new].
	^sessionMap at: aNumber ifAbsentPut: [GdsIoSession new session: aNumber].
	
]

{ #category : #accessing }
GdsServer >> showsLog [
	^evaluator showsLog
]

{ #category : #accessing }
GdsServer >> showsLog: aBoolean [
	evaluator showsLog: aBoolean
]

{ #category : #conversation }
GdsServer >> startSession: aSocket [
	| replySession |
	self clearSession.
	replySession := GdsReplySession new session: 0.
	replySession setCodeCompleteState: true.
	replySession message: 
		(self implementedMethodNames joinUsing: String cr).
	replySession send: aSocket	
]

{ #category : #conversation }
GdsServer >> suspendedGplExpressionLateResult: aResult [ 
	| context suspendToken |
	"self halt."
	evaluator pushResult: aResult.
	context := evaluator peekSuspendContext.
	suspendToken := context tempAt: 1.
	self assert: (suspendToken isMemberOf: GplToken).
	^ suspendToken parser source
]
