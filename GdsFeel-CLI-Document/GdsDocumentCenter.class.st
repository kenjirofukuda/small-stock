Class {
	#name : #GdsDocumentCenter,
	#superclass : #Object,
	#classVars : [
		'HelpDirectory',
		'SourceDirectory'
	],
	#category : #'GdsFeel-CLI-Document'
}

{ #category : #resource }
GdsDocumentCenter class >> contentsOfFileReference: aFileReference [
	"self sample"

	^ aFileReference
		readStreamDo: [ :s | 
			String
				streamContents: [ :ts | 
					[ s atEnd ]
						whileFalse: [ ts nextPutAll: s nextLine asString.
							ts cr ] ] ]
]

{ #category : #accessing }
GdsDocumentCenter class >> defaultLocalDirectoryName [
	^ 'gdsfeel-local'
]

{ #category : #example }
GdsDocumentCenter class >> example [
	"self example"

	| fref |
	fref := self sourceDirectory files atRandom.
	self openWorkSpaceFromFileReference: fref
]

{ #category : #accessing }
GdsDocumentCenter class >> helpDirectory [
	^ HelpDirectory
		ifNil: [ (FileLocator imageDirectory / self defaultLocalDirectoryName
				/ 'help') resolve ]
]

{ #category : #accessing }
GdsDocumentCenter class >> helpDirectory: aFileReference [
	HelpDirectory := aFileReference asFileReference
]

{ #category : #accessing }
GdsDocumentCenter class >> holders [
	"self holders explore."

	^ self helpDirectory files
		collect: [ :fref | GdsDocumentFile new file: fref ]
]

{ #category : #lookup }
GdsDocumentCenter class >> lookupFilesIn: aDirectory match: aFileReferenceBlock [
	^ aDirectory allFiles
		select: [ :ref | 
			(ref basename beginsWithAnyOf: #('~' '.#~')) not
				and: [ aFileReferenceBlock value: ref ] ]
]

{ #category : #lookup }
GdsDocumentCenter class >> lookupGplSources [
	"self lookupGplSources explore"

	^ self
		lookupFilesIn: self sourceDirectory
		match: [ :f | f extension sameAs: 'GS' ]
]

{ #category : #lookup }
GdsDocumentCenter class >> lookupHelps [
	"self lookupHelps explore"

	^ self
		lookupFilesIn: self helpDirectory
		match: [ :f | f extension sameAs: 'HP' ]
]

{ #category : #resource }
GdsDocumentCenter class >> openWorkSpaceFromFileReference: aFileReference [
	Workspace new
		contents: (self contentsOfFileReference: aFileReference);
		openLabel: aFileReference base
]

{ #category : #settings }
GdsDocumentCenter class >> settingsOn: aBuilder [
	<systemsettings>
	(aBuilder setting: #sourceDirectory)
		parent: #GdsFeel;
		type: #Directory;
		target: self;
		description: 'The path to GDSII source file (*.GS) directory';
		label: 'GPLII Source directory'.
	(aBuilder setting: #helpDirectory)
		parent: #GdsFeel;
		type: #Directory;
		target: self;
		description: 'The path to GDSII help file (*.HP|*.DC) directory';
		label: 'GPLII Help directory'
]

{ #category : #accessing }
GdsDocumentCenter class >> sourceDirectory [
	^ SourceDirectory
		ifNil:
			[ (FileLocator imageDirectory / self defaultLocalDirectoryName / 'src')
				resolve ]
]

{ #category : #accessing }
GdsDocumentCenter class >> sourceDirectory: aFileReference [
	SourceDirectory := aFileReference asFileReference
]
