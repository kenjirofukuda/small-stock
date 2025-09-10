Extension { #name : #MorphicUIManager }

{ #category : #'*GdsFeel-UI-Extension' }
MorphicUIManager >> chooseFullFileNameMatching: patterns label: labelString path: aDirectoryPath [

	| modalMorph |
	modalMorph := self modalMorph.
	^ modalMorph theme
		  chooseFullFileNameIn: modalMorph
		  title: (labelString ifNil: [ 'Choose File' translated ])
		  patterns: patterns
		  path: aDirectoryPath asFileReference fullName
		  preview: false
]
