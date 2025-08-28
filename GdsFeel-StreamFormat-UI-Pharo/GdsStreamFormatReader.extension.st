Extension { #name : #GdsStreamFormatReader }

{ #category : #'*GdsFeel-StreamFormat-UI-Pharo' }
GdsStreamFormatReader class >> chooseSampleFileName [

	"self chooseSampleFileName"

	| fileName |
	fileName := UIManager default
		        chooseFullFileNameMatching: #( '*.sf' '*.gds' '*.gdsii' )
		        label: 'Choose GDS File'
		        path: FileSystem workingDirectory.
	fileName ifNil: [ ^ '' ].
	^ fileName
]

{ #category : #'*GdsFeel-StreamFormat-UI-Pharo' }
GdsStreamFormatReader class >> exampleAllRecordsFormUser [

	"self exampleAllRecordsFormUser"

	self exampleInstanceFromUser 
		ifNotNil: [ :inst | ^ inst allRecords ].
	^ #()
]

{ #category : #'*GdsFeel-StreamFormat-UI-Pharo' }
GdsStreamFormatReader class >> exampleInstanceFromUser [

	"self exampleInstanceFromUser"

	| fileName |
	fileName := self chooseSampleFileName.
	fileName ifEmpty: [ ^ nil ].
	^ self fromStreamFormatPath: fileName
]
