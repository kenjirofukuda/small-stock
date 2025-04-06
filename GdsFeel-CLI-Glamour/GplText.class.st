Class {
	#name : #GplText,
	#superclass : #Object,
	#instVars : [
		'file',
		'errorToken',
		'errorString',
		'builder',
		'text'
	],
	#classVars : [
		'ActiveSourceFile'
	],
	#category : #'GdsFeel-CLI-Glamour'
}

{ #category : #debugging }
GplText class >> activeSourceFile [
	^ ActiveSourceFile
		ifNil: [ ActiveSourceFile := self toolFiles atRandom ]
]

{ #category : #'instance creation' }
GplText class >> applyText: aText tokens: aTokenCollection [
	| colorMap |
	aText
		addAttribute:
			(TextFontReference
				toFont: (LogicalFont familyName: 'Source Code Pro' pointSize: 10))
		from: 1
		to: aText size.
	colorMap := Dictionary new.
	self setupTokenColor: colorMap.
	aTokenCollection
		do: [ :token | 
			(token type = #label or: token type = #labelDest)
				ifTrue: [ aText
						addAttribute: TextEmphasis italic
						from: token start
						to: token end ].
			(colorMap at: token type ifAbsent: [  ])
				ifNotNil: [ :color | aText makeColor: color from: token start to: token end ] ]
]

{ #category : #resource }
GplText class >> contentsOfFileReference: aFileReference [
	"TODO: remove duplicate method GdsDeveloperDocument"

	^ aFileReference
		readStreamDo: [ :s | 
			String
				streamContents: [ :ts | 
					[ s atEnd ]
						whileFalse: [ ts nextPutAll: s nextLine asString.
							ts cr ] ] ]
]

{ #category : #debugging }
GplText class >> example [
	"self example"

	self openViewOfFile: self toolFiles atRandom
	"(PluggableButtonMorph on: GplText getState: nil action: #example) openInWorld. "
]

{ #category : #menu }
GplText class >> gdsMenuOn: aBuilder [
	<worldMenu>
	(aBuilder item: #'Gpl Syntax Check')
		action: [ self openView ];
		parent: #GdsFeel;
		yourself
]

{ #category : #resource }
GplText class >> helpFiles [
	"self helpFiles"

	^ self toolDir allFiles select: [ :f | f extension sameAs: 'HP' ]
]

{ #category : #debugging }
GplText class >> makeOpenActiveButton [
	"self makeOpenActiveButton"

	(PluggableButtonMorph
		on: GplText
		getState: nil
		action: #openActiveFile)
		label: 'Open Active';
		openCenteredInWorld
]

{ #category : #debugging }
GplText class >> makeRandomButton [
	"self makeRandomButton"

	(PluggableButtonMorph
		on: GplText
		getState: nil
		action: #setRandomFile)
		label: 'Gpl Random';
		openCenteredInWorld
]

{ #category : #debugging }
GplText class >> openActiveFile [
	"self example"

	self openViewOfFile: self activeSourceFile
]

{ #category : #'instance creation' }
GplText class >> openView [
	"self openView"

	| browser |
	browser := GLMTabulator new.
	browser title: 'GPL Syntax Check'.
	browser
		row: [ :row | 
			row column: #files.
			row column: #source span: 5 ]
		span: 8.
	browser row: #error.
	browser transmit
		to: #files;
		andShow: [ :a | 
			a list
				display: [ GplText toolFiles
						collect: [ :f | 
							GplText new
								file: f;
								yourself ] ];
				format: [ :g | g file basename ] ].
	browser transmit
		from: #files;
		to: #source;
		andShow: [ :a | 
			a text
				title: [ :g | g file basename ];
				format: [ :g | g text ] ].
	browser transmit
		from: #source port: #entity;
		to: #error;
		andShow: [ :a | a text format: [ :g | g statusString ] ].
	"from: #source port: #selectionInterval;"
	browser openOn: 1
]

{ #category : #'instance creation' }
GplText class >> openViewOfFile: aFileReference [
	"self openViewOfFile:(self toolFiles atRandom)"

	| builder browser errToken textPresentation |
	errToken := nil.
	builder := GplASTBuilder fromFile: aFileReference.
	[ builder buildTree ]
		on: Error
		do: [ :err | 
			5 timesRepeat: [ self inform: err asString ].
			errToken
				ifNotNil: [ errToken := builder currentToken.
					#cr = errToken type
						ifTrue: [ errToken := (builder
								leftTokens: errToken
								until: [ :tk | tk type = #cr ]) first ].
					builder explore ] ].
	browser := GLMTabulator new.
	browser row: #list.
	browser transmit
		to: #list;
		andShow: [ :a | 
			textPresentation := a text.
			textPresentation
				format: [ :x | 
					| text |
					text := builder inputStream contents asText.
					self applyText: text tokens: builder ranges.
					errToken
						ifNotNil: [ text makeColor: Color red from: errToken start to: errToken end ].
					text ] ].
	browser openOn: 1.
	errToken
		ifNotNil: [ (self helpFiles
				detect: [ :f | errToken fragment sameAs: f basenameWithoutExtension ]
				ifNone: [  ])
				ifNotNil: [ :f | self openWorkSpaceFromFileReference: f ] ]
]

{ #category : #resource }
GplText class >> openWorkSpaceFromFileReference: aFileReference [
	Workspace new
		contents: (self contentsOfFileReference: aFileReference);
		openLabel: aFileReference base
]

{ #category : #debugging }
GplText class >> setRandomFile [
	"self setRandomFile"

	ActiveSourceFile := self toolFiles atRandom
]

{ #category : #'instance creation' }
GplText class >> setupTokenColor: aDictionary [
	{(#unresolved -> Color orange darker).
	(#gdsiiMethod -> Color green muchDarker muchDarker).
	(#reserved -> Color blue darker).
	(#number -> Color brown).
	(#vector -> Color brown twiceDarker).
	(#comment -> Color gray).
	(#string -> Color purple)} do: [ :assoc | aDictionary add: assoc ]
]

{ #category : #resource }
GplText class >> toolDir [
	""

	^ FileLocator home / 'Nextcloud' / 'gds' / 'calma4' / 'tool'
]

{ #category : #resource }
GplText class >> toolFiles [
	""

	^ self toolDir allFiles select: [ :f | f extension sameAs: 'GS' ]
]

{ #category : #'see class side' }
GplText >> buildTree [
	errorToken := nil.
	errorString := nil.
	builder := GplASTBuilder fromFile: self file.
	[ builder buildTree ]
		on: Error
		do: [ :err | 
			"5 timesRepeat: [self inform: err asString]. "
			errorString := err asString.
			errorToken := builder currentToken.
			#cr = errorToken type
				ifTrue: [ errorToken := (builder
						leftTokens: errorToken
						until: [ :tk | tk type = #cr ]) first ] ]
]

{ #category : #accessing }
GplText >> builder [
	^ builder
]

{ #category : #accessing }
GplText >> errorString [
	^ errorString
]

{ #category : #accessing }
GplText >> errorToken [
	^ errorToken
]

{ #category : #accessing }
GplText >> file [
	^ file
]

{ #category : #accessing }
GplText >> file: aFileReference [
	file := aFileReference
]

{ #category : #accessing }
GplText >> lookupText [
	| gText |
	self buildTree.
	gText := builder inputStream contents asText.
	self class applyText: gText tokens: builder ranges.
	errorToken
		ifNotNil:
			[ gText makeColor: Color red from: errorToken start to: errorToken end ].
	gText.
	^ gText
]

{ #category : #accessing }
GplText >> statusString [
	self text.
	^ self errorString
		ifNil: [ 'Syntax OK' ]
		ifNotNil: [ self errorString ]
]

{ #category : #accessing }
GplText >> text [
	text ifNil: [ text := self lookupText ].
	^ text
]
