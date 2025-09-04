accessing
sampleFileEntry

	"self sampleFileEntry"
	| dirEnt |
	dirEnt := self directoryEntry.
	^ (dirEnt respondsTo: #//)
		ifTrue: [dirEnt // self sampleBaseName]	  "only Cuis"
		ifFalse: [dirEnt / self sampleBaseName]  "Squeak, Pharo"