Class {
	#name : #GdsReplySession,
	#superclass : #GdsIoSession,
	#instVars : [
		'isPrompt',
		'isCodeComplete'
	],
	#category : #'GdsFeel-CLI-Service'
}

{ #category : #'initialize-release' }
GdsReplySession >> initialize [
	super initialize.
	isPrompt := false.
	isCodeComplete := false
]

{ #category : #testing }
GdsReplySession >> isCodeComplete [
	^ isCodeComplete
]

{ #category : #testing }
GdsReplySession >> isPrompt [
	^ isPrompt
]

{ #category : #accessing }
GdsReplySession >> message [
	| stream |
	stream := WriteStream on: (String new: 4096).
	records do: [ :each | stream nextPutAll: each base64 ].
	^ (Base64MimeConverter mimeDecodeToChars: stream contents readStream)
		contents
]

{ #category : #accessing }
GdsReplySession >> message: aString [
	| base64 nSplit unit rest start end fragment reply consume |
	records := OrderedCollection new.
	base64 := (Base64MimeConverter mimeEncode: (ReadStream on: aString))
		contents.
	unit := GdsIoReply fragmentSize.
	nSplit := base64 size // unit.
	rest := base64 size \\ unit.
	consume := 1.
	1 to: nSplit do: [ :index | 
		start := (index - 1) * unit + 1.
		end := start + unit - 1.
		fragment := base64 copyFrom: start to: end.
		reply := GdsIoReply consume: index base64: fragment.
		self addRecord: reply.
		consume := consume + 1 ].
	rest > 0
		ifTrue: [ nSplit := nSplit + 1.
			reply := GdsIoReply consume: consume base64: (base64 last: rest).
			self addRecord: reply ].
	records
		ifEmpty: [ reply := GdsIoReply consume: consume base64: ''.
			self addRecord: reply ].
	self setSplitNumber: nSplit
]

{ #category : #action }
GdsReplySession >> send: aSocket [
	| data |
	self assert: [ records isEmpty not ].
	records
		do: [ :each | 
			data := each contents.
			"data explore."
			aSocket sendData: data ].
	records := nil
]

{ #category : #accessing }
GdsReplySession >> setCodeCompleteState: aBoolean [
	isCodeComplete := aBoolean
]

{ #category : #accessing }
GdsReplySession >> setPrommptState: aBoolean [
	isPrompt := aBoolean
]

{ #category : #accessing }
GdsReplySession >> setSplitNumber: nSplit [
	records
		do: [ :each | 
			each session: self session.
			self isPrompt
				ifTrue: [ each type: each typePrompt ].
			self isCodeComplete
				ifTrue: [ each type: each typeCodeComplete ].
			each nSplit: nSplit ]
]
