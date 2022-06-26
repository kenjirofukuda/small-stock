Class {
	#name : #KFWorkspaceComponent,
	#superclass : #KFBrowserComponent,
	#instVars : [
		'classOrMetaClass',
		'masterSourceCode',
		'displaySourceCode'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #accessing }
KFWorkspaceComponent >> classOrMetaClass [
	^ classOrMetaClass
]

{ #category : #accessing }
KFWorkspaceComponent >> classOrMetaClass: anObject [
	classOrMetaClass := anObject
]

{ #category : #styles }
KFWorkspaceComponent >> cssClassOfRange: aSHRange [
	(SHPreferences classVarNamed: 'Groups')
		keysAndValuesDo: [ :tokensCategory :shoutStylelement | 
			(shoutStylelement tokens includes: aSHRange type)
				ifTrue: [ ^ tokensCategory ] ].
	^ #default
]

{ #category : #styles }
KFWorkspaceComponent >> cssStyle: aGroupSymbol ofStyleElement: aSHStyleElement on: aStream [
	| words |
	aStream nextPut: $..
	aStream nextPutAll: aGroupSymbol asString.
	aStream nextPut: ${.
	aStream cr.
	aSHStyleElement color
		ifNotNil: [ :color | 
			aStream nextPutAll: 'color: '.
			aStream nextPutAll: color asHTMLColor.
			aStream nextPut: $;.
			aStream cr ].
	words := ' ' split: aSHStyleElement emphasis.
	(words includes: 'bold')
		ifTrue: [ aStream nextPutAll: 'font-weight: bold'.
			aStream nextPut: $;.
			aStream cr ].
	(words includes: 'italic')
		ifTrue: [ aStream nextPutAll: 'font-style: bold'.
			aStream nextPut: $;.
			aStream cr ].
	aStream nextPut: $}.
	aStream cr
]

{ #category : #accessing }
KFWorkspaceComponent >> displaySourceCode [
	^ displaySourceCode
		ifNil: [ displaySourceCode := self masterSourceCode tabWidth2 ]
]

{ #category : #accessing }
KFWorkspaceComponent >> fillShoutRanges [
	| shoutRanges newRanges |
	shoutRanges := self lookupShoutRanges
		reject: [ :r | r length = 1 and: [ r type = #symbol ] ].
	shoutRanges ifEmpty: [ ^ #() ].
	shoutRanges size = 1
		ifTrue: [ ^ shoutRanges ].
	newRanges := OrderedCollection new.
	1 to: shoutRanges size - 1 do: [ :i | 
		| r1 r2 fillStart fillEnd fillLen |
		r1 := shoutRanges at: i.
		r2 := shoutRanges at: i + 1.
		newRanges add: r1.
		fillStart := r1 end + 1.
		fillEnd := r2 start - 1.
		fillLen := fillEnd - fillStart + 1.
		fillLen >= 1
			ifTrue: [ | indexes pushBlock |
				indexes := OrderedCollection new.
				pushBlock := [ indexes
					ifNotEmpty: [ newRanges
							add: (SHRange start: indexes first end: indexes last type: #blank).
						indexes := OrderedCollection new ] ].
				fillStart to: fillEnd do: [ :fi | 
					| c |
					c := self displaySourceCode at: fi.
					Character cr = c
						ifTrue: [ pushBlock value.
							newRanges add: (SHRange start: fi end: fi type: #cr) ]
						ifFalse: [ indexes add: fi ] ].
				pushBlock value ] ].
	newRanges add: shoutRanges last.
	^ newRanges asArray
]

{ #category : #private }
KFWorkspaceComponent >> lookupShoutRanges [
	^ SHParserST80 new
		rangesIn: self displaySourceCode
		classOrMetaClass: self classOrMetaClass
		workspace: nil
		environment: nil
]

{ #category : #accessing }
KFWorkspaceComponent >> masterSourceCode [
	^ masterSourceCode
]

{ #category : #accessing }
KFWorkspaceComponent >> masterSourceCode: anObject [
	masterSourceCode := anObject
]

{ #category : #styles }
KFWorkspaceComponent >> printCSSOn: aStream [
	(SHPreferences classVarNamed: 'Groups')
		keysAndValuesDo: [ :tokensCategory :shoutStylelement | 
			self
				cssStyle: tokensCategory
				ofStyleElement: shoutStylelement
				on: aStream ]
]

{ #category : #rendering }
KFWorkspaceComponent >> renderContentByShoutOn: html [
	html div
		class: 'methodContainer';
		with: [ self fillShoutRanges
				do: [ :range | self renderRange: range on: html ] ]
]

{ #category : #rendering }
KFWorkspaceComponent >> renderContentOn: html [
	self renderContentByShoutOn: html.
	self renderReturnToTopOn: html
]

{ #category : #rendering }
KFWorkspaceComponent >> renderRange: aSHRange on: html [
	| fragment |
	#cr = aSHRange type
		ifTrue: [ ^ html break ].
	fragment := self displaySourceCode
		copyFrom: aSHRange start
		to: aSHRange end.
	#blank = aSHRange type
		ifTrue: [ ^ fragment size timesRepeat: [ html space ] ].
	#ansiAssignment = aSHRange type
		ifTrue: [ fragment := (Character value: 16r2190) asString ].
	#return = aSHRange type
		ifTrue: [ fragment := (Character value: 16r2191) asString ].
	html span
		class: aSHRange type;
		class: (self cssClassOfRange: aSHRange);
		with: [ #globalVar = aSHRange type
				ifTrue: [ html anchor
						callback: [ self browser findString: fragment ];
						with: fragment ]
				ifFalse: [ fragment lines
						do: [ :line | html render: line ]
						separatedBy: [ html break ] ] ]
]

{ #category : #rendering }
KFWorkspaceComponent >> renderReturnToTopOn: html [
	html div
		class: 'returnToTop';
		with: [ html anchor
				class: 'textButton';
				url: '#top';
				with: '[top]'.
			self renderToolSpace: 4 on: html ]
]

{ #category : #rendering }
KFWorkspaceComponent >> renderToolSpace: nSpace on: html [
	html span
		class: 'textButton';
		with: [ nSpace timesRepeat: [ html space ] ]
]

{ #category : #rendering }
KFWorkspaceComponent >> renderToolSpaceOn: html [
	self renderToolSpace: 3 on: html
]

{ #category : #styles }
KFWorkspaceComponent >> style [
	^ self styleForMethodLayout , self styleForSyntax
]

{ #category : #styles }
KFWorkspaceComponent >> styleForMethodLayout [
	^ '
.methodLeft { 
	width: 75%; 
	float: right;
}
.methodMessages {
	background-color: #F6F6F6;
	width: 25%; 
	float: left;
}

ul.expanded {
	margin-top: 2px;
	margin-bottom: 2px;
	padding-left: 5px;	
}



.methodEnd { 
	clear: both;
	border-bottom: 1px solid black;
}
'
]

{ #category : #styles }
KFWorkspaceComponent >> styleForSyntax [
	^ String
		streamContents: [ :s | 
			s
				nextPutAll:
					'.methodContainer {
  font-family: monospace;
	font-size: 13pt;
}
.returnToTop { 
	text-align: right;
}

.methodTools { 
	text-align: right;
}

'.
			s cr.
			self printCSSOn: s ]
]
