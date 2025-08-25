Extension { #name : #GdsStreamFormatReader }

{ #category : #'*GdsFeel-StreamFormat-UI' }
GdsStreamFormatReader class >> chooseSampleFile [

	"self chooseSampleFile"

	| file |
	file := GdsFeelMorphic
		        chooseFullFileName: 'Choose sampleFile'
		        extensions: #( 'sf' 'gds' 'gdsii' ).
	file ifNil: [ ^ nil ].
	^ file
]

{ #category : #'*GdsFeel-StreamFormat-UI' }
GdsStreamFormatReader class >> exampleAllRecordsFormUser [

	"self example"

	| inst |
	inst := self exampleInstanceFromUser.
	^ inst allRecords
]

{ #category : #'*GdsFeel-StreamFormat-UI' }
GdsStreamFormatReader class >> exampleInstanceFromUser [

	"self exampleInstance"

	| file |
	file := self chooseSampleFile.
	file ifNil: [ ^ nil ].
	^ self fromStreamFormatPath: file
]
