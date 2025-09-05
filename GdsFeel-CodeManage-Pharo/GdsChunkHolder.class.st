"
Instance Variables
	chunk:		<String>
	tokens:		<Array<ByteSymbol|ByteString>>

"
Class {
	#name : #GdsChunkHolder,
	#superclass : #Object,
	#instVars : [
		'chunk',
		'tokens',
		'chunkFile',
		'index',
		'isMethodBody'
	],
	#category : #'GdsFeel-CodeManage-Pharo'
}

{ #category : #'instance creation' }
GdsChunkHolder class >> fromChunkString: aString [ 
	^ self new chunk: aString
]

{ #category : #accessing }
GdsChunkHolder >> chunk: aString [ 
	chunk := aString.
	tokens := chunk parseLiterals.

]

{ #category : #accessing }
GdsChunkHolder >> chunkFile: aGdsChunkFile [ 
	chunkFile := aGdsChunkFile.
]

{ #category : #accessing }
GdsChunkHolder >> clazzName [
	self isMethodHeader ifTrue: [ ^ tokens first asString ].
	^ ''
]

{ #category : #enumerating }
GdsChunkHolder >> ifClassDefinictionDo: classAndSuperClassBlock [

	self isClassDefinition 
		ifTrue: [ 
			| clazz superclass |
			clazz := tokens third.
			superclass := tokens first.
			^ classAndSuperClassBlock cull: clazz cull: superclass ]
]

{ #category : #accessing }
GdsChunkHolder >> index: anInteger [ 
	index := anInteger.
]

{ #category : #initialization }
GdsChunkHolder >> initialize [
	isMethodBody := false
]

{ #category : #testing }
GdsChunkHolder >> isClassDefinition [
	^ tokens size >= 3 and: [ tokens second = #'subclass:' ] 
]

{ #category : #testing }
GdsChunkHolder >> isClassMethodHeader [
	^ ((tokens indexOf: #'methodsFor:') = 3) and: [ (tokens indexOf: #'class') = 2 ]
]

{ #category : #testing }
GdsChunkHolder >> isCommentStamp [
	^ tokens size >= 2 and: [ tokens second = #'commentStamp:' ] 
]

{ #category : #testing }
GdsChunkHolder >> isEmpty [
	^ tokens isEmpty
]

{ #category : #testing }
GdsChunkHolder >> isInstanceMethodHeader [
	^ (tokens indexOf: #'methodsFor:') = 2
]

{ #category : #testing }
GdsChunkHolder >> isMethodBody [
	^ isMethodBody 
]

{ #category : #testing }
GdsChunkHolder >> isMethodHeader [
	^ self isInstanceMethodHeader or: [ self isClassMethodHeader ]
]

{ #category : #accessing }
GdsChunkHolder >> next [
	index >= chunkFile chunks size ifTrue: [ ^ nil ].
	^ chunkFile chunks at: index + 1 
]

{ #category : #accessing }
GdsChunkHolder >> prev [
	index <= 1 ifTrue: [ ^ nil ].
	^ chunkFile chunks at: index - 1 
]

{ #category : #printing }
GdsChunkHolder >> printOn: aStream [
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
GdsChunkHolder >> protocolName [
	| mIndex |
	mIndex := tokens indexOf: #'methodsFor:'.
	mIndex > 0 ifTrue: [ ^ tokens at: mIndex + 1 ].
	^ ''
]

{ #category : #accessing }
GdsChunkHolder >> selector [
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
GdsChunkHolder >> setMethodBody: aBoolean [
	isMethodBody := aBoolean
]
