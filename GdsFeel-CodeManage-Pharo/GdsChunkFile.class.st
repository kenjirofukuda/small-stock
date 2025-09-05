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
	| stream ch |
	stream := String new writeStream.
	ch := self fromFile: (('./' asFileReference filesMatching: '*.st') sort: [:a :b| a size > b size ])first.
	ch inspect.
	ch chunks do: [ :each |  
		| mt |
		mt := each markerType.
		mt first = 1 ifTrue: [ stream nextPut: $! ].
		stream  nextPutAll: each chunk.
		mt second = 1 ifTrue: [ stream nextPut: $! ].
		mt second = 2 ifTrue: [ stream nextPutAll: '! !' ].
		stream flush.
		  stream cr.].
	
	UIManager default edit: stream contents label: 'Result'.
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

{ #category : #removing }
GdsChunkFile >> removeGuestExtensions [

	| chunkStream packageName col rejectclass |
	packageName := self file basenameWithoutExtension: 'st'.
	chunkStream := ChunkReadStream on: self file readStream.
	rejectclass := nil.
	col := OrderedCollection new.
	[ chunkStream atEnd ] whileFalse: [ 
		| chunk tokens chunkIsTarget |
		chunkIsTarget := true.
		chunk := chunkStream next.
		tokens := chunk parseLiterals.
		(tokens size >= 3 and: [tokens second = #'subclass:'])
			ifTrue: [ | clazz superclass | 
				clazz := tokens third.
				superclass := tokens first.
				(superclass = #'PackageManifest')
					ifTrue: [ 
						rejectclass := clazz.
						"chunkIsTarget := false" ]
					ifFalse: [
						rejectclass := nil.].
			].				
		
		("rejectclass isNil and: ["(chunk includesSubstring: 'methodsFor:') "]")
			ifTrue: [ 
				|  tokenStream categoryName |
				tokenStream := tokens readStream.
				tokenStream upTo: 'methodsFor:'.
				categoryName := tokenStream next.
				(categoryName beginsWith: '*')
					ifTrue: [ 
						| extensionName |
						extensionName := categoryName allButFirst.
						(packageName sameAs: extensionName)
							ifFalse: [ chunkIsTarget := false ].
					]					
			].
		chunkIsTarget ifTrue: [ col add: chunk ] ].
	^ col.
]

{ #category : #removing }
GdsChunkFile >> scanChunks [
	(chunks select: [ :each | each isMethodHeader ])
		do: [ :each |
			each next setMethodBody: true ] 

]
