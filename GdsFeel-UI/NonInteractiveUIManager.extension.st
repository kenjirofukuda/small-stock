Extension { #name : #NonInteractiveUIManager }

{ #category : #'*GdsFeel-UI' }
NonInteractiveUIManager >> chooseFullFileNameMatching: patterns label: labelString path: aDirectoryPath [
	"Let the user choose a file matching the given patterns"
	^ self nonInteractiveWarning: (String streamContents: [ :s|
			s 
				nextPutAll: 'Interactive File Choice Request: ';
				nextPutAll: '[ '; nextPutAll: labelString asString; nextPutAll: ' ] ';
				print: patterns.
		])
]
