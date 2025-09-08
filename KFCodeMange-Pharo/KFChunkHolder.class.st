"
Instance Variables
	chunk:		<String>
	tokens:		<Array<ByteSymbol|ByteString>>

"
Class {
	#name : #KFChunkHolder,
	#superclass : #KFAbstractChunk,
	#instVars : [
		'chunk',
		'tokens',
		'index',
		'isMethodBody'
	],
	#category : #'KFCodeMange-Pharo'
}

{ #category : #'instance creation' }
KFChunkHolder class >> fromChunkString: aString [ 
	^ self new chunk: aString
]

{ #category : #accessing }
KFChunkHolder >> chunk [
	^ chunk
]

{ #category : #accessing }
KFChunkHolder >> chunk: aString [ 
	chunk := aString.
	tokens := chunk parseLiterals.

]

{ #category : #printing }
KFChunkHolder >> chunkStreamOn: aStream [

	| mt |
	mt := self markerType.
	mt first = 1 ifTrue: [ aStream nextPut: $! ].
	aStream nextPutAll: self terminatorMarkEscapedChunk.
	mt second = 1 ifTrue: [ aStream nextPut: $! ].
	mt second = 2 ifTrue: [ aStream nextPutAll: '! !' ].
	aStream flush
]

{ #category : #printing }
KFChunkHolder >> chunkStreamOn: aStream lineEnding: aLineEnding [

	| mt |
	mt := self markerType.
	mt first = 1 ifTrue: [ aStream nextPut: $! ].
	aStream 
		nextPutAll: 
			(self terminatorMarkEscapedChunk
				copyReplaceAll: String cr with: aLineEnding asString).
	mt second = 1 ifTrue: [ aStream nextPut: $! ].
	mt second = 2 ifTrue: [ aStream nextPutAll: '! !' ].
	aStream flush
]

{ #category : #accessing }
KFChunkHolder >> clazzName [

	(self isMethodHeader or: [ 
		 self isClassDefinition or: [ 
			 self isClassClassDefinition or: [ self isCommentStamp ] ] ]) 
		ifTrue: [ ^ tokens first asString ].
	^ ''
]

{ #category : #accessing }
KFChunkHolder >> extensionName [

	self protocolName notEmpty and: [ 
		(self protocolName beginsWith: '*') and: [ 
			^ self protocolName allButFirst ] ].
	^ ''
]

{ #category : #enumerating }
KFChunkHolder >> ifClassDefinictionDo: classAndSuperClassBlock [

	self isClassDefinition 
		ifTrue: [ 
			| clazz superclass |
			clazz := tokens third.
			superclass := tokens first.
			^ classAndSuperClassBlock cull: clazz cull: superclass ]
]

{ #category : #accessing }
KFChunkHolder >> index: anInteger [ 
	index := anInteger.
]

{ #category : #initialization }
KFChunkHolder >> initialize [
	isMethodBody := false
]

{ #category : #testing }
KFChunkHolder >> isClassClassDefinition [

	^ tokens size >= 3 and: [ 
		  tokens second = #class and: [ 
			  tokens third = #instanceVariableNames: ] ]
]

{ #category : #testing }
KFChunkHolder >> isClassDefinition [
	^ tokens size >= 3 and: [ tokens second = #'subclass:' ] 
]

{ #category : #testing }
KFChunkHolder >> isClassMethodHeader [
	^ ((tokens indexOf: #'methodsFor:') = 3) and: [ (tokens indexOf: #'class') = 2 ]
]

{ #category : #testing }
KFChunkHolder >> isCommentBody [
	^ self prev isCommentStamp  
]

{ #category : #testing }
KFChunkHolder >> isCommentLiteral [
	chunk ifNotEmpty: [ chunk first = $" and: [ chunk last = $" ] ].
	^ false
	 
]

{ #category : #testing }
KFChunkHolder >> isCommentStamp [
	^ tokens size >= 2 and: [ tokens second = #'commentStamp:' ] 
]

{ #category : #testing }
KFChunkHolder >> isEmpty [
	^ tokens isEmpty
]

{ #category : #testing }
KFChunkHolder >> isInstanceMethodHeader [
	^ (tokens indexOf: #'methodsFor:') = 2
]

{ #category : #testing }
KFChunkHolder >> isMethodBody [
	^ isMethodBody 
]

{ #category : #testing }
KFChunkHolder >> isMethodHeader [
	^ self isInstanceMethodHeader or: [ self isClassMethodHeader ]
]

{ #category : #testing }
KFChunkHolder >> isStringLiteral [
	chunk ifNotEmpty: [ chunk first = $' and: [ chunk last = $' ] ].
	^ false
	 
]

{ #category : #printing }
KFChunkHolder >> markerType [
	self isEmpty ifTrue: [ ^ Array with: 0 with: 0 ]. 
	self isCommentStamp ifTrue: [ ^ Array with: 1 with: 1 ].
	self isMethodHeader ifTrue: [ ^ Array with: 1 with: 1 ].
	self isMethodBody ifTrue: [ ^ Array with: 0 with: 2 ].
	^ Array with: 0 with: 1.
]

{ #category : #accessing }
KFChunkHolder >> next [
	index >= chunkFile chunks size ifTrue: [ ^ self class tail ].
	^ chunkFile chunks at: index + 1 
]

{ #category : #accessing }
KFChunkHolder >> prev [
	index <= 1 ifTrue: [ ^ self class head ].
	^ chunkFile chunks at: index - 1 
]

{ #category : #printing }
KFChunkHolder >> printOn: aStream [
	self isEmpty ifTrue: [ ^ aStream nextPutAll: chunk ].
	self ifClassDefinictionDo: [ :clazz :superclass |
		aStream nextPutAll: clazz asString.
		aStream nextPutAll: '('.
		aStream nextPutAll: superclass asString.
		^ aStream nextPutAll: ')'.		
		 ].
	self isCommentStamp ifTrue: [ ^ aStream nextPutAll: 'commentStunp:' ].
	self isMethodBody ifTrue: [ 
		aStream nextPutAll: self prev clazzName.
		self prev isClassMethodHeader
			ifTrue: [ 
				aStream nextPutAll: ' '.
				aStream nextPutAll: 'class' ].
				aStream nextPutAll: '>>#'.
				^ aStream nextPutAll: self selector.
		  ].
	self isMethodHeader
		ifTrue: [
			aStream nextPutAll: '{'. 
			aStream nextPutAll: self protocolName.
			^ aStream nextPutAll: '}'. 
 		].
	aStream nextPutAll: chunk.
]

{ #category : #accessing }
KFChunkHolder >> protocolName [
	| mIndex |
	mIndex := tokens indexOf: #'methodsFor:'.
	mIndex > 0 ifTrue: [ ^ tokens at: mIndex + 1 ].
	^ ''
]

{ #category : #testing }
KFChunkHolder >> rejectable [

	self clazzName ifNotEmpty: [ :clazz | 
		^ (clazz includesSubstring: 'manifest' caseSensitive: false) or: [ 
			  self extensionName notEmpty and: [ 
				   (chunkFile packageName sameAs: self extensionName) not ] ] ].
	self isMethodBody and: [ ^ self prev rejectable ].
	self isCommentBody and: [ ^ self prev rejectable ].
	^ false
]

{ #category : #accessing }
KFChunkHolder >> selector [
	self isMethodBody
		ifTrue: [  
			(tokens first asString endsWith: ':')
				ifFalse: [ ^ tokens first asString ]
				ifTrue: [
					| subTokens |
					subTokens := (chunk readStream upTo: Character cr) trimRight parseLiterals.
					^ (subTokens collect: [ :each | each asString ] thenSelect: [ :each | each endsWith: ':' ])
						joinUsing: ''
				]. 
		].
	^ ''.
]

{ #category : #initialization }
KFChunkHolder >> setMethodBody: aBoolean [
	isMethodBody := aBoolean
]

{ #category : #printing }
KFChunkHolder >> terminatorMarkEscapedChunk [

	^ (String streamContents: [ :s | 
		  | cws |
		  cws := ChunkWriteStream on: s.
		  cws nextPut: self chunk ]) allButLast.  "ignore last bang"
]
