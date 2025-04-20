Extension { #name : #Archive }

{ #category : #'*GdsFeel-Foundation-ZipP6P7' }
Archive >> addTree: aFileNameOrDirectory removingFirstCharacters: n match: aBlock [
	| dir relativePath matches localName logging |
	logging := false.
	logging
		ifTrue: [ {'addTree:' . aFileNameOrDirectory . 'removingFirstCharacters:' . n} traceCr ].
	dir := aFileNameOrDirectory asFileReference.
	relativePath := (dir fullName allButFirst: n) asFileReference.
	logging
		ifTrue: [ {'relativePath' . relativePath} traceCr ].
	matches := dir entries select: [ :entry | aBlock value: entry ].
	matches
		do: [ :e | 
			| newMember |
			newMember := e isDirectory
				ifTrue: [ self memberClass newFromDirectory: e fullName ]
				ifFalse: [ self memberClass newFromFile: e fullName ].
			localName := self fixLocalPath: (relativePath / e name) fullName.
			logging
				ifTrue: [ {newMember . 'localFileName:' . localName} traceCr ].
			newMember localFileName: localName.
			self addMember: newMember.
			e isDirectory
				ifTrue: [ 
					self
						addTree: e asFileReference
						removingFirstCharacters: n
						match: aBlock ] ]
]

{ #category : #'*GdsFeel-Foundation-ZipP6P7' }
Archive >> fixLocalPath: aPathString [
	| workingDirPath |
	workingDirPath := FileSystem workingDirectory fullName.
	^ (aPathString beginsWith: workingDirPath)
			ifTrue: [
				aPathString allButFirst: workingDirPath size ]
			ifFalse: [
				aPathString ].
]

{ #category : #'*GdsFeel-Foundation-ZipP6P7' }
Archive >> writeToFile: aFileName [
	self writeToFileNamed: aFileName fullName
]
