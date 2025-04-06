Class {
	#name : 'GplTokenHandler',
	#superclass : 'GdsObject',
	#instVars : [
		'stack',
		'showsLog'
	],
	#category : 'GdsFeel-CLI-Kernel',
	#package : 'GdsFeel-CLI',
	#tag : 'Kernel'
}

{ #category : 'analysis-postfix' }
GplTokenHandler >> beforeEvaluateTokens: aGplTokens [
	GplScanner assertGplTokens: aGplTokens.
	self resetStack
]

{ #category : 'private' }
GplTokenHandler >> clientPrompt [
	^ '? '
]

{ #category : 'accessing' }
GplTokenHandler >> debugLog: aObject [
	self showsLog
		ifFalse: [ ^ self ].
	Transcript
		cr;
		show: aObject
]

{ #category : 'initialize-release' }
GplTokenHandler >> initialize [
	super initialize.
	showsLog := false.
	self resetStack
]

{ #category : 'syntax check' }
GplTokenHandler >> notImplementedToken: aGplToken [
	^ self syntaxMessage: 'RESERVED BUT NOT IMPLEMENTED' token: aGplToken
]

{ #category : 'analysis-postfix' }
GplTokenHandler >> pop [
	| result |
	result := stack last.
	stack := stack allButLast.
	^ result
]

{ #category : 'analysis-postfix' }
GplTokenHandler >> push: aToken [
	stack add: aToken
]

{ #category : 'initialize-release' }
GplTokenHandler >> resetStack [
	stack := OrderedCollection new
]

{ #category : 'accessing' }
GplTokenHandler >> showsLog [
	^ showsLog
]

{ #category : 'accessing' }
GplTokenHandler >> showsLog: aBoolean [
	self assert: [ aBoolean isKindOf: Boolean ].
	showsLog := aBoolean
]

{ #category : 'syntax check' }
GplTokenHandler >> syntaxMessage: aMessage token: aGplToken [
	^ String
		streamContents: [ :s | 
			aGplToken start + self clientPrompt size - 1
				timesRepeat: [ s nextPut: Character space ].
			aGplToken fragment size timesRepeat: [ s nextPut: $^ ].
			s nextPut: Character space.
			s
				nextPutAll: aMessage , ': ';
				nextPutAll: aGplToken fragment ]
]
