"
A GdsFeelMorphic class is Morphic level settings.

TODO: use Settings Framework.

"
Class {
	#name : #GdsFeelMorphic,
	#superclass : #Object,
	#classVars : [
		'LocalizeMap',
		'TypedMap'
	],
	#category : #'GdsFeel-UI-Morph'
}

{ #category : #utilities }
GdsFeelMorphic class >> actualScreenSize [

	"self actualScreenSize"

	^ self environment
		  at: #DisplayScreen
		  ifPresent: [ :clazz | clazz actualScreenSize ]
		  ifAbsent: [ self currentWorld actualScreenSize ]
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> backgroundColor [

	^ self typedMap colorFor: #backgroundColor
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> backgroundColor: aColor [

	self typedMap colorFor: #backgroundColor value: aColor
]

{ #category : #accessing }
GdsFeelMorphic class >> borderedSensorDisplay [

	^ self typedMap booleanFor: #borderedSensorDisplay default: false
]

{ #category : #accessing }
GdsFeelMorphic class >> borderedSensorDisplay: aBoolean [

	^ self typedMap booleanFor: #borderedSensorDisplay value: aBoolean
]

{ #category : #utilities }
GdsFeelMorphic class >> chooseFullFileName: labelString extensions: exts [

	| file dirPath |
	dirPath := self lastVisitDirectory.
	dirPath ifNotNil: [ 
		dirPath asFileReference exists ifFalse: [ 
			dirPath := FileSystem workingDirectory ] ].
	file := UIManager default
		        chooseExistingFileReference: 'Choose GDS database file'
		        extensions: exts
		        path: dirPath.
	file ifNil: [ ^ nil ].
	self lastVisitDirectory: file asFileReference parent fullName.
	^ file
]

{ #category : #utilities }
GdsFeelMorphic class >> chooseFullFileName: labelString patterns: patterns [

	| file dirPath |
	dirPath := self lastVisitDirectory.
	dirPath ifNotNil: [ 
		dirPath asFileReference exists ifFalse: [ 
			dirPath := FileSystem workingDirectory ] ].
	file := UIManager default
		        chooseFullFileNameMatching: patterns
		        label: labelString
		        path: dirPath.
	file ifNil: [ ^ nil ].
	self lastVisitDirectory: file asFileReference parent fullName.
	^ file
]

{ #category : #utilities }
GdsFeelMorphic class >> chooseUnit [

	| index |
	index := UIManager default
		         chooseFrom: GdsLibrary unitStrings
		         lines: #(  )
		         title: 'Choose Unit:'.
	index = 0 ifTrue: [ ^ nil ].
	^ GdsLibrary unitStrings at: index
]

{ #category : #accessing }
GdsFeelMorphic class >> clickSoundEnabled [

	^ self typedMap booleanFor: #clickSoundEnabled default: false
]

{ #category : #accessing }
GdsFeelMorphic class >> clickSoundEnabled: aBoolean [

	self typedMap booleanFor: #clickSoundEnabled value: aBoolean
]

{ #category : #accessing }
GdsFeelMorphic class >> colorRiseToolsGroup [

	^ self typedMap booleanFor: #colorRiseToolsGroup default: false
]

{ #category : #accessing }
GdsFeelMorphic class >> colorRiseToolsGroup: aBoolean [

	self typedMap booleanFor: #colorRiseToolsGroup value: aBoolean
]

{ #category : #documentation }
GdsFeelMorphic class >> contentsForOpenGui [

	^ String streamContents: [ :s | 
		  s cr.
		  s nextPutAll: 'Open GUI'.
		  s cr.
		  self class environment at: #ComposablePresenter ifPresent: [ 
			  s nextPutAll: '[World menu][GdsFeel][Tree Browser (Spec 1)].'.
			  s cr ].
		  self class environment
			  at: #SpPresenter
			  ifPresent: [ 
			  s nextPutAll: '[World menu][GdsFeel][Tree Browser (Spec 2)].' ].
		  s cr ]
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> controlCaptionFont [

	| textStyle |
	textStyle := TextStyle named: GdsFeelMorphic controlCaptionFontName.
	textStyle ifNil: [ textStyle := TextStyle default ].
	^ textStyle fontOfPointSize: GdsFeelMorphic controlCaptionFontSize
]

{ #category : #accessing }
GdsFeelMorphic class >> controlCaptionFontName [

	^ self typedMap stringFor: #controlCaptionFontName default: 'Accumon'
]

{ #category : #accessing }
GdsFeelMorphic class >> controlCaptionFontName: aString [

	^ self typedMap
		  stringFor: #controlCaptionFontName
		  value: aString asString
]

{ #category : #accessing }
GdsFeelMorphic class >> controlCaptionFontSize [

	^ self typedMap numberFor: #controlCaptionFontSize default: 9
]

{ #category : #accessing }
GdsFeelMorphic class >> controlCaptionFontSize: anInteger [

	^ self typedMap numberFor: #controlCaptionFontSize value: anInteger
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> createGdsToolsIconForm [

	"self createGdsToolsIconForm display"

	^ Form
		  extent: 16 @ 16
		  depth: 32
		  fromArray:
			  #( 4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4290559164 4284177243 4284440415 4286414205 4294835709
			     4291875024 4283256141 4284637794 4284835173 4291611852
			     4294967295 4293980400 4284637794 4285164138 4286479998
			     4292730333 4283321934 4294638330 4294967295 4288848546
			     4292335575 4291019715 4287072135 4294967295 4293980400
			     4283321934 4292335575 4288519581 4288782753 4294967295
			     4291414473 4287598479 4289374890 4294967295 4294967295
			     4294967295 4294967295 4291019715 4287072135 4294967295
			     4294967295 4290361785 4286874756 4292730333 4282400832
			     4289045925 4294769916 4287137928 4289835441 4294967295
			     4291217094 4285164138 4287730065 4291019715 4287072135
			     4294967295 4294967295 4290624957 4286085240 4294967295
			     4294375158 4288387995 4282664004 4291677645 4283979864
			     4294901502 4294967295 4291875024 4286545791 4291019715
			     4287072135 4294967295 4294638330 4283914071 4291151301
			     4293125091 4294111986 4294967295 4286282619 4294967295
			     4288453788 4283453520 4284506208 4284243036 4292796126
			     4291348680 4282137660 4284308829 4283716692 4289440683
			     4294967295 4291809231 4283387727 4284308829 4283848278
			     4294967295 4294967295 4294967295 4294769916 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294769916
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 4294967295 4294967295 4294967295 4294967295
			     4294967295 )
		  offset: 0 @ 0
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> createViewingBaseForm [

	"self createViewingBaseForm display"

	^ Form
		  extent: 16 @ 16
		  depth: 1
		  fromArray:
			  #( 16rE000000 16r31800000 16r40400000 16r40400000 16r80200000
			     16r80200000 16r80200000 16r40600000 16r40400000 16r31E00000
			     16rF700000 16r380000 16r1C0000 16rE0000 16r70000 16r30000 )
		  offset: -5 @ -5
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> debugFindElement [

	^ self typedMap booleanFor: #debugFindElement
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> debugFindElement: aBoolean [

	self typedMap booleanFor: #debugFindElement value: aBoolean
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> debugPathBoundary [

	^ self typedMap booleanFor: #debugPathBoundary
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> debugPathBoundary: aBoolean [

	self typedMap booleanFor: #debugPathBoundary value: aBoolean
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> debugStretchFeedback [

	^ self typedMap booleanFor: #debugStretchFeedback
]

{ #category : #'debug-flags' }
GdsFeelMorphic class >> debugStretchFeedback: aBoolean [

	self typedMap booleanFor: #debugStretchFeedback value: aBoolean
]

{ #category : #accessing }
GdsFeelMorphic class >> dragWithTools [

	^ self typedMap booleanFor: #dragWithTools default: false
]

{ #category : #accessing }
GdsFeelMorphic class >> dragWithTools: aBoolean [

	self typedMap booleanFor: #dragWithTools value: aBoolean
]

{ #category : #accessing }
GdsFeelMorphic class >> fittingRatio [

	^ GdsFeel fittingRatio
]

{ #category : #accessing }
GdsFeelMorphic class >> fittingRatio: aFloat [

	^ GdsFeel fittingRatio: aFloat
]

{ #category : #menu }
GdsFeelMorphic class >> gdsMenuOn: aBuilder [

	<worldMenu>
	(aBuilder item: #GdsFeel)
		order: 5.0;
		help: 'Gds Tools';
		icon: GdsFeelMorphic createGdsToolsIconForm
	"aBuilder withSeparatorAfter."
]

{ #category : #accessing }
GdsFeelMorphic class >> goodiesEnabled [

	^ self typedMap booleanFor: #goodiesEnabled default: false
]

{ #category : #accessing }
GdsFeelMorphic class >> goodiesEnabled: aBoolean [

	"self goodiesEnabled: true."

	self typedMap booleanFor: #goodiesEnabled value: aBoolean
]

{ #category : #initializing }
GdsFeelMorphic class >> initialize [

	"self initialize"

	self openReadMe
]

{ #category : #accessing }
GdsFeelMorphic class >> lastVisitDirectory [

	^ self typedMap
		  stringFor: #lastVisitDirectory
		  default:
		  (Path workingDirectory / 'GdsFeel') asFileReference fullName
]

{ #category : #accessing }
GdsFeelMorphic class >> lastVisitDirectory: aString [

	^ self typedMap
		  stringFor: #lastVisitDirectory
		  value: aString asString
]

{ #category : #localize }
GdsFeelMorphic class >> loadLocalizeEnvirons [

	| csvFile localizeMap parser converter |
	LocalizeMap := nil.
	self localizeCsvName ifEmpty: [ ^ self ].
	csvFile := GdsFeel projectDirectory / self localizeCsvName.
	csvFile isFile ifFalse: [ ^ self ].
	localizeMap := Dictionary new.
	converter := UTF8TextConverter new.
	StandardFileStream readOnlyFileNamed: csvFile fullName do: [ :s | 
		parser := CSVParser on: s.
		parser rowsDo: [ :row | 
			| convertedRow |
			convertedRow := row collect: [ :each | 
				                each convertFromWithConverter: converter ].
			self readRow: convertedRow intoMap: localizeMap ] ].
	localizeMap keys ifEmpty: [ localizeMap := nil ].
	LocalizeMap := localizeMap
]

{ #category : #localize }
GdsFeelMorphic class >> localizeCsvName [

	^ GdsFeelMorphic typedMap stringFor: #localizeCsvName
]

{ #category : #localize }
GdsFeelMorphic class >> localizeCsvName: aCsvFilename [

	self typedMap stringFor: #localizeCsvName value: aCsvFilename
]

{ #category : #localize }
GdsFeelMorphic class >> localizeMap [

	^ LocalizeMap
]

{ #category : #localize }
GdsFeelMorphic class >> localizedCaption: aKey [

	| map |
	GdsFeelMorphic localizeMap ifNil: [ ^ aKey ].
	map := GdsFeelMorphic localizeMap at: aKey ifAbsent: [ ^ aKey ].
	^ map at: #captionName ifAbsent: [ aKey ]
]

{ #category : #localize }
GdsFeelMorphic class >> localizedHelpText: aKey [

	| map |
	GdsFeelMorphic localizeMap ifNil: [ ^ '' ].
	map := GdsFeelMorphic localizeMap at: aKey ifAbsent: [ ^ '' ].
	^ map at: #toolTipText ifAbsent: [ '' ]
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> locationCaptionFont [

	| textStyle |
	textStyle := TextStyle named: self smallUIFontName.
	textStyle ifNil: [ textStyle := TextStyle default ].
	^ textStyle fontOfPointSize: (Display height <= 600
			   ifTrue: [ 9 ]
			   ifFalse: [ 12 ])
]

{ #category : #documentation }
GdsFeelMorphic class >> openReadMe [

	"self openReadMe."

	UIManager default edit: self readMeContents label: self readMeTitle
]

{ #category : #localize }
GdsFeelMorphic class >> readLine: aString intoMap: aDictionary [

	| items |
	aString ifEmpty: [ ^ self ].
	items := aString splitOn: ','.
	items size < 2 ifTrue: [ ^ self ].
	items := items collect: [ :each | each trimBoth ].
	self readRow: items intoMap: aDictionary
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeContents [

	^ self readMeMaster
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeMaster [

	^ self contentsForOpenGui
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeMasterOld1 [

	^ '
	
"Evaluate this:
-------------------"

"show debugging tool"
GdsFeelMorphic goodiesEnabled: true.

"start GUI"
GdsStationUI open.


"open this README file"

GdsFeel openReadMe.

GdsFeelMorphic openReadMe.

'
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeTitle [

	^ 'README - '
	  , ((self category asString splitOn: '-') allButLast joinUsing: '-')
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeV001 [

	^ '
Evalute this:
-------------------

GdsStationUI open.

V001
--------
fix: playSoundNamed: problem on Pharo.
 
'
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeV002 [

	^ '
Evalute this:
-------------------

GdsStationUI open.

V002
--------
add: [pathtype] to tool palete.
automatic layer color allocate.
'
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeV003 [

	^ '
Change button font example:
-----------------------------
GdsFeelMorphic controlCaptionFontSize: 18.
GdsFeelMorphic controlCaptionFontName: ''BitstreamVeraSansMono''


Evalute this:
-------------------
GdsStationUI open.


Restore original or Narrow screen:
-----------------------------
GdsFeelMorphic controlCaptionFontSize: 9.
GdsFeelMorphic controlCaptionFontName: ''Accumon''


This update clear class variables. if set goodiesEnabled:
-----------------------------
GdsFeelMorphic goodiesEnabled: true.


V003
--------
add class named: GdsFeelMorphic

and provides: 
- #controlCaptionFontSize 
- #controlCaptionFontSize: 
- #controlCaptionFontName 
- #controlCaptionFontName: 

move from GdsFeel classmethods:
- #goodiesEnabled
- #goodiesEnabled:
- #debugStretchFeedback 
- #debugStretchFeedback: 
- #debugFindElement 
- #debugFindElement: 
- #debugPathBoundary: 
- #clickSoundEnabled 
- #clickSoundEnabled: 
- #debugPathBoundary 
'
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeV004 [

	^ '
- add [REFL].
- swap reserved color map.
 Perfect white -> id, item,
 Generic white (visible pen color)-> lightGray.
- small refactoring.
'
]

{ #category : #documentation }
GdsFeelMorphic class >> readMeV005 [

	^ '	
FIX:
------
- MessageNotUndestood>>UndefindObject>>visible.
- freeze on click [DRAW PROFILE].
- Missing cross cursor.
- [ENTERTEXT] illigal color.

ADD FUTURE:
---------------------
- Sensor location Morph defalts now StringMorph wthout BorderdStringMorph.
turn to original appearance:

 GdsFeelMorphic borderedSensorDisplay: true.

- display fitting ratio control.
 defaut is 0.98.
 between 0.5 and 1.0. 

 GdsFeelMorphic fittingRatio: 0.8.

rectangular rubberband enhance:
------------------------------------------------
- reference point.
- delta size, length.
 W: ##.# H: ##.# L: ##.#
- snaped sensor point.

tool palette layout:
----------------------------
- separate ''digitizing tools''.

'
]

{ #category : #localize }
GdsFeelMorphic class >> readRow: aCollection intoMap: aDictionary [

	| map |
	aCollection size < 2 ifTrue: [ ^ self ].
	map := Dictionary new.
	map at: #gdsName put: aCollection first.
	map at: #captionName put: aCollection second.
	aCollection size >= 3 ifTrue: [ 
		map at: #toolTipText put: aCollection third ].
	aDictionary at: (map at: #gdsName) put: map
]

{ #category : #utilities }
GdsFeelMorphic class >> requestLibraryName [

	| libName ok default |
	libName := nil.
	ok := false.
	default := ''.
	[ ok ] whileFalse: [ 
		libName := UIManager default
			           request: 'Enter libraryname:'
			           initialAnswer: default.
		libName ifNil: [ ^ libName ].
		libName := libName trimBoth.
		libName := GdsCompatibility default coerceStructureName: libName.
		libName = ''
			ifTrue: [ 
				libName := nil.
				ok := true ]
			ifFalse: [ 
				(GdsLibrary existsBaseName: libName)
					ifTrue: [ default := libName ]
					ifFalse: [ ok := true ] ] ].
	^ libName
]

{ #category : #settings }
GdsFeelMorphic class >> settingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #GdsFeelUI)
		label: 'UI';
		parent: #GdsFeel;
		with: [ 
			(aBuilder setting: #goodiesEnabled)
				target: self;
				label: 'Show developer Tools';
				description: 'optional tools enabled'.
			(aBuilder setting: #debugFindElement)
				target: self;
				label: 'Inspect Find Infomation in GET''s ';
				description: 'inspect find element information by GET command'.
			(aBuilder setting: #useCustomCursor)
				target: self;
				label: 'Use custom cursor';
				description: 'Use custom cursor'.
			(aBuilder setting: #backgroundColor)
				target: self;
				default: Color black;
				label: 'Background Color' ]
]

{ #category : #accessing }
GdsFeelMorphic class >> showsFloatingTools [

	^ self typedMap booleanFor: #showsFloatingTools
]

{ #category : #accessing }
GdsFeelMorphic class >> showsFloatingTools: aBoolean [

	self typedMap booleanFor: #showsFloatingTools value: aBoolean
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> smallUIFontName [

	^ 'Accumon'
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> structureScreenClass [

	^ GdsStructureEditorMorph
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> typedMap [

	TypedMap ifNil: [ TypedMap := TypedConfigulation new ].
	^ TypedMap
]

{ #category : #'as yet unclassified' }
GdsFeelMorphic class >> useCustomCursor [

	^ self typedMap booleanFor: #useCustomCursor default: true
]

{ #category : #accessing }
GdsFeelMorphic class >> useCustomCursor: aBoolean [

	self typedMap booleanFor: #useCustomCursor value: aBoolean
]

{ #category : #accessing }
GdsFeelMorphic class >> usingStatusBar [

	^ self typedMap booleanFor: #usingStatusBar default: true
]

{ #category : #accessing }
GdsFeelMorphic class >> usingStatusBar: aBoolean [

	self typedMap booleanFor: #usingStatusBar value: aBoolean
]
