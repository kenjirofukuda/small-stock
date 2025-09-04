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
