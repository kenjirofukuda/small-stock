Extension { #name : #Archive }

{ #category : #'*GdsFeel-Foundation-ZipP8P9' }
Archive >> addTree: aFileNameOrDirectory removingFirstCharacters: n match: aBlock [
	| dir relativePath matches |
	dir := aFileNameOrDirectory asFileReference.
	relativePath := (dir fullName allButFirst: n) asFileReference.
	matches := dir entries select: [ :entry | aBlock value: entry ].
	matches
		do: [ :e | | newMember |
			newMember := e isDirectory
					ifTrue: [ self memberClass newFromDirectory: e asFileReference ]
					ifFalse: [ self memberClass newFromFile: e asFileReference ].
		newMember localFileName: (relativePath / e name) fullName.
		self addMember: newMember.
		e isDirectory ifTrue: [ self addTree: e asFileReference removingFirstCharacters: n match: aBlock ].
	]

]
