Class {
	#name : #KFClassBrowserComponent,
	#superclass : #KFBrowserComponent,
	#instVars : [
		'modelClass',
		'methodMap',
		'definitionView',
		'methodListViewMap',
		'classDefinitionView',
		'classMethodMap',
		'classMethodListViewMap'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #private }
KFClassBrowserComponent >> categories: aClass do: aCategorySymbolBlock [
	| org localSels |
	localSels := aClass localSelectors.
	org := aClass organization.
	aClass organization categories
		do: [ :category | 
			| virtualSels |
			virtualSels := org listAtCategoryNamed: category asString.
			(virtualSels includesAny: localSels)
				ifTrue: [ aCategorySymbolBlock
						cull: category
						cull: virtualSels
						cull: localSels ] ]
]

{ #category : #hooks }
KFClassBrowserComponent >> children [
	^ Array
		streamContents: [ :s | 
			s nextPutAll: self methodListViewMap values.
			s nextPut: self definitionView.
			s nextPutAll: self classMethodListViewMap values.
			s nextPut: self classDefinitionView ]
]

{ #category : #accessing }
KFClassBrowserComponent >> classDefinitionView [
	^ classDefinitionView
		ifNil:
			[ classDefinitionView := self createViewOfClass: self modelClass class ]
]

{ #category : #accessing }
KFClassBrowserComponent >> classMethodListViewMap [
	^ classMethodListViewMap
		ifNil: [ classMethodListViewMap := self
				lookupMethodListViewMap: self classMethodMap
				ofClass: self modelClass class ]
]

{ #category : #accessing }
KFClassBrowserComponent >> classMethodMap [
	^ classMethodMap
		ifNil: [ classMethodMap := self lookupClassMethodMap ]
]

{ #category : #private }
KFClassBrowserComponent >> clearCache [
	definitionView := nil.
	methodMap := nil.
	methodListViewMap := nil.
	classDefinitionView := nil.
	classMethodMap := nil.
	classMethodListViewMap := nil
]

{ #category : #accessing }
KFClassBrowserComponent >> createViewOfClass: aClass [
	^ KFWorkspaceComponent new
		browser: self browser;
		masterSourceCode: aClass definition;
		yourself
]

{ #category : #accessing }
KFClassBrowserComponent >> definitionView [
	^ definitionView
		ifNil: [ definitionView := self createViewOfClass: self modelClass ]
]

{ #category : #accessing }
KFClassBrowserComponent >> entryClass [
	Smalltalk
		at: self findString asSymbol
		ifPresent: [ :clazz | ^ clazz ].
	^ self class
]

{ #category : #private }
KFClassBrowserComponent >> lookupClassMethodMap [
	^ self lookupMethodMapOfClass: self modelClass class
]

{ #category : #private }
KFClassBrowserComponent >> lookupMethodListViewMap: aMethodMap [
	| viewMap |
	viewMap := Dictionary new.
	aMethodMap
		keysAndValuesDo: [ :category :selectors | 
			viewMap at: category put: KFMethodViewListComponent new.
			(viewMap at: category)
				browser: self browser;
				compiledMethods: (selectors collect: [ :sel | self modelClass >> sel ]);
				showsSelector: false;
				yourself ].
	^ viewMap
]

{ #category : #private }
KFClassBrowserComponent >> lookupMethodListViewMap: aMethodMap ofClass: aClass [
	| viewMap |
	viewMap := Dictionary new.
	aMethodMap
		keysAndValuesDo: [ :category :selectors | 
			viewMap at: category put: KFMethodViewListComponent new.
			(viewMap at: category)
				browser: self browser;
				compiledMethods: (selectors asArray sort collect: [ :sel | aClass >> sel ]);
				showsSelector: false;
				yourself ].
	^ viewMap
]

{ #category : #private }
KFClassBrowserComponent >> lookupMethodMap [
	^ self lookupMethodMapOfClass: self modelClass
]

{ #category : #private }
KFClassBrowserComponent >> lookupMethodMapOfClass: aClass [
	| map |
	map := Dictionary new.
	self
		categories: aClass
		do: [ :category :virtualSels :localSels | 
			virtualSels
				do: [ :vSel | 
					(localSels includes: vSel)
						ifTrue: [ map at: category ifAbsentPut: [ OrderedCollection new ].
							(map at: category) add: vSel ] ] ].
	map keysAndValuesRemove: [ :category :methods | methods isEmpty ].
	^ map
]

{ #category : #accessing }
KFClassBrowserComponent >> methodListViewMap [
	^ methodListViewMap
		ifNil: [ methodListViewMap := self
				lookupMethodListViewMap: self methodMap
				ofClass: self modelClass ]
]

{ #category : #accessing }
KFClassBrowserComponent >> methodMap [
	^ methodMap ifNil: [ methodMap := self lookupMethodMap ]
]

{ #category : #accessing }
KFClassBrowserComponent >> modelClass [
	^ modelClass ifNil: [ modelClass := self entryClass ]
]

{ #category : #accessing }
KFClassBrowserComponent >> modelClass: anObject [
	modelClass := anObject.
	self browser ifNotNil: [ :b | b topTitle: anObject name ].
	self clearCache
]

{ #category : #rendering }
KFClassBrowserComponent >> renderClass: aClass on: html [
	html heading: aClass name.
	self renderComment: aClass on: html.
	html horizontalRule.
	html div
		class: 'centerText';
		with: [ html render: self definitionView ].
	self renderToolsOfClass: aClass on: html.
	html horizontalRule.
	self renderMethods: self methodListViewMap on: html.
	html horizontalRule.
	html div
		class: 'centerText';
		with: [ html render: self classDefinitionView ].
	self renderMethods: self classMethodListViewMap on: html
]

{ #category : #rendering }
KFClassBrowserComponent >> renderComment: aClass on: html [
	html div
		class: 'classComment';
		with: [ aClass comment lines
				do: [ :line | 
					(Character tab split: line)
						do: [ :nonTab | html render: nonTab ]
						separatedBy: [ 2 timesRepeat: [ html space ] ] ]
				separatedBy: [ html break ] ]
]

{ #category : #rendering }
KFClassBrowserComponent >> renderContentOn: html [
	self renderClass: self modelClass on: html
]

{ #category : #rendering }
KFClassBrowserComponent >> renderMethods: aMethodMap on: html [
	html horizontalRule.
	aMethodMap keys sort
		do: [ :category | 
			| view |
			view := aMethodMap at: category.
			html heading
				level: 2;
				class: 'protocolHeader';
				with: category asString.
			html render: view ]
		separatedBy: [ html horizontalRule ]
]

{ #category : #rendering }
KFClassBrowserComponent >> renderToolsOfClass: aClass on: html [
	html div
		with: [ html anchor
				class: 'textButton';
				callback: [ self browser
						classesOf: (RPackageOrganizer default packageOf: aClass) name ];
				with: '[package]'.
			html anchor
				class: 'textButton';
				callback: [ self browser classRefs: aClass ];
				with: '[refs]' ]
]

{ #category : #style }
KFClassBrowserComponent >> style [
	^ '
.protocolHeader { 
	font-size: 1.1em;
	-webkit-margin-before: 0.2em;
	-webkit-margin-after: 0.2em;
}

.classComment { 
	width: 800px;
	margin: 0 auto;
}

'
]
