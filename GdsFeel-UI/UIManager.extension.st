Extension { #name : 'UIManager' }

{ #category : '*GdsFeel-UI' }
UIManager >> chooseFullFileNameMatching: patterns label: labelString path: aDirectoryPath [
	"Let the user choose a file matching the given patterns"
	^self subclassResponsibility
]
