Extension { #name : #'GDSreader_0_3_2' }

{ #category : #'*GdsFeel-StreamFormat-Atomic-FileMan' }
GDSreader_0_3_2 class >> directoryEntry [

	"self directoryEntry"

	^ ('./' asDirectoryEntry / 'GdsFeel' / self projectName)
		  fullPrintString asDirectoryEntry assureExistence.
]

{ #category : #'*GdsFeel-StreamFormat-Atomic-FileMan' }
GDSreader_0_3_2 class >> sampleFileEntry [

	"self sampleFileEntry"
	| dirEnt |
	dirEnt := self directoryEntry.
	^ (dirEnt respondsTo: #//)
		ifTrue: [dirEnt // self sampleBaseName]	  "only Cuis"
		ifFalse: [dirEnt / self sampleBaseName]  "Squeak, Pharo"
]
