Extension { #name : #GdsInform }

{ #category : #'*GdsFeel-SF-Inform-UI-Squeak' }
GdsInform class >> ensureExample [

	"self ensureExample."

	('./GdsFeel' asDirectoryEntry  / 'BGHIER.DB') 
		isFile 
			ifFalse: [ 
				self makeGDSreaderSample ]
]

{ #category : #'*GdsFeel-SF-Inform-UI-Squeak' }
GdsInform class >> makeGDSreaderSample [

	<script>
	self makeGDSreaderSampleFromPath: self sampleStreamFormatFile fullPrintString
		
]

{ #category : #'*GdsFeel-SF-Inform-UI-Squeak' }
GdsInform class >> makeGDSreaderSampleFromPath: aPath [

	| reader inform |
	reader := GdsStreamFormatReader fromStreamFormatPath: aPath.
	reader ifNil: [ ^ self ].
	inform := GdsInform new.	
	inform reader: reader.
	false 
		ifTrue: [ 
			inform libraryClass: GdsLibrary.
			inform structureClass: GdsStructure.
			inform elementClass: GdsElement ]
		ifFalse: [ 
			inform libraryClass: GdaLibrary.
			inform structureClass: GdaStructure.
			inform elementClass: GdaElement ].
	Cursor wait showWhile: [ 
		inform run.
		inform inspect.
		false ifTrue: [inform saveLibrary] ]
]

{ #category : #'*GdsFeel-SF-Inform-UI-Squeak' }
GdsInform class >> reMakeGDSreaderSample [

	"self reMakeGDSreaderSample"

	<script>
	| fileEntry |
	fileEntry := './GdsFeel/BGHIER.DB' asFileEntry.
	fileEntry isFile ifTrue: [ fileEntry delete ] .
	self makeGDSreaderSample
]

{ #category : #'*GdsFeel-SF-Inform-UI-Squeak' }
GdsInform class >> sampleStreamFormatFile [

	| dir fileEntry |
	dir := ('./GdsFeel' asDirectoryEntry  / GDSreader_0_3_2 projectName) ensureAsDirectory
		       assureExistence.
	fileEntry := dir / 'bghier.gds'.
	fileEntry exists ifFalse: [ 
		| doc data  |
		doc := GDSreader_0_3_2 sampleFileBinaryURL asUrl retrieveContents.
		data :=  doc contents.
		fileEntry binaryContents:  data asByteArray ].
	^ fileEntry
]
