"
abstract class for GdsCodeManageForSqueak and GdsCodeManageForCuis

"
Class {
	#name : #KFCodeManage,
	#superclass : #Object,
	#instVars : [
		'beLegacyPrinter',
		'originalPrinter'
	],
	#classVars : [
		'Default'
	],
	#category : #'KFCodeMange-Pharo'
}

{ #category : #examples }
KFCodeManage class >> cleanupWorkingDirectory [
	('./' asFileReference filesMatching: '*.st')
		do: [ :each | each ensureDelete ].
	 
]

{ #category : #'see class side' }
KFCodeManage class >> default [ 
	^ Default ifNil: [ Default := self new ]
]

{ #category : #private }
KFCodeManage class >> deleteEmptySources: aFileReference [
	aFileReference isDirectory
		ifTrue: [ 
			(aFileReference filesMatching: '*.st')
				do: [ :each | self deleteIfEmpty: each ] ]
]

{ #category : #private }
KFCodeManage class >> deleteIfEmpty: aFileReference [

	(aFileReference isFile and: [ aFileReference size = 0 ]) 
		ifTrue: [ 
			aFileReference ensureDelete ].
	^ aFileReference
]

{ #category : #examples }
KFCodeManage class >> fileOutTargets [
	self default fileOutTargets
]

{ #category : #'registry access' }
KFCodeManage class >> initialize [
	Default := nil.
]

{ #category : #examples }
KFCodeManage class >> newSequence [
	<example>
	self fileOutTargets.
	self postReadyForSqueak.
	self postReadyForCuis.
	self cleanupWorkingDirectory.
	'./' asFileReference inspect. 
	 
]

{ #category : #'examples - deprecated' }
KFCodeManage class >> oldSequence [
	self fileOutTargets.
	self postReadyForSqueakOld.
	self postReadyForCuisOld.
	 
]

{ #category : #utilities }
KFCodeManage class >> openBaselineTemplate [

	<script>
	| names contents |
	names := self default targetPackageNames.
	contents := String streamContents: [ :s | 
		            names do: [ :each | 
			            s nextPutAll:
				            ('spec package: ''{1}''.' format: (Array with: each)).
			            s cr ].
		            s cr.
		            s nextPutAll: 'spec requires: #('.
		            s cr.
		            names do: [ :each | 
			            s nextPutAll: each asString printString.
			            s cr ].
		            s nextPutAll: ')'.		            s cr.
 ].

	UIManager default edit: contents label: 'to insert baseline:'
]

{ #category : #utilities }
KFCodeManage class >> openPackageNames [
	<script>
	UIManager default
		edit: 
			((self default targetPackageNames)
				joinUsing: String cr)  
		label: 'Target Packages'.
]

{ #category : #examples }
KFCodeManage class >> postReadyForCuis [
	self writeOnFolder: './ForCuis' asFileReference lineEnding: String lf. 
]

{ #category : #'examples - deprecated' }
KFCodeManage class >> postReadyForCuisOld [
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
KFCodeManage class >> postReadyForSqueak [
	self writeOnFolder: './ForSqueak' asFileReference lineEnding: String cr. 
]

{ #category : #'examples - deprecated' }
KFCodeManage class >> postReadyForSqueakOld [
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
KFCodeManage class >> printer: aClassDifinitionPrinter [
	^ self default printer: aClassDifinitionPrinter
]

{ #category : #'registry access' }
KFCodeManage class >> workspace [
"
[PharoPackageFormatter formatPackageNamed: 'GdsFeel-Model-Atomic' ] 
	on: Error do: [:ex | ('Error: ', ex asString) traceCr.].
"
]

{ #category : #examples }
KFCodeManage class >> writeOnFolder: aFileReference lineEnding: aLineEnding [
	| fileOuts destFolder |
	fileOuts := './' asFileReference filesMatching: '*.st'.
	destFolder := aFileReference asFileReference ensureCreateDirectory.
	(destFolder filesMatching: '*.st') do: [ :each | each ensureDelete ].
	fileOuts do: [ :src | 
		| dest chunkFile |
		dest := destFolder / src basename.
		chunkFile := KFChunkFile fromFile: src.
		chunkFile writeOn: dest writeStream lineEnding: aLineEnding.		
		self deleteIfEmpty: dest ].
	self deleteEmptySources: destFolder.
]

{ #category : #testing }
KFCodeManage >> canLegacyPrinter [
	^ beLegacyPrinter
	
]

{ #category : #testing }
KFCodeManage >> fileOutTargets [

	"self default fileOutTargets"

	self legacyPrinterActivateDuring: [ 
		self targetPackageNames do: [ :pkgSymbol | 
			(self packageOrganizerClass default packageNamed: pkgSymbol) 
				ifNotNil: [ :pkg | pkg fileOut ] ].
		self targetClassNames do: [ :classSymbol | 
			Smalltalk at: classSymbol ifPresent: [ :clazz | clazz fileOut ] ] ].
	self class deleteEmptySources: './' asFileReference
]

{ #category : #initialization }
KFCodeManage >> initialize [
	beLegacyPrinter := false
]

{ #category : #testing }
KFCodeManage >> legacyPrinterActivateDuring: aBlock [

	beLegacyPrinter := true.
	[ aBlock value ] ensure: [ beLegacyPrinter := false ]
]

{ #category : #accessing }
KFCodeManage >> packageOrganizerClass [
	Smalltalk at: #RPackageOrganizer ifPresent: [ :clazz | ^ clazz ].
	Smalltalk at: #PackageOrganizer ifPresent: [ :clazz | ^ clazz ].	
	^ nil
]

{ #category : #initialization }
KFCodeManage >> printer: aClassDefinitionPrinter [

	^ beLegacyPrinter
		  ifTrue: [ ClassDefinitionPrinter legacy ]
		  ifFalse: [ aClassDefinitionPrinter ]
]

{ #category : #'see class side' }
KFCodeManage >> seeClassSide [
]

{ #category : #testing }
KFCodeManage >> targetClassNames [

	"KFCodeManage default targetPackageNames"

	| col |
	col := OrderedCollection new.
	col add: #LineSegment.
	col add: #Bezier2Segment.
	col add: #Bezier3Segment.
	^ col
]

{ #category : #testing }
KFCodeManage >> targetPackageNames [
	"
	UIManager default
		edit: 
			((KFCodeManage default targetPackageNames)
				joinUsing: String cr)  
		label: 'Target Packages'.
	"
	| col |
	col := OrderedCollection new.
	col addAll:
		(self packageOrganizerClass default packageNames select: [ :pkg | 
			 pkg beginsWithAnyOf: #( 
			'Math-Operations-Extensions'
			'GeometryUtils'
			'KFCodeManage' 
			'KFImaging-Support'
			'KFImaging-LayerMorph'
			'GdsFeel-Model2'
			'GdsFeel-Foundation2'
			'GdsFeel-SF' 
			'GdsFeel-UI-Drawer'
			'GdsFeel-UI2'
			) ]).
	^ col
]
