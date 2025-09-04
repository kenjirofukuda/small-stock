Class {
	#name : #GdsChunkFile,
	#superclass : #Object,
	#instVars : [
		'file'
	],
	#category : #'GdsFeel-CodeManage-Pharo'
}

{ #category : #accessing }
GdsChunkFile class >> fromFile: aFileReference [
	^ self new file: aFileReference
]

{ #category : #accessing }
GdsChunkFile >> file [

	^ file
]

{ #category : #accessing }
GdsChunkFile >> file: anObject [

	file := anObject
]

{ #category : #removing }
GdsChunkFile >> removeGuestExtensions [

	| chunkStream packageName col |
	packageName := self file basenameWithoutExtension: 'st'.
	chunkStream := ChunkReadStream on: self file readStream.
	col := OrderedCollection new.
	[ chunkStream atEnd ] whileFalse: [ 
		| chunk chunkIsTarget |
		chunkIsTarget := true.
		chunk := chunkStream next.
		(chunk includesSubstring: 'methodsFor:') 
			ifTrue: [ 
				| tokens tokenStream categoryName |
				tokens := chunk parseLiterals.
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
