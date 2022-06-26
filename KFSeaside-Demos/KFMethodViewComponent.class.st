"
TODO:


SystemNavigation default allImplementorsOf: #drawOnAthensCanvas:


RBMethodDefinition insted: CompiledMethod.
"
Class {
	#name : #KFMethodViewComponent,
	#superclass : #KFWorkspaceComponent,
	#instVars : [
		'compiledMethod',
		'showsSelector'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #'as yet unclassified' }
KFMethodViewComponent class >> workspace [
	
]

{ #category : #accessing }
KFMethodViewComponent >> compiledMethod [
	^ compiledMethod
]

{ #category : #accessing }
KFMethodViewComponent >> compiledMethod: anObject [
	self assert: (anObject isMemberOf: CompiledMethod).
	compiledMethod := anObject.
	self masterSourceCode: compiledMethod sourceCode.
	self classOrMetaClass: compiledMethod methodClass
]

{ #category : #initialize }
KFMethodViewComponent >> initialize [
	super initialize.
	compiledMethod := nil.
	showsSelector := false
]

{ #category : #rendering }
KFMethodViewComponent >> renderContentOn: html [
	| id |
	html div
		id: (id := html nextId);
		class: 'methodLeft';
		with: [ self renderMethodToolsOn: html.
			self showsSelector
				ifTrue: [ self renderSelectorOn: html ].
			super renderContentOn: html ].
	self renderMessagesOn: html.
	html div class: 'methodEnd'
]

{ #category : #rendering }
KFMethodViewComponent >> renderMessagesOn: html [
	html div
		class: 'methodMessages';
		with: [ html unorderedList
				class: 'expanded';
				with: [ self compiledMethod messages asArray sort
						do: [ :msg | 
							html listItem
								with: [ html anchor
										callback: [ self browser findString: msg asString ];
										with: msg asString ] ] ] ]
]

{ #category : #rendering }
KFMethodViewComponent >> renderMethodToolsOn: html [
	html div
		class: 'methodTools';
		with: [ html anchor
				class: 'textButton';
				callback: [ self browser sendersOf: self compiledMethod ];
				with: '[sdr]'.
			self renderToolSpaceOn: html.
			html anchor
				class: 'textButton';
				callback: [ self browser implementersOf: self compiledMethod ];
				with: '[imp]' ]
]

{ #category : #rendering }
KFMethodViewComponent >> renderSelectorOn: html [
	html div
		class: 'selectorSpec';
		with: [ | classString |
			classString := self compiledMethod methodClass asString.
			html anchor
				callback: [ | linkClass |
					linkClass := classString.
					self compiledMethod methodClass
						ifNotNil: [ :clazz | 
							clazz isMeta
								ifTrue: [ linkClass := (classString findTokens: ' ') first ] ].
					self browser findString: linkClass ];
				with: classString.
			html render: '>>'.
			html render: self compiledMethod selector asString ]
]

{ #category : #testing }
KFMethodViewComponent >> showsSelector [
	^ showsSelector
]

{ #category : #accessing }
KFMethodViewComponent >> showsSelector: anObject [
	showsSelector := anObject
]
