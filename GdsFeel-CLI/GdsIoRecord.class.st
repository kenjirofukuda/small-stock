"
A GdsIoRecord is xxxxxxxxx.

Instance Variables
	consume:		<Integer>
	desc:		<Byte>
	fragmentSize:		<Integer>
	kind:		<Byte>
	nSplit:		<Integer>
	phase:		<Integer>
	session:		<Integer>

consume
	- xxxxx

desc
	- xxxxx

fragmentSize
	- xxxxx

kind
	- xxxxx

nSplit
	- xxxxx

phase
	- xxxxx

session
	- xxxxx

"
Class {
	#name : 'GdsIoRecord',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'desc',
		'session',
		'nSplit',
		'consume',
		'fragmentSize',
		'phase',
		'base64'
	],
	#category : 'GdsFeel-CLI-Service',
	#package : 'GdsFeel-CLI',
	#tag : 'Service'
}

{ #category : 'constants' }
GdsIoRecord class >> bufferSize [
	^ 2000
]

{ #category : 'accessing' }
GdsIoRecord class >> fragmentSize [
	^ self bufferSize - self headerSize
]

{ #category : 'instance creation' }
GdsIoRecord class >> fromByteArray: aByteArray [
	^ self new byteArray: aByteArray
]

{ #category : 'constants' }
GdsIoRecord class >> headerSize [
	^ 20
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> base64 [
	^ base64
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> base64: aString [
	base64 := aString.
	fragmentSize := aString size
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> byteArray: aByteArray [
	| stream |
	"self assert: aByteArray size = 2000."
	"AssociationFailure on cygwin byte size 1460"
	stream := aByteArray readStream.
	phase := stream next.
	kind := stream next.
	desc := stream next.
	stream next.	"padd"
	session := stream nextInt32.
	nSplit := stream nextInt32.
	consume := stream nextInt32.
	fragmentSize := stream nextInt32.
	base64 := (stream next: fragmentSize) asString
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> consume: aNumber [
	consume := aNumber
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> contentsOn: aWriteStream [
	| fillSize |
	self headerOn: aWriteStream.
	aWriteStream nextPutAll: self base64 asByteArray.
	fillSize := self class bufferSize
		- (self class headerSize + fragmentSize).
	fillSize timesRepeat: [ aWriteStream nextPut: 0 ]
]

{ #category : 'testing' }
GdsIoRecord >> hasMoreData [
	^ consume < nSplit
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> headerOn: aWriteStream [
	aWriteStream nextPut: phase.
	aWriteStream nextPut: kind.
	aWriteStream nextPut: desc.
	aWriteStream nextPut: 0.
	aWriteStream nextInt32Put: session.
	aWriteStream nextInt32Put: nSplit.
	aWriteStream nextInt32Put: consume.
	aWriteStream nextInt32Put: fragmentSize
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> initialize [
	phase := self sessionRunLoop.
	kind := self typeNormal.
	desc := 1.
	session := 1.
	nSplit := 1.
	consume := 1.
	fragmentSize := 0.
	base64 := ''
]

{ #category : 'testing' }
GdsIoRecord >> isSessionEnter [
	^ phase = self sessionEnter
]

{ #category : 'testing' }
GdsIoRecord >> isSessionExit [
	^ phase = self sessionExit
]

{ #category : 'testing' }
GdsIoRecord >> isTypeNormal [
	^ kind = self typeNormal
]

{ #category : 'testing' }
GdsIoRecord >> isTypePrompt [
	^ kind = self typePrompt
]

{ #category : 'testing' }
GdsIoRecord >> isTypePromptReply [
	^ kind = self typePromptReply
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> nSplit: aNumber [
	nSplit := aNumber
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> session [
	^ session
]

{ #category : 'as yet unclassified' }
GdsIoRecord >> session: aNumber [
	session := aNumber
]

{ #category : 'testing' }
GdsIoRecord >> sessionEnter [
	^ 1
]

{ #category : 'testing' }
GdsIoRecord >> sessionExit [
	^ 2
]

{ #category : 'testing' }
GdsIoRecord >> sessionRunLoop [
	^ 0
]

{ #category : 'testing' }
GdsIoRecord >> type: aInteger [
	({self typeNormal.
	self typePrompt.
	self typePromptReply.
	self typeCodeComplete} includes: aInteger)
		ifFalse: [ ^ self error: 'invarid argument for #type:' ].
	kind := aInteger
]

{ #category : 'testing' }
GdsIoRecord >> typeCodeComplete [
	^ 3
]

{ #category : 'testing' }
GdsIoRecord >> typeNormal [
	^ 0
]

{ #category : 'testing' }
GdsIoRecord >> typePrompt [
	^ 1
]

{ #category : 'testing' }
GdsIoRecord >> typePromptReply [
	^ 2
]
