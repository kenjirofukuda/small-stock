"
abstract class for GdsCodeManageForSqueak and GdsCodeManageForCuis

"
Class {
	#name : #GdsCodeManage,
	#superclass : #Object,
	#instVars : [
		'beLegacyPrinter',
		'originalPrinter'
	],
	#classVars : [
		'Default'
	],
	#category : #'GdsFeel-CodeManage-Pharo'
}

{ #category : #'see class side' }
GdsCodeManage class >> default [ 
	^ Default ifNil: [ Default := self new ]
]

{ #category : #examples }
GdsCodeManage class >> deleteEmptySources: aFileReference [
	aFileReference isDirectory
		ifTrue: [ 
			(aFileReference filesMatching: '*.st')
				do: [ :each | self deleteIfEmpty: each ] ]
]

{ #category : #examples }
GdsCodeManage class >> deleteIfEmpty: aFileReference [

	(aFileReference isFile and: [ aFileReference size = 0 ]) 
		ifTrue: [ 
			aFileReference ensureDelete ].
	^ aFileReference
]

{ #category : #examples }
GdsCodeManage class >> fileOutTargets [
	<example>
	self default fileOutTargets
]

{ #category : #'see class side' }
GdsCodeManage class >> for: aClass [
	^ self default for: aClass
]

{ #category : #'registry access' }
GdsCodeManage class >> initialize [
	Default := nil.
]

{ #category : #examples }
GdsCodeManage class >> postReadyForCuis [

	<example>
	| sources squeakFolder cuisFolder |
	squeakFolder := './ForSqueak' asFileReference ensureCreateDirectory.
	cuisFolder := './ForCuis' asFileReference ensureCreateDirectory.
	sources := (squeakFolder filesMatching: '*.st') reject: [ :each | 
		           each size = 0 ].
	(squeakFolder filesMatching: '*.st') do: [ :each | 
		| dest |
		dest := cuisFolder / each basename.
		dest ensureDelete.
		dest writeStreamDo: [ :ws | 
			each readStreamDo: [ :rs | 
				[ rs atEnd ] whileFalse: [ 
					| line |
					line := rs nextLine trimRight.
					ws nextPutAll: line.
					ws nextPut: Character lf ] ] ].
		self deleteIfEmpty: dest. ].
		self deleteEmptySources: cuisFolder.
]

{ #category : #examples }
GdsCodeManage class >> postReadyForSqueak [

	<example>
	| fileOuts squeakFolder |
	fileOuts := './' asFileReference filesMatching: '*.st'.
	squeakFolder := './ForSqueak' asFileReference ensureCreateDirectory.
	fileOuts do: [ :each | 
		| dest |
		dest := squeakFolder / each basename.
		self deleteIfEmpty: each.
		each isFile
			ifTrue: [
				dest ensureDelete.
				each moveTo: dest ].
		self deleteIfEmpty: dest ].
	self deleteEmptySources: squeakFolder.
]

{ #category : #'see class side' }
GdsCodeManage class >> printer: aClassDifinitionPrinter [
	^ self default printer: aClassDifinitionPrinter
]

{ #category : #'registry access' }
GdsCodeManage class >> workspace [
"
[PharoPackageFormatter formatPackageNamed: 'GdsFeel-Model-Atomic' ] 
	on: Error do: [:ex | ('Error: ', ex asString) traceCr.].
"
]

{ #category : #testing }
GdsCodeManage >> canLegacyPrinter [
	^ beLegacyPrinter
	
]

{ #category : #testing }
GdsCodeManage >> fileOutTargets [

	"self default fileOutTargets"

	self legacyPrinterActivateDuring: [ 
		self targetPackageNames do: [ :pkgSymbol | 
			| pkg |
			pkg := RPackageOrganizer default packageNamed: pkgSymbol.
			pkg fileOut ].
		self targetClassNames do: [ :classSymbol | 
			| clazz |
			clazz := Smalltalk at: classSymbol.
			clazz fileOut ] ].
	self class deleteEmptySources: './' asFileReference.
]

{ #category : #'instance creation' }
GdsCodeManage >> for: aClass [

]

{ #category : #initialization }
GdsCodeManage >> initialize [
	beLegacyPrinter := false
]

{ #category : #testing }
GdsCodeManage >> legacyPrinterActivateDuring: aBlock [

	beLegacyPrinter := true.
	[ aBlock value ] ensure: [ beLegacyPrinter := false ]
]

{ #category : #initialization }
GdsCodeManage >> printer: aClassDefinitionPrinter [

	^ beLegacyPrinter
		  ifTrue: [ ClassDefinitionPrinter legacy ]
		  ifFalse: [ aClassDefinitionPrinter ]
]

{ #category : #'see class side' }
GdsCodeManage >> seeClassSide [
]

{ #category : #testing }
GdsCodeManage >> targetClassNames [

	"GdsCodeManage default targetPackageNames"

	| col |
	col := OrderedCollection new.
	col add: #LineSegment.
	col add: #Bezier2Segment.
	col add: #Bezier3Segment.

	^ col
]

{ #category : #testing }
GdsCodeManage >> targetPackageNames [
	"GdsCodeManage default targetPackageNames"
	| col |
	col := OrderedCollection new.
	col addAll:
		(RPackageOrganizer default packageNames select: [ :pkg | 
			 pkg beginsWithAnyOf: #( 'GdsFeel-StreamFormat-Atomic' ) ]).
	^ col
]
