Class {
	#name : #TwkCompositBrickGdsBuilder,
	#superclass : #TwkGdsBuilder,
	#instVars : [
		'library'
	],
	#category : #'TowerKit-GdsFeel'
}

{ #category : #building }
TwkCompositBrickGdsBuilder >> build [
	GdsStation default
		ensureOpenLibrary: self library
		during: [ self model allBricks
				do: [ :each | each gdsBuilder build ]
				displayingProgress: 'Building Gds data...'.
			self library layers ifNotNil: [ :layers | self setupLayers: layers ] ]
]

{ #category : #actions }
TwkCompositBrickGdsBuilder >> fileOutBrick: each to: s [
	| newStructure newName |
	s elements.
	newName := (each name , '_FLAT') asUppercase.
	s library ensureRemoveStructureNamed: newName.
	newStructure := s copyNamed: newName.
	GdsStation default structure: newStructure.
	newStructure elements
		do: [ :e | newStructure idSelection idAdd: e keyNumber ].
	newStructure idExplode.
	newStructure forceSave.
	(self model projectFolder / (newStructure name asUppercase , '.dxf'))
		ensureDelete.
	^ newStructure fileOutDxfToFolder: self model projectFolder
]

{ #category : #actions }
TwkCompositBrickGdsBuilder >> fileOutDxf [
	GdsStation default
		ensureOpenLibrary: self library
		during: [ self library structures
				do: [ :s | s forceSave ]
				displayingProgress: 'Saving structures  ...'.
			self model allBricks
				do: [ :each | each gdsBuilder structureDo: [ :s | self fileOutBrick: each to: s ] ]
				displayingProgress: 'File out dxf ...' ]
]

{ #category : #accessing }
TwkCompositBrickGdsBuilder >> library [
	^ library ifNil: [ library := self lookupLibrary  ]
]

{ #category : #private }
TwkCompositBrickGdsBuilder >> lookupLibrary [
	^ GdsStation default ensureCreateLibraryNamed: self model name
]

{ #category : #building }
TwkCompositBrickGdsBuilder >> setupLayers: layers [
	(layers atNumber: self layerNumberForPoint)
		name: 'Point'; 
		color: Color red.
	(layers atNumber: self layerNumberForSegment)
		name: 'Segment'; 
		color: Color yellow.
	(layers atNumber: self layerNumberForText) 
		name: 'Node Number'; 
		color: Color green.
	(layers atNumber: self layerNumberForSegmentText) 
		name: 'Segment Number'; 
		color: Color cyan.
]
