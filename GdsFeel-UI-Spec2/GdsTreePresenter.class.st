Class {
	#name : #GdsTreePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'menuBar',
		'tree',
		'visibleElementList',
		'inspectorView',
		'tabManager',
		'layers',
		'kinds',
		'statusBar'
	],
	#category : #'GdsFeel-UI-Spec2'
}

{ #category : #initialization }
GdsTreePresenter class >> defaultSpec [
	^ SpBoxLayout newVertical
		add: #menuBar;
		add:
			(SpBoxLayout newHorizontal
				add: #tree;
				add:
					(SpBoxLayout newVertical
						add: #visibleElementList;
						add: #inspectorView);
				add: #tabManager;
				add:
					(SpBoxLayout newVertical
						add: #layers;
						add: #kinds));
		add: #statusBar;
		yourself
]

{ #category : #examples }
GdsTreePresenter class >> open [
	<example>
	self new openWithSpec
]

{ #category : #initialization }
GdsTreePresenter >> debugMenu [
	^ self newMenu
]

{ #category : #initialization }
GdsTreePresenter >> fileMenu [
	^ self newMenu
		addGroup: [ :aGroup | 
			aGroup addItem: [ :anItem | 
				
				anItem 
					name: 'Open Ziped DB...'] ]
]

{ #category : #initialization }
GdsTreePresenter >> initializeMenuBar [
	menuBar := self newMenuBar.
	menuBar addGroup: [ :group |
		group addItem: [ :item |
			item
				name: 'File';
				icon: (self iconNamed: #open);
				subMenu: self fileMenu ].
		"group addItem: [ :item |
			item
				name: 'Debug';
				subMenu: self debugMenu ]" ].
	"menuBar addKeybindingsTo: self".
	
]

{ #category : #initialization }
GdsTreePresenter >> initializePresenters [
	self initializeMenuBar.
	tree := self newMorph.
	visibleElementList := self newMorph.
	inspectorView := self newMorph.
	tabManager := self newMorph.
	layers := self newMorph.
	kinds := self newMorph.
		statusBar := self newMorph.
]

{ #category : #initialization }
GdsTreePresenter >> initializeWindow: aWindowPresenter [
	super initializeWindow: aWindowPresenter.
	aWindowPresenter 
	title: 'GDS';
	initialExtent: (800 @ 600).
]
