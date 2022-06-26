"
A KFSmalltalkBrowser class 


"
Class {
	#name : #KFSmalltalkBrowser,
	#superclass : #WAComponent,
	#instVars : [
		'findString',
		'action',
		'classView',
		'methodListView',
		'fixedPositionOfHeader',
		'showsSideMenu',
		'packageListView',
		'classListView',
		'topTitle'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #testing }
KFSmalltalkBrowser class >> canBeRoot [
	^ true
]

{ #category : #'class initialization' }
KFSmalltalkBrowser class >> initialize [
	"self initialize."

	| application |
	application := WAAdmin
		register: self
		asApplicationAt: 'kf/smalltalk_browser'.
	application addLibrary: KFBrowserFileLibrary
]

{ #category : #accessing }
KFSmalltalkBrowser >> action [
	^ action
]

{ #category : #accessing }
KFSmalltalkBrowser >> action: aSymbol [
	action := aSymbol.
	self showsSideMenu: false
]

{ #category : #hooks }
KFSmalltalkBrowser >> children [
	^ Array
		streamContents: [ :s | 
			action = #classList
				ifTrue: [ s nextPut: classListView ].
			action = #methodList
				ifTrue: [ s nextPut: methodListView ].
			action = #class
				ifTrue: [ s nextPut: classView ].
			self showsSideMenu
				ifTrue: [ s nextPut: packageListView ] ]
]

{ #category : #actions }
KFSmalltalkBrowser >> classRefs: aClass [
	| methodDefs |
	methodDefs := aClass allCallsOn asArray.
	methodListView
		compiledMethods: (methodDefs collect: [ :md | md compiledMethod ]).
	self action: #methodList
]

{ #category : #actions }
KFSmalltalkBrowser >> classesOf: aPackageSymbol [
	| rPackage |
	rPackage := RPackageOrganizer default packageNamed: aPackageSymbol.
	classListView classes: rPackage orderedClasses.
	self action: #classList
]

{ #category : #styles }
KFSmalltalkBrowser >> cssMultiPlatformBlock: aBlock on: aStream [
	| base moz webkit |
	base := aBlock value.
	moz := '-moz-' , base.
	webkit := '-webkit-' , base.
	{base.
	moz.
	webkit}
		do: [ :each | 
			aStream nextPutAll: each.
			aStream ensureEndsWith: $;.
			aStream ensureCr ]
]

{ #category : #styles }
KFSmalltalkBrowser >> cssTransformX: xValue on: aStream [
	self
		cssMultiPlatformBlock: [ 'transform: translateX(<1p>px)' expandMacrosWith: xValue ]
		on: aStream
]

{ #category : #accessing }
KFSmalltalkBrowser >> findString [
	^ findString value
]

{ #category : #accessing }
KFSmalltalkBrowser >> findString: aString [
	findString value: aString
]

{ #category : #private }
KFSmalltalkBrowser >> findUpdate: aNewValue [
	| mds |
	aNewValue ifEmpty: [ ^ self ].
	aNewValue first isUppercase
		ifTrue: [ | clazz globalSymbol |
			globalSymbol := aNewValue asSymbol.
			clazz := Smalltalk at: globalSymbol ifAbsent: [  ].
			clazz
				ifNil: [ self action: #classFind.
					^ self ].
			(Smalltalk hasClassNamed: globalSymbol)
				ifTrue: [ clazz := Smalltalk at: globalSymbol ]
				ifFalse: [ clazz := (Smalltalk at: globalSymbol) class ].
			classView modelClass: clazz.
			self action: #class.
			^ self ].
	mds := SystemNavigation default allImplementorsOf: aNewValue asSymbol.
	mds ifEmpty: [ ^ self ].
	methodListView
		compiledMethods: (mds collect: [ :md | md compiledMethod ]).
	self action: #methodList
]

{ #category : #testing }
KFSmalltalkBrowser >> fixedPositionOfHeader [
	^ fixedPositionOfHeader
]

{ #category : #accessing }
KFSmalltalkBrowser >> fixedPositionOfHeader: aBoolean [
	fixedPositionOfHeader := aBoolean
]

{ #category : #accessing }
KFSmalltalkBrowser >> headerHeight [
	^ 44
]

{ #category : #actions }
KFSmalltalkBrowser >> implementersOf: aCompiledMethod [
	methodListView
		compiledMethods:
			((SystemNavigation default allImplementorsOf: aCompiledMethod selector)
				collect: [ :md | md compiledMethod ]).
	self action: #methodList
]

{ #category : #initialize }
KFSmalltalkBrowser >> initialize [
	super initialize.
	fixedPositionOfHeader := true.
	showsSideMenu := false.
	findString := '' asValueHolder.
	findString whenChangedDo: [ :newValue | self findUpdate: newValue ].
	action := #class.
	classView := KFClassBrowserComponent new.
	classView browser: self.
	classView modelClass: self class.
	methodListView := KFMethodViewListComponent new.
	methodListView browser: self.
	packageListView := KFPackageListComponent new.
	packageListView browser: self.
	classListView := KFClassListComponent new.
	classListView browser: self
]

{ #category : #styles }
KFSmalltalkBrowser >> printContainerOn: aStream [
	aStream nextPutAll: 'div#top {'.
	aStream cr.
	self fixedPositionOfHeader
		ifTrue: [ aStream
				nextPutAll: ('padding-top: <1p>px;' expandMacrosWith: self headerHeight) ].
	true
		ifTrue: [ self cssTransformX: 0 on: aStream.
			self
				cssMultiPlatformBlock: [ 'transition: ease 0.5s;' ]
				on: aStream.
			aStream nextPutAll: 'position: relative;'.
			aStream cr.
			aStream nextPutAll: 'left: 0px;'.
			aStream cr ].
	self showsSideMenu
		ifTrue: [ aStream nextPutAll: 'opacity: 0.5;'.
			aStream cr.
			aStream nextPutAll: 'overflow-x: hidden;'.
			aStream cr.
			aStream nextPutAll: 'overflow-y: hidden;'.
			aStream cr.
			self cssTransformX: self sideMenuWidth on: aStream ].
	aStream nextPutAll: '}'.
	aStream cr
]

{ #category : #styles }
KFSmalltalkBrowser >> printSideMenuOn: aStream [
	aStream nextPutAll: 'div#sidemenu {'.
	aStream cr.
	aStream
		nextPutAll: ('width: <1p>px;' expandMacrosWith: self sideMenuWidth).
	aStream cr.
	aStream nextPutAll: 'height: 100%;'.
	aStream cr.
	self
		cssTransformX:
			(self showsSideMenu
				ifTrue: [ 0 ]
				ifFalse: [ self sideMenuWidth negated ])
		on: aStream.
	true
		ifTrue:
			[ self cssMultiPlatformBlock: [ 'transition: ease 0.5s;' ] on: aStream.
			aStream nextPutAll: 'position: absolute;'.
			aStream cr.
			aStream nextPutAll: 'position: fixed;'.
			aStream cr.
			aStream nextPutAll: 'top: 0px;'.
			aStream cr.
			aStream nextPutAll: 'left: 0px;'.
			aStream cr.
			aStream nextPutAll: 'z-index: 5;'.
			aStream cr ].
	self showsSideMenu
		ifTrue: [ aStream nextPutAll: 'overflow-x: hidden;'.
			aStream cr.
			aStream nextPutAll: 'overflow-y: scroll;'.
			aStream cr.
			self
				cssMultiPlatformBlock: [ 'overflow-scrolling: touch' ]
				on: aStream ].
	aStream nextPutAll: '}'.
	aStream cr
]

{ #category : #rendering }
KFSmalltalkBrowser >> renderClassListOn: html [
	html
		unorderedList: [ ((Smalltalk allClasses collect: [ :sym | sym asString ])
				select: [ :classString | classString includesSubstring: self findString ])
				do: [ :cs | 
					html listItem
						class: 'wideMarginList';
						with: [ html anchor
								callback: [ self findString: cs ];
								with: cs ] ] ]
]

{ #category : #rendering }
KFSmalltalkBrowser >> renderContentOn: html [
	self renderFinderOn: html.
	html div
		class: 'content';
		id: 'top';
		with: [ action = #class
				ifTrue: [ html render: classView ].
			action = #methodList
				ifTrue: [ html render: methodListView ].
			action = #classList
				ifTrue: [ html render: classListView ].
			action = #classFind
				ifTrue: [ self renderClassListOn: html ] ].
	self showsSideMenu
		ifTrue: [ self renderSideMenuOn: html ]
]

{ #category : #rendering }
KFSmalltalkBrowser >> renderFinderOn: html [
	html div
		id: 'header';
		with: [ html anchor
				class: 'lightText';
				class: 'noUnderline';
				class: 'menuIcon';
				callback: [ self toggleSideMenu ];
				with: [ self renderMenuIconOn: html ].
			"html anchor class: 'lightText';
				callback: [ self toggleFixedHeader ]; with: '[P]'."
			html div
				class: 'topTitle';
				with: self topTitle.
			html form
				class: 'findForm';
				with: [ html textInput
						id: #findString;
						size: 20;
						on: #findString of: self.
					html submitButton ] ]
]

{ #category : #rendering }
KFSmalltalkBrowser >> renderMenuIconOn: html [
	html image url: KFBrowserFileLibrary / #menuIconPng
	"html render: (Character value: 16r2630) asString."
]

{ #category : #rendering }
KFSmalltalkBrowser >> renderSideMenuOn: html [
	html div
		id: 'sidemenu';
		with: [ html render: packageListView ]
]

{ #category : #actions }
KFSmalltalkBrowser >> sendersOf: aCompiledMethod [
	methodListView
		compiledMethods:
			((SystemNavigation default allSendersOf: aCompiledMethod selector)
				collect: [ :md | md compiledMethod ]).
	self action: #methodList
]

{ #category : #accessing }
KFSmalltalkBrowser >> showsSideMenu [
	^ showsSideMenu
]

{ #category : #accessing }
KFSmalltalkBrowser >> showsSideMenu: aBoolean [
	showsSideMenu := aBoolean
]

{ #category : #accessing }
KFSmalltalkBrowser >> sideMenuWidth [
	^ 226
]

{ #category : #styles }
KFSmalltalkBrowser >> style [
	^ self styleForStatic , self styleForHeader
		, self styleForPackageList
		,
			'html { 
	margin: 0px;
	word-wrap: break-word;
'
		,
			(self showsSideMenu
				ifTrue: [ 'height: 100%; overflow: hidden; ' ]
				ifFalse: [ '' ])
		,
			'		 
}
' , (String streamContents: [ :s | self printContainerOn: s ])
		, (String streamContents: [ :s | self printSideMenuOn: s ])
]

{ #category : #styles }
KFSmalltalkBrowser >> styleForHeader [
	| leftValue |
	leftValue := self showsSideMenu
		ifTrue: [ self sideMenuWidth ]
		ifFalse: [ 0 ].
	^ String
		streamContents: [ :s | 
			s nextPutAll: '#header'.
			s space.
			s nextPut: ${.
			s cr.
			s nextPutAll: 'color: white;'.
			s cr.
			s nextPutAll: 'background-color: #2e51a2;'.
			s cr.
			s nextPutAll: 'width: 100%;'.
			s cr.
			s
				nextPutAll: ('height: <1p>px;' expandMacrosWith: self headerHeight).
			s cr.
			self cssTransformX: leftValue on: s.
			self cssMultiPlatformBlock: [ 'transition: ease 0.5s;' ] on: s.
			s nextPutAll: 'z-index: 9999;'.
			s cr.
			self fixedPositionOfHeader
				ifTrue: [ s nextPutAll: 'position: absolute;'.
					s cr.
					s nextPutAll: 'position: fixed; !Important'.
					s cr.
					s nextPutAll: 'top: 0;'.
					s cr ].
			s nextPut: $}.
			s cr ]
]

{ #category : #styles }
KFSmalltalkBrowser >> styleForPackageList [
	^ '
	
ul.expand {
	padding-left: 0; 
}	
	
.package { 
	list-style: none;
	padding-left: 0px;
	
}
'
]

{ #category : #styles }
KFSmalltalkBrowser >> styleForStatic [
	^ '
body { 
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
}

.findForm { 
	display: inline-block;
	float: right;
}

.menuIcon { 
	font-size: 2em;	
	width: 5%;
}

.topTitle { 
	margin: 0 auto;
	text-align: center;
	display: inline;
	font-size: 2em;	
	width: 40%;
	top: 0px;
	left: 5%;
	right: 40%;
	bottom: 0px;
	position: absolute;
	overflow: hidden;
}

.noUnderline { 
	text-decoration: none;
	text-decoration-line: none;
}

.selectorSpec { 
	font-family: monospace;
	font-weight: bold;
	font-size: 1.2em;
}

.centerText { 
	margin: 0 auto;
	width: 80%;
}

.textButton { 
	font-family: monospace;
	font-size: 12pt;
}

.lightText {
	color: white; 
}

.wideMarginList { 
	padding-top: 0.1em;
	padding-bottom: 0.1em;
}



'
]

{ #category : #actions }
KFSmalltalkBrowser >> toggleFixedHeader [
	self fixedPositionOfHeader: self fixedPositionOfHeader not
]

{ #category : #actions }
KFSmalltalkBrowser >> toggleSideMenu [
	self showsSideMenu: self showsSideMenu not
]

{ #category : #accessing }
KFSmalltalkBrowser >> topTitle [
	^ topTitle
]

{ #category : #accessing }
KFSmalltalkBrowser >> topTitle: aString [
	topTitle := aString
]
