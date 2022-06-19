Class {
	#name : #GdsDocumentFile,
	#superclass : #Object,
	#instVars : [
		'contents',
		'entryName',
		'file'
	],
	#category : #'GdsFeel-CLI-Document'
}

{ #category : #accessing }
GdsDocumentFile >> contents [
	contents ifNil: [ contents := self lookupContents ].
	^ contents
]

{ #category : #accessing }
GdsDocumentFile >> entryName [
	entryName ifNil: [ entryName := self lookupEntryName ].
	^ entryName
]

{ #category : #accessing }
GdsDocumentFile >> file: aFileReference [
	file := aFileReference
]

{ #category : #private }
GdsDocumentFile >> lookupContents [
	^ GdsDocumentCenter contentsOfFileReference: file
]

{ #category : #private }
GdsDocumentFile >> lookupEntryName [
	self contents
		linesDo: [ :line | 
			line trimBoth
				ifNotEmpty: [ :trimedLine | 
					| words |
					words := trimedLine findTokens: Character separators.
					words size = 2
						ifTrue: [ (words first beginsWith: file base)
								ifTrue: [ (words second findTokens: '/') size = 3
										ifTrue: [ ^ words first ] ] ] ] ].
	^ self fileReference base
]

{ #category : #display }
GdsDocumentFile >> open [
	"GdsDocumentCenter openWorkSpaceFromFileReference: fileReference."

	(Workspace new contents: self contents) openLabel: file base
]

{ #category : #printing }
GdsDocumentFile >> printOn: aStream [
	entryName ifNil: [ ^ aStream nextPutAll: file base ].
	aStream nextPutAll: self entryName
]
