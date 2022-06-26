"
A GdsReadline is Readline model.

"
Class {
	#name : #KFReadline,
	#superclass : #Object,
	#instVars : [
		'inputBuffer',
		'historyIndex',
		'inputLog',
		'announcer'
	],
	#category : #'KFConsole-Model'
}

{ #category : #accessing }
KFReadline >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #'event handling' }
KFReadline >> handleKeyStroke: anEvent [
	(anEvent keyString sameAs: '<Ctrl-a>')
		ifTrue: [ ^ inputBuffer insertPosToBegin ].
	(anEvent keyString sameAs: '<Ctrl-e>')
		ifTrue: [ ^ inputBuffer insertPosToEnd ].
	(anEvent keyString sameAs: '<Ctrl-k>')
		ifTrue: [ ^ inputBuffer killFromInsertPos ].
	anEvent keyCharacter = Character backspace
		ifTrue: [ inputBuffer backspace.
			^ self	"insertPosIncrement: -1." ].
	anEvent keyCharacter = Character arrowUp
		ifTrue: [ ^ self historyUp ].
	anEvent keyCharacter = Character arrowDown
		ifTrue: [ ^ self historyDown ].
	anEvent keyCharacter = Character arrowLeft
		ifTrue: [ ^ self insertPosLeft ].
	anEvent keyCharacter = Character arrowRight
		ifTrue: [ ^ self insertPosRight ].
	inputBuffer insertChar: anEvent keyCharacter.
	anEvent keyCharacter = Character cr
		ifFalse: [ "self insertPosIncrement: 1" ].
	self announcer announce: #attributeChanged
]

{ #category : #'special key handler' }
KFReadline >> historyDown [
	self historyIndexIncrement: 1
]

{ #category : #'special key handler' }
KFReadline >> historyIndexIncrement: anOffset [
	| validLogs backInput |
	inputLog value ifEmpty: [ ^ self ].
	historyIndex := historyIndex + anOffset.
	validLogs := self validLogs.
	historyIndex := (historyIndex max: 0) min: validLogs size.
	historyIndex = 0
		ifTrue: [ ^ self ].
	backInput := validLogs at: historyIndex.
	inputBuffer replaceString: backInput
]

{ #category : #'special key handler' }
KFReadline >> historyUp [
	self historyIndexIncrement: -1
]

{ #category : #initialize }
KFReadline >> initialize [
	super initialize.
	inputBuffer := KFInputBuffer new.
	historyIndex := 0.
	inputLog := OrderedCollection new asValueHolder.
	inputBuffer announcer
		when: KFInputBufferFlushed
		send: #value:
		to: [ :ann | 
			inputLog add: ann stringContents.
			historyIndex := self validLogs size max: 1.
			self announcer announce: ann ].
	inputBuffer announcer
		when: #stringContents
		do: [ self announcer announce: #stringContents ].
	inputBuffer announcer
		when: #insertPosChanged
		do: [ self announcer announce: #insertPosChanged ]
]

{ #category : #accessing }
KFReadline >> inputLog [
	^ inputLog value
]

{ #category : #accessing }
KFReadline >> insertPos [
	^ inputBuffer insertPos
]

{ #category : #'special key handler' }
KFReadline >> insertPosLeft [
	inputBuffer insertPosIncrement: -1
]

{ #category : #'special key handler' }
KFReadline >> insertPosRight [
	inputBuffer insertPosIncrement: 1
]

{ #category : #accessing }
KFReadline >> stringContents [
	^ inputBuffer stringContents
]

{ #category : #'special key handler' }
KFReadline >> validLogs [
	| validLogs |
	validLogs := OrderedCollection new.
	validLogs := validLogs
		addAll: (self inputLog select: [ :log | log trim notEmpty ]).
	validLogs add: inputBuffer stringContents.
	^ validLogs
]
