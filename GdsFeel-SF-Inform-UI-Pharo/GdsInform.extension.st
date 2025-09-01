Extension { #name : #GdsInform }

{ #category : #'*GdsFeel-SF-Inform-UI-Pharo' }
GdsInform class >> ensureExample [

	"self ensureExample."

	(GdsFeel projectDirectory / 'BGHIER.DB') isFile 
		ifFalse: [ 
			self makeGDSreaderSample ]
]

{ #category : #'*GdsFeel-SF-Inform-UI-Pharo' }
GdsInform class >> makeGDSreaderSample [

	<script>
	self makeGDSreaderSampleFromPath: self sampleStreamFormatFile fullName
]

{ #category : #'*GdsFeel-SF-Inform-UI-Pharo' }
GdsInform class >> makeGDSreaderSampleFromPath: aPath [

	| reader inform |
	reader := GdsStreamFormatReader fromStreamFormatPath: aPath.
	reader ifNil: [ ^ self ].
	inform := GdsInform new.	
	inform reader: reader.
	inform libraryClass: GdsLibrary.
	inform structureClass: GdsStructure.
	inform elementClass: GdsElement.
	
	Cursor wait showWhile: [ 
		inform run.
		inform saveLibrary ]
]

{ #category : #'*GdsFeel-SF-Inform-UI-Pharo' }
GdsInform class >> reMakeGDSreaderSample [

	"self reMakeGDSreaderSample"

	<script>
	| file |
	file := './GdsFeel/BGHIER.DB' asFileReference.
	file ensureDelete.
	self makeGDSreaderSample
]

{ #category : #'*GdsFeel-SF-Inform-UI-Pharo' }
GdsInform class >> sampleStreamFormatFile [

	| dir saveFile |
	dir := (GdsFeel projectDirectory / GDSreader_0_3_2 projectName)
		       ensureCreateDirectory.
	saveFile := dir / 'bghier.gds'.
	saveFile isFile ifFalse: [ 
		GDSreader_0_3_2 sampleFileBinaryURL asUrl saveContentsToFile:
			saveFile ].
	^ saveFile
]
