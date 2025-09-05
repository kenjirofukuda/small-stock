"
Instance Variables
	file:		<FileReference>

"
Class {
	#name : #GdsChunkFile,
	#superclass : #Object,
	#instVars : [
		'file',
		'chunks'
	],
	#category : #'GdsFeel-CodeManage-Pharo'
}

{ #category : #accessing }
GdsChunkFile class >> fromFile: aFileReference [
	^ self new file: aFileReference
]

{ #category : #'registry access' }
GdsChunkFile class >> workspace [

	<script>
	| stream ch sampleFile |
	stream := String new writeStream.
	sampleFile := (('./' asFileReference filesMatching: '*.st') 
		sort: [ :a :b | a size > b size ]) first.
	ch := self fromFile: sampleFile.
	ch inspect.
	ch ownPackagedChunks do: [ :each | each chunkStreamOn: stream ].
	stream contents inspect
	"UIManager default edit: stream contents label: 'Result'."
]

{ #category : #removing }
GdsChunkFile >> chunkHolders [

	| chunkStream packageName col index |
	packageName := self file basenameWithoutExtension: 'st'.
	chunkStream := ChunkReadStream on: self file readStream.
	col := OrderedCollection new.
	index := 1.
	[ chunkStream atEnd ] whileFalse: [ 
		| chunk  chunkHolder |
		chunk := chunkStream next.
		chunkHolder := GdsChunkHolder fromChunkString: chunk.
		chunkHolder chunkFile: self.
		chunkHolder index: index.
		col add: chunkHolder.
		index := index + 1
			].
		
	^ col.
]

{ #category : #accessing }
GdsChunkFile >> chunks [
	^ chunks
]

{ #category : #accessing }
GdsChunkFile >> file [

	^ file
]

{ #category : #accessing }
GdsChunkFile >> file: anObject [

	file := anObject.
	chunks := self chunkHolders asArray.
	self scanChunks
	 
]

{ #category : #accessing }
GdsChunkFile >> ownPackagedChunks [

	^ Array streamContents: [ :s | 
		  self chunks do: [ :each | 
			  each rejectable ifFalse: [ s nextPut: each ] ] ]
]

{ #category : #accesssing }
GdsChunkFile >> packageName [
	^ file basenameWithoutExtension: 'st'
]

{ #category : #removing }
GdsChunkFile >> scanChunks [
	(chunks select: [ :each | each isMethodHeader ])
		do: [ :each |
			each next setMethodBody: true ] 

]
