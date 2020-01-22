"
A DxfShapeTest is a test class for testing the behavior of DxfShape
"
Class {
	#name : #DxfShapeTest,
	#superclass : #DxfTest,
	#category : #'KFDxf-Tests'
}

{ #category : #'as yet unclassified' }
DxfShapeTest class >> applicationDirectories [
	^ { 
'C:/Program Files' .
'C:/Program Files (x86)' .
'/Applications' .
'/opt' .
FileLocator home / 'opt' .
}

]

{ #category : #'as yet unclassified' }
DxfShapeTest class >> qcadExamplesDirectory [
	self applicationDirectories 
		do: [ :pathString | 
			| path |
			path := pathString asFileReference.
			path isDirectory
				ifTrue: [
					(path directoryNames select: [ :dirName | dirName asLowercase beginsWith: 'qcad' ])
						ifNotEmpty: [ :dirs | 
							path := path / dirs first / 'examples'.
							path isDirectory
								ifTrue: [ ^ path ] ] ] ].
	^ nil
]

{ #category : #'as yet unclassified' }
DxfShapeTest class >> qcadExamplesDxfFiles [
	"self qcadExamplesDxfFiles explore."
	self qcadExamplesDirectory 
		ifNotNil: [ :dir | ^ dir filesMatching: '*.dxf'  ].
	^ #()
]

{ #category : #'tests-accessing' }
DxfShapeTest >> testTypeString [
	self assert: DxfLine typeString equals: 'LINE' .
	self assert: DxfPoint typeString equals: 'POINT' .
	self assert: DxfMtext typeString equals: 'MTEXT' .
	self assert: DxfText typeString equals: 'TEXT' .
	self assert: DxfCircle typeString equals: 'CIRCLE'.
	self assert: DxfInsert typeString equals: 'INSERT'.
	
]
