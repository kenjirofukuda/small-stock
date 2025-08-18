Class {
	#name : #GdsLibraryTest,
	#superclass : #GdsOldTestCase,
	#instVars : [
		'lib',
		'libMap'
	],
	#category : #'GdsFeel-Model-Tests'
}

{ #category : #tests }
GdsLibraryTest >> deleteSample [
	libMap valuesDo: [:db | db close.]
	
]

{ #category : #tests }
GdsLibraryTest >> makeSampleNamed: aLibName [
	lib := GdsLibrary initializeName: aLibName.
	libMap at: lib libName put: lib.
	lib newStructureNamed: lib libName  withActivate: true.
	lib close.
	^lib.
	
]

{ #category : #tests }
GdsLibraryTest >> puts: anObject [
	Transcript cr; show: anObject.
]

{ #category : #tests }
GdsLibraryTest >> setUp [
	super setUp.
	libMap := Dictionary new.

]

{ #category : #tests }
GdsLibraryTest >> testDeleteExtracted [
	self sampleLibrary extractDirectory isDirectory
		ifTrue: [
			self sampleLibrary deleteExtracted.
			self assert: self sampleLibrary extractDirectory exists not]
		ifFalse: [self error: ' not extracted'].
]

{ #category : #'tests-utility' }
GdsLibraryTest >> testExtract [
]

{ #category : #tests }
GdsLibraryTest >> testExtractDirectory [
	self assert: (self sampleLibrary extractDirectory isKindOf: FileReference).

	self assert: (self sampleLibrary extractDirectory base 
							sameAs: self sampleLibrary name).

	self sampleLibrary extractDirectory exists
		ifTrue: [ self assert: self sampleLibrary extractDirectory isDirectory  ]
]

{ #category : #tests }
GdsLibraryTest >> testExtractedStructureNames [

	self sampleLibrary ensureOpenDuring: [ 
		self sampleLibrary extractedStructureNames inspect ]
]

{ #category : #'tests-accessing' }
GdsLibraryTest >> testFile [
	self assert: (self sampleLibrary file isKindOf: FileReference).

]

{ #category : #tests }
GdsLibraryTest >> testInitializeName [
	"Tests GdsLibrary>>#initializeName:"

	self makeSampleNamed: 'fuck1'.
	self assert: lib libName equals: 'FUCK1'

	"libMap inspect."
]

{ #category : #'tests-private' }
GdsLibraryTest >> testLookupStructureNames [
	self sampleLibrary lookupStructureNames traceCr.
]

{ #category : #tests }
GdsLibraryTest >> testName [
	"name is whtout extension"
	self assert: false equals: (self sampleLibrary name endsWith: '.DB')
]

{ #category : #tests }
GdsLibraryTest >> testStructureNames [

	self sampleLibrary structureNames inspect
]

{ #category : #tests }
GdsLibraryTest >> testStructures [

	self assert: self sampleLibrary structures isCollection.
	self sampleLibrary structures inspect
]

{ #category : #tests }
GdsLibraryTest >> testZipArchiveDo [
	self zipArchiveDo: [:zip |
		(zip memberNamed: 'LIB.ini')
			contents traceCr.
		(zip memberNamed: 'layers.xml')
				contents traceCr.].
	
]

{ #category : #tests }
GdsLibraryTest >> testZipStructureNames [
	self assert: (self sampleLibrary zipStructureNames isCollection).
	self sampleLibrary zipStructureNames
		ifNotEmpty: [ :names | 
			names allSatisfy: [ :name | 
				name isString and: [ 
				(name endsWith: '.structure') not ] ] ]
]

{ #category : #'tests-utility' }
GdsLibraryTest >> zipArchiveDo: aZipBlock [
	self sampleLibrary zipArchiveDo: aZipBlock.
	
]
