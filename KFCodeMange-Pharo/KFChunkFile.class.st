"
Instance Variables
	file:		<FileReference>

"
Class {
	#name : #KFChunkFile,
	#superclass : #Object,
	#instVars : [
		'file',
		'chunks'
	],
	#category : #'KFCodeMange-Pharo'
}

{ #category : #accessing }
KFChunkFile class >> fromFile: aFileReference [
	^ self new file: aFileReference
]

{ #category : #'registry access' }
KFChunkFile class >> workspace [

	<script>
	| stream ch sampleFile |
	stream := String new writeStream.
	sampleFile := (('./' asFileReference filesMatching: '*.st') 
		sort: [ :a :b | a size > b size ]) first.
	ch := self fromFile: sampleFile.
	ch inspect.
	ch writeOn: stream.
	stream contents inspect
	"UIManager default edit: stream contents label: 'Result'."
]

{ #category : #removing }
KFChunkFile >> chunkHolders [

	| chunkStream packageName col index |
	packageName := self file basenameWithoutExtension: 'st'.
	chunkStream := ChunkReadStream on: self file readStream.
	col := OrderedCollection new.
	index := 1.
	[ chunkStream atEnd ] whileFalse: [ 
		| chunk  chunkHolder |
		chunk := chunkStream next.
		chunkHolder := KFChunkHolder fromChunkString: chunk.
		chunkHolder chunkFile: self.
		chunkHolder index: index.
		col add: chunkHolder.
		index := index + 1
			].
		
	^ col.
]

{ #category : #accessing }
KFChunkFile >> chunks [
	^ chunks
]

{ #category : #accessing }
KFChunkFile >> file [

	^ file
]

{ #category : #accessing }
KFChunkFile >> file: anObject [

	file := anObject.
	KFAbstractChunk head chunkFile: file.
	KFAbstractChunk tail chunkFile: file.
	chunks := self chunkHolders asArray.
	self scanChunks
	 
]

{ #category : #accessing }
KFChunkFile >> ownPackagedChunks [

	^ Array streamContents: [ :s | 
		  self chunks do: [ :each | 
			  each rejectable ifFalse: [ s nextPut: each ] ] ]
]

{ #category : #accesssing }
KFChunkFile >> packageName [
	^ file basenameWithoutExtension: 'st'
]

{ #category : #removing }
KFChunkFile >> scanChunks [
	(chunks select: [ :each | each isMethodHeader ])
		do: [ :each |
			each next setMethodBody: true ] 

]

{ #category : #writing }
KFChunkFile >> writeOn: aStream [ 
	self writeOn: aStream lineEnding: String cr 
]

{ #category : #writing }
KFChunkFile >> writeOn: aStream lineEnding: lineEnding [ 
	self ownPackagedChunks do: [ :each | 
		each chunkStreamOn: aStream lineEnding: lineEnding.
		aStream nextPutAll: lineEnding asString ].

]
