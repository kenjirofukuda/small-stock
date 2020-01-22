Class {
	#name : #GdsShellSyntax,
	#superclass : #ShellSyntax,
	#category : #'GdsFeel-CLI-CommandShell'
}

{ #category : #'platform dependent' }
GdsShellSyntax >> pathEntriesInDirectoryPath: aPath [
	^(super pathEntriesInDirectoryPath: aPath)
		select: [ :path | path asFileReference isDirectory]
]
