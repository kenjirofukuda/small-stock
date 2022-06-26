"
A KFInputBuffer is string input.
"
Class {
	#name : #KFInputBuffer,
	#superclass : #Object,
	#instVars : [
		'charWriteStream',
		'insertPos',
		'announcer'
	],
	#category : #'KFConsole-Model'
}

{ #category : #adding }
KFInputBuffer >> addChar: aCharacter [
	aCharacter = Character cr
		ifFalse: [ self charWriteStream nextPut: aCharacter.
			self insertPos: self charWriteStream position ].
	self announcer announce: #stringContents.
	aCharacter = Character cr
		ifTrue: [ "self inform: aCharacter asString." self flush ]
]

{ #category : #adding }
KFInputBuffer >> addPoint: aPoint [
	self ensureASpace.
	self addString: aPoint x asString.
	self addString: ' '.
	self addString: aPoint y asString
]

{ #category : #adding }
KFInputBuffer >> addPoints: aPointCollection [
	aPointCollection do: [ :point | self addPoint: point ]
]

{ #category : #adding }
KFInputBuffer >> addString: aString [
	aString do: [ :char | self addChar: char ]
]

{ #category : #accessing }
KFInputBuffer >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #tests }
KFInputBuffer >> appendable [
	self isEmpty
		ifTrue: [ ^ true ].
	self stringContents size = self insertPos
		ifTrue: [ ^ true ].
	^ false
]

{ #category : #action }
KFInputBuffer >> backspace [
	self backspaceEnabled
		ifFalse: [ ^ self ].
	self stringContents size = self insertPos
		ifTrue: [ self charWriteStream skip: -1.
			self insertPosIncrement: -1 ]
		ifFalse: [ | pair |
			"self halt."
			pair := self split.
			charWriteStream := nil.
			(pair at: 1)
				ifNotEmpty: [ :left | self charWriteStream nextPutAll: left allButLast ].
			(pair at: 2)
				ifNotEmpty: [ :right | self charWriteStream nextPutAll: right ].
			self insertPosIncrement: -1 ].
	self announcer announce: #stringContents
]

{ #category : #tests }
KFInputBuffer >> backspaceEnabled [
	self isEmpty
		ifTrue: [ ^ false ].
	self insertPos = 0
		ifTrue: [ ^ false ].
	^ true
]

{ #category : #accessing }
KFInputBuffer >> charWriteStream [
	^ charWriteStream ifNil: [ charWriteStream := WriteStream on: #() ]
]

{ #category : #'character writing' }
KFInputBuffer >> ensureASpace [
	self charWriteStream ensureASpace
]

{ #category : #action }
KFInputBuffer >> flush [
	| sc |
	sc := self stringContents copy.
	charWriteStream := nil.
	self insertPos: 0.
	self announcer
		announce:
			(KFInputBufferFlushed new
				stringContents: sc;
				yourself)
]

{ #category : #initialize }
KFInputBuffer >> initialize [
	super initialize.
	charWriteStream := nil.
	insertPos := 0 asValueHolder.
	insertPos
		whenChangedDo: [ self announcer announce: #insertPosChanged ]
]

{ #category : #adding }
KFInputBuffer >> insertChar: aCharacter [
	| leftAndRight |
	self appendable
		ifTrue: [ ^ self addChar: aCharacter ].
	aCharacter = Character cr
		ifTrue: [ ^ self flush ].
	leftAndRight := self split.
	self
		assert: self stringContents = ((leftAndRight at: 1) , (leftAndRight at: 2)).
	charWriteStream := nil.
	self charWriteStream
		nextPutAll: (leftAndRight at: 1);
		nextPut: aCharacter;
		nextPutAll: (leftAndRight at: 2).
	self insertPosIncrement: 1.
	self announcer announce: #stringContents
]

{ #category : #accessing }
KFInputBuffer >> insertPos [
	^ insertPos value
]

{ #category : #accessing }
KFInputBuffer >> insertPos: anInteger [
	insertPos value: ((anInteger max: 0) min: self stringContents size)
]

{ #category : #accessing }
KFInputBuffer >> insertPosIncrement: anOffset [
	self insertPos: self insertPos + anOffset
]

{ #category : #action }
KFInputBuffer >> insertPosToBegin [
	self insertPos: 0
]

{ #category : #action }
KFInputBuffer >> insertPosToEnd [
	self insertPos: self stringContents size
]

{ #category : #adding }
KFInputBuffer >> insertString: aString [
	aString do: [ :char | self insertChar: char ]
]

{ #category : #tests }
KFInputBuffer >> isEmpty [
	charWriteStream ifNil: [ ^ true ].
	^ charWriteStream isEmpty
]

{ #category : #action }
KFInputBuffer >> killFromInsertPos [
	| pair |
	pair := self split.
	charWriteStream := nil.
	self charWriteStream nextPutAll: (pair at: 1).
	self insertPosToEnd
]

{ #category : #tests }
KFInputBuffer >> puts: aString [
	self addString: aString.
	self charWriteStream ensureEndsWith: Character cr
]

{ #category : #adding }
KFInputBuffer >> replaceString: aString [
	charWriteStream := nil.
	self addString: aString
]

{ #category : #adding }
KFInputBuffer >> split [
	| left right len |
	self isEmpty
		ifTrue: [ ^ Array with: '' with: '' ].
	self insertPos = 0
		ifTrue: [ ^ Array with: '' with: self stringContents ].
	self insertPos = self stringContents size
		ifTrue: [ ^ Array with: self stringContents with: '' ].
	len := self stringContents size - self insertPos.
	left := self stringContents allButLast: len.
	right := self stringContents allButFirst: self insertPos.
	^ {left.
	right}
]

{ #category : #accessing }
KFInputBuffer >> stringContents [
	^ String
		streamContents: [ :ws | ws nextPutAll: self charWriteStream contents ]
]
