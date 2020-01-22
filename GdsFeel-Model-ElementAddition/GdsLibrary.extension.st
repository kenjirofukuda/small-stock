Extension { #name : #GdsLibrary }

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsLibrary >> fileOutDxfToDefault [
	self fileOutDxfToFolder: nil.
]

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsLibrary >> fileOutDxfToFolder: aContainerFolder [
	| libFolder containerFolder |
	containerFolder := aContainerFolder.
	containerFolder ifNil: [ containerFolder := './' asFileReference  ].
	libFolder := (containerFolder asFileReference / self libName) ensureCreateDirectory.
	self structures do: [ :s | s fileOutDxfToFolder: libFolder ]
]

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsLibrary >> fileOutJsonToDefault [
	self fileOutJsonToFolder: nil.
]

{ #category : #'*GdsFeel-Model-ElementAddition' }
GdsLibrary >> fileOutJsonToFolder: aContainerFolder [
	| libFolder containerFolder |
	containerFolder := aContainerFolder.
	containerFolder ifNil: [ containerFolder := './' asFileReference ].
	libFolder := (containerFolder asFileReference / self libName) ensureCreateDirectory.
	file := libFolder / self libName , '.json'.
	file ensureDelete.
	file
		writeStreamDo: [ :s | s nextPutAll: (NeoJSONWriter toStringPretty: self) ]
]
