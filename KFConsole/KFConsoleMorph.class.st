"
consolue simuraton morph

"
Class {
	#name : #KFConsoleMorph,
	#superclass : #MorphicModel,
	#instVars : [
		'font',
		'curses',
		'readline',
		'console',
		'getUserInput',
		'redrawCount',
		'lastRedraw',
		'superDrawable',
		'overlayMorph',
		'proxyStdOut',
		'stepGlobalSelector',
		'boldFont',
		'bold'
	],
	#category : #'KFConsole-Morph'
}

{ #category : #accessing }
KFConsoleMorph class >> open [
	"self open."

	| m |
	m := KFConsoleMorph new.
	(m embeddedInMorphicWindowLabeled: 'Console')
		ifNotNil: [ :w | w openInWorld ]
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> activeFont [
	^ self bold
		ifTrue: [ self boldFont ]
		ifFalse: [ self font ]
]

{ #category : #menu }
KFConsoleMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	KFMenuSupport
		addToMenu: aCustomMenu
		actionAssociations: {('change font' -> #changeFont)}
	"aCustomMenu add: 'change font' action: #changeFont."
]

{ #category : #'as yet unclassified' }
KFConsoleMorph >> apiDrawString: aString on: aCanvas atCol: aCol atRow: aRow [
	| cursX |
	cursX := aCol.
	aString
		do: [ :ch | 
			aCanvas
				drawString: ch asString
				at: (self drawPosCol: cursX Row: aRow)
				font: self font
				color: Color black.
			cursX := cursX + 1 ]
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> bold [
	^ bold ifNil: [ bold := false ]
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> bold: aBoolean [
	bold := aBoolean
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> boldFont [
	^ boldFont ifNil: [ boldFont := self font emphasis: 1 ]
]

{ #category : #'as yet unclassified' }
KFConsoleMorph >> changeFont [
	| newFont chooser |
	chooser := FontChooser
		windowTitle: 'Choose a Font'
		for: self
		setSelector: #font:
		getSelector: #font.
	self openModal: chooser.
	newFont := chooser result.
	newFont ifNotNil: [ self font: newFont ]
]

{ #category : #accessing }
KFConsoleMorph >> console [
	^ console
]

{ #category : #accessing }
KFConsoleMorph >> consoleClass [
	^ KFConsole
]

{ #category : #accessing }
KFConsoleMorph >> curses [
	^ curses
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> drawCaretPos [
	^ self innerBounds origin + self localCaretDrawPos
]

{ #category : #drawing }
KFConsoleMorph >> drawChar: aCharacter on: aCanvas [
	aCanvas
		drawString: aCharacter asString
		at: self drawPos
		font: self activeFont
		color: self visiblePenColor.
	self curses cursColIncrement: 1
]

{ #category : #drawing }
KFConsoleMorph >> drawCursorOn: aCanvas [
	| cursBounds |
	cursBounds := self drawCaretPos extent: self fontExtent.
	aCanvas frameRectangle: cursBounds color: self visiblePenColor
]

{ #category : #drawing }
KFConsoleMorph >> drawEventSizeOn: aCanvas [
	"self curses setPosY: self curses numRows - 1 x: 0."

	self curses
		restoreCursPosDuring: [ | t |
			t := console eventFetcher size asString.
			self curses cursRow: 0.
			self curses cursCol: 20.
			self drawString: t on: aCanvas ]
]

{ #category : #drawing }
KFConsoleMorph >> drawLocationOn: aCanvas [
	"self curses setPosY: self curses numRows - 1 x: 0."

	self overlayMorph ifNil: [ ^ self ].
	self overlayMorph viewport ifNil: [ ^ self ].
	(self overlayMorph viewport worldPointFromGlobal: Sensor cursorPoint)
		ifNotNil: [ :point | 
			self curses
				restoreCursPosDuring: [ | t |
					t := String
						streamContents: [ :s | 
							s nextPutAll: 'X: '.
							s nextPutAll: (point x printShowingDecimalPlaces: 3).
							s nextPutAll: '  '.
							s nextPutAll: 'Y: '.
							s nextPutAll: (point y printShowingDecimalPlaces: 3) ].
					self curses cursRow: 0.
					self curses cursCol: (self curses numCols - t size) // 2.
					self drawString: t on: aCanvas ] ]
]

{ #category : #drawing }
KFConsoleMorph >> drawLogsOn: aCanvas [
	| r trim displayLogs |
	trim := self readline inputLog size - (self curses numRows - 1).
	displayLogs := (trim > 0
		ifTrue: [ [ self readline inputLog allButFirst: trim ]
				on: Error
				do: [ #() ] ]
		ifFalse: [ self readline inputLog ]) reverse.
	displayLogs ifEmpty: [ ^ self ].
	self curses
		restoreCursPosDuring: [ r := self curses cursRow - 1.
			displayLogs
				do: [ :log | 
					self curses setPosY: r x: 0.
					self drawString: console promptString , log on: aCanvas.
					r := r - 1 max: 0 ] ]
]

{ #category : #drawing }
KFConsoleMorph >> drawOn: aCanvas [
	redrawCount := redrawCount + 1.
	self superDrawable
		ifTrue: [ super drawOn: aCanvas ].
	self drawStdOutOn: aCanvas.
	self drawReadlineOn: aCanvas.
	self drawCursorOn: aCanvas
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> drawPos [
	^ self innerBounds origin + self localDrawPos
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> drawPosCol: aCol Row: aRow [
	^ self self innerBounds origin + self localDrawPosCol: aCol Row: aRow
]

{ #category : #drawing }
KFConsoleMorph >> drawReadlineOn: aCanvas [
	"self curses setPosY: self curses numRows - 1 x: 0."

	self curses
		restoreCursPosDuring: [ self drawString: readline stringContents on: aCanvas ]
]

{ #category : #drawing }
KFConsoleMorph >> drawRedrawCountOn: aCanvas [
	"self curses setPosY: self curses numRows - 1 x: 0."

	self curses
		restoreCursPosDuring: [ | t |
			t := redrawCount asString.
			self curses cursRow: 0.
			self curses cursCol: 1.
			self drawString: t on: aCanvas ]
]

{ #category : #drawing }
KFConsoleMorph >> drawStdOutOn: aCanvas [
	| lines enableVisibleLinesCount totalCount cutCount visibleLines row |
	lines := self proxyStdOut contents lines.
	row := 1.
	enableVisibleLinesCount := self curses numRows - row.
	totalCount := lines size.
	visibleLines := lines.
	cutCount := totalCount - enableVisibleLinesCount.
	cutCount > 0
		ifTrue: [ visibleLines := [ lines allButFirst: cutCount ]
				on: Error
				do: [ #() ] ]
		ifFalse: [ row := cutCount abs ].
	visibleLines
		do: [ :line | 
			self curses setPosY: row x: 0.
			self drawString: line on: aCanvas.
			row := row + 1 ]
]

{ #category : #drawing }
KFConsoleMorph >> drawString: aString on: aCanvas [
	aString
		do: [ :ch | 
			self curses cursCol < (self curses numCols - 1)
				ifTrue: [ self drawChar: ch on: aCanvas ] ]
]

{ #category : #drawing }
KFConsoleMorph >> drawTimeOn: aCanvas [
	"self curses setPosY: self curses numRows - 1 x: 0."

	self curses
		restoreCursPosDuring: [ | t ts |
			ts := DateAndTime now.
			t := String
				streamContents: [ :s | 
					s nextPutAll: 'TIME:  '.
					ts printHMSOn: s ].
			self curses cursRow: 0.
			self curses cursCol: self curses numCols - t size - 2.
			self drawString: t on: aCanvas ]
]

{ #category : #geometry }
KFConsoleMorph >> extent: anAspect [
	super extent: anAspect.
	self curses numCols: self innerBounds width // self fontExtent x.
	self curses numRows: self innerBounds height // self fontExtent y
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> familyName [
	"Default Family font"

	| fontList |
	fontList := FontChooser new fontListStrings.
	fontList
		ifNotEmpty: [ self familyNames
				do: [ :name | 
					(fontList includes: name)
						ifTrue: [ ^ name ] ] ].
	^ StandardFonts defaultFont familyName
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> familyNames [
	"Source Code Pro"

	^ Array
		streamContents: [ :s | 
			(Smalltalk at: #SourceCodeFonts)
				ifNotNil: [ :clazz | s nextPut: clazz fontName ].
			s nextPut: 'Nouveau IBM' ]
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> font [
	^ font
		ifNil: [ font := LogicalFont familyName: self familyName pointSize: 16 ]
]

{ #category : #accessing }
KFConsoleMorph >> font: aFont [
	font := aFont
]

{ #category : #'as yet unclassified' }
KFConsoleMorph >> fontExtent [
	^ ((self font widthOf: $W) @ self font height) rounded
]

{ #category : #initialize }
KFConsoleMorph >> initialize [
	super initialize.
	superDrawable := true.
	stepGlobalSelector := nil.
	redrawCount := 0.
	self color: Color white.
	self initializeCursorWindow.
	self initializeReadline.
	self initializeConsole.
	self initializeEvents
]

{ #category : #initialize }
KFConsoleMorph >> initializeConsole [
	console := self consoleClass new.
	self model: console.
	(console stdOut respondsTo: #stepGlobal)
		ifTrue: [ stepGlobalSelector := #stepGlobal ].
	console stdOut addDependent: self.
	self readline announcer
		when: KFInputBufferFlushed
		do: [ :ann | 
			"WorldState addDeferredUIMessage: [  "
			console puts: ann stringContents.
			self redraw.
			"]."
			"WorldState addDeferredUIMessage: ["
			console postCommandLine: ann stringContents	"]" ].
	self announcer
		when: MorphDeleted
		do: [ console eventFetcher terminateEventLoop.
			console stdOut removeDependent: self ]
]

{ #category : #initialize }
KFConsoleMorph >> initializeCursorWindow [
	curses := KFCurses new.
	curses announcer when: #attributeChanged send: #redraw to: self.
	{#rowSizeChanged . #columnSizeChanged}
		do: [ :each | 
			curses announcer
				when: each
				send: #value
				to: [ self containingWindow
						ifNotNil: [ :w | 
							w
								setLabel:
									('Console <1p> x <2p>'
										expandMacrosWith: curses numCols
										with: curses numRows) ] ] ]
]

{ #category : #initialize }
KFConsoleMorph >> initializeEvents [
	self on: #mouseEnter send: #value to: [ self takeKeyboardFocus ].
	self on: #click send: #value to: [ self takeKeyboardFocus ].
	self
		on: #keyStroke
		send: #value:
		to: [ :evt | 
			((evt keyString sameAs: '<Ctrl-r>')
				or: [ evt keyString sameAs: '<Cmd-r>' ])
				ifTrue: [ console eventFetcher restart.
					console puts: '*** WARNING *** EVENT PROCESS RESTARTED.' ] ].
	self on: #keyStroke send: #handleKeyStroke: to: readline.
	self on: #keyStroke send: #redraw to: self
]

{ #category : #initialize }
KFConsoleMorph >> initializeReadline [
	readline := KFReadline new.
	readline announcer when: #stringContents send: #redraw to: self.
	readline announcer
		when: #insertPosChanged
		send: #value
		to: [ self curses insertCol: self curses cursCol + readline insertPos ]
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> localCaretDrawPos [
	^ self curses caretPos * self fontExtent
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> localDrawPos [
	^ self curses cursPos * self fontExtent
]

{ #category : #'accessing - drawing' }
KFConsoleMorph >> localDrawPosCol: aCol Row: aRow [
	^ aCol @ aRow * self fontExtent
]

{ #category : #accessing }
KFConsoleMorph >> proxyStdOut [
	^ proxyStdOut ifNil: [ proxyStdOut := WriteStream on: String new ]
]

{ #category : #accessing }
KFConsoleMorph >> readline [
	^ readline
]

{ #category : #drawing }
KFConsoleMorph >> redraw [
	self invalidRect: self fullBounds
	"| diff |
	lastRedraw ifNil: [ lastRedraw := DateAndTime now. ].
	diff := DateAndTime now - lastRedraw.
	diff milliseconds > 10
		ifTrue: [
			self invalidRect: self fullBounds.
			redrawCount := redrawCount + 1.
			lastRedraw := DateAndTime now]."
]

{ #category : #stepping }
KFConsoleMorph >> step [
	stepGlobalSelector
		ifNotNil: [ console stdOut perform: stepGlobalSelector ]
]

{ #category : #stepping }
KFConsoleMorph >> stepTime [
	^ 500
]

{ #category : #testing }
KFConsoleMorph >> superDrawable [
	^ superDrawable
]

{ #category : #accessing }
KFConsoleMorph >> superDrawable: aBoolean [
	superDrawable := aBoolean
]

{ #category : #update }
KFConsoleMorph >> update: anAspect [
	super update: anAspect.
	anAspect == #appendEntry
		ifTrue: [ self proxyStdOut nextPutAll: console stdOut contents ]
]

{ #category : #accessing }
KFConsoleMorph >> visiblePenColor [
	^ self color luminance > 0.7
		ifTrue: [ Color black ]
		ifFalse: [ Color white ]
]

{ #category : #stepping }
KFConsoleMorph >> wantsSteps [
	^ stepGlobalSelector notNil
]
