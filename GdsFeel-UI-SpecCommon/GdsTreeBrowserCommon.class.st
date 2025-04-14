Class {
	#name : #GdsTreeBrowserCommon,
	#superclass : #Object,
	#instVars : [
		'specImpl',
		'structureSortBlock'
	],
	#category : #'GdsFeel-UI-SpecCommon'
}

{ #category : #initialization }
GdsTreeBrowserCommon >> initialize [ 
	super initialize.
	structureSortBlock := [ :s1 :s2 | s1 name < s2 name ] asValueHolder.
	structureSortBlock whenChangedDo: [ specImpl updateTree ].
]

{ #category : #'ui building' }
GdsTreeBrowserCommon >> onWindowClosed [
	self station structure:nil.
	self station quit.
]

{ #category : #'action - selection independent' }
GdsTreeBrowserCommon >> openLibrary [

	| file |
	file := GdsFeelMorphic
		        chooseFullFileName: 'Choose GdsFeel Library File .DB'
		        patterns: #( '*.db' ).
	file ifNil: [ ^ self inform: 'Library open Canceld' ].
	file := file asFileReference.
	(GdsLibrary isLibraryFile: file) ifFalse: [
		^ self inform: ('<1p> is not a GdsFeel file' expandMacrosWith: file) ].
	Cursor wait showWhile: [ specImpl registerLibraryFile: file ]
]

{ #category : #'action - selection independent' }
GdsTreeBrowserCommon >> sortByArea [
	self structureSortBlock: [ :s1 :s2 | s1 dataExtentForElements area > s2 dataExtentForElements area ]
]

{ #category : #'action - selection independent' }
GdsTreeBrowserCommon >> sortByName [
	self structureSortBlock: [ :s1 :s2 | s1 name < s2 name ]
]

{ #category : #accessing }
GdsTreeBrowserCommon >> specImpl [

	^ specImpl
]

{ #category : #accessing }
GdsTreeBrowserCommon >> specImpl: anObject [

	specImpl := anObject
]

{ #category : #accessing }
GdsTreeBrowserCommon >> station [ 
	^ GdsStation default
]

{ #category : #api }
GdsTreeBrowserCommon >> structureSortBlock [
	^ structureSortBlock value
]

{ #category : #api }
GdsTreeBrowserCommon >> structureSortBlock: aBlock [
	structureSortBlock value: aBlock
]
