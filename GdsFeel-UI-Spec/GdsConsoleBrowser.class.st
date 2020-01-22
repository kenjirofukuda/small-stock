"
A GdsConsoleBrowser is console base browser

GdsConsoleBrowser new
	openWithSpec.
	

"
Class {
	#name : #GdsConsoleBrowser,
	#superclass : #ComposableModel,
	#instVars : [
		'structureViewMorph',
		'consoleMorph'
	],
	#category : #'GdsFeel-UI-Spec'
}

{ #category : #specs }
GdsConsoleBrowser class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		"add: #structureView;"
		add: #console;
		yourself 
		
]

{ #category : #menu }
GdsConsoleBrowser class >> gdsMenuOn: aBuilder [ 
	<worldMenu>
	(aBuilder item: #'Console Browser')
		action: [ self new openWithSpec ];
		parent: #GdsFeel;
		yourself.
]

{ #category : #initialization }
GdsConsoleBrowser >> console [
	^ consoleMorph asSpecAdapter.
]

{ #category : #initialization }
GdsConsoleBrowser >> initializeWidgets [
	consoleMorph := GdsConsoleMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.	

]

{ #category : #initialization }
GdsConsoleBrowser >> initializeWidgets2 [
	GdsFeel fittingRatio: 0.8.
	structureViewMorph := GdsStructureEditorMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	consoleMorph := GdsConsoleMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		yourself.
	consoleMorph overlayMorph: structureViewMorph.
	structureViewMorph handleEventsBySelf: false.
	consoleMorph announcer when: #mouseEnter send: #enterArea: to: structureViewMorph.
	consoleMorph announcer when: #mouseLeave send: #leaveArea: to: structureViewMorph.
	GdsStation default announcer
		when: #structureChanged
		do: [ structureViewMorph model: GdsStation default structure ]
]

{ #category : #initialization }
GdsConsoleBrowser >> structureView [
	^ structureViewMorph asSpecAdapter.
]
