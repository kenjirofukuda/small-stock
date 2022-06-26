"
A GdsCurses is curses model.

"
Class {
	#name : #KFCurses,
	#superclass : #Object,
	#instVars : [
		'numRows',
		'numCols',
		'cursRow',
		'cursCol',
		'insertCol',
		'attributeChangeCount',
		'lockChanges',
		'announcer'
	],
	#category : #'KFConsole-Model'
}

{ #category : #accessing }
KFCurses >> announcer [
	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #accessing }
KFCurses >> caretPos [
	^ self insertCol @ self cursRow
]

{ #category : #accessing }
KFCurses >> cursCol [
	^ cursCol value
]

{ #category : #accessing }
KFCurses >> cursCol: aColIndex [
	cursCol value: ((aColIndex max: 0) min: self numCols - 1)
]

{ #category : #private }
KFCurses >> cursColIncrement: anOffset [
	self cursCol: self cursCol + anOffset
]

{ #category : #action }
KFCurses >> cursDown [
	self cursRowIncrement: 1
]

{ #category : #action }
KFCurses >> cursLeft [
	self cursColIncrement: -1
]

{ #category : #accessing }
KFCurses >> cursPos [
	^ self cursCol @ self cursRow
]

{ #category : #action }
KFCurses >> cursRight [
	self cursColIncrement: 1
]

{ #category : #accessing }
KFCurses >> cursRow [
	^ cursRow value
]

{ #category : #accessing }
KFCurses >> cursRow: aRowIndex [
	cursRow value: ((aRowIndex max: 0) min: self numRows - 1)
]

{ #category : #private }
KFCurses >> cursRowIncrement: anOffset [
	self cursRow: self cursRow + anOffset
]

{ #category : #action }
KFCurses >> cursUp [
	self cursRowIncrement: -1
]

{ #category : #initialize }
KFCurses >> initialize [
	super initialize.
	lockChanges := false.
	attributeChangeCount := 0.
	numRows := 0 asValueHolder.
	numCols := 0 asValueHolder.
	cursRow := 0 asValueHolder.
	cursCol := 0 asValueHolder.
	insertCol := 0 asValueHolder.
	"promptString := '' asValueHolder ."
	{numRows.
	numCols.
	cursRow.
	cursCol.
	insertCol}
		do: [ :holder | 
			holder
				whenChangedDo: [ lockChanges
						ifTrue: [ attributeChangeCount := attributeChangeCount + 1 ]
						ifFalse: [ self announcer announce: #attributeChanged ] ] ].	"promptString ."
	numRows whenChangedDo: [ self announcer announce: #rowSizeChanged ].
	numCols
		whenChangedDo: [ self announcer announce: #columnSizeChanged ]
]

{ #category : #accessing }
KFCurses >> insertCol [
	^ insertCol value max: self insertColMin
]

{ #category : #accessing }
KFCurses >> insertCol: aColIndex [
	insertCol
		value: ((aColIndex max: self insertColMin) min: self numCols - 1)
]

{ #category : #accessing }
KFCurses >> insertColMin [
	^ self cursCol
]

{ #category : #accessing }
KFCurses >> numCols [
	^ numCols value
]

{ #category : #accessing }
KFCurses >> numCols: aColSize [
	numCols value: aColSize
]

{ #category : #accessing }
KFCurses >> numRows [
	^ numRows value
]

{ #category : #accessing }
KFCurses >> numRows: aRowSize [
	numRows value: aRowSize
]

{ #category : #utility }
KFCurses >> restoreCursPosDuring: aBlock [
	| saveRow saveCol |
	lockChanges := true.
	saveRow := self cursRow.
	saveCol := self cursCol.
	[ aBlock value ]
		ensure: [ self cursRow: saveRow.
			self cursCol: saveCol.
			attributeChangeCount > 0
				ifTrue: [ self announcer announce: #attributeChanged.
					attributeChangeCount := 0 ].
			lockChanges := false ]
]

{ #category : #'curses - api' }
KFCurses >> setPosY: aRow x: aCol [
	self cursCol: aCol.
	self cursRow: aRow
]
