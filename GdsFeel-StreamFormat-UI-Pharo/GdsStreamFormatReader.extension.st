Extension { #name : #GdsStreamFormatReader }

{ #category : #'*GdsFeel-StreamFormat-UI-Pharo' }
GdsStreamFormatReader class >> chooseSampleFile [

	"self chooseSampleFile"

	| file |
	file := GdsFeelMorphic
		        chooseFullFileName: 'Choose GDS File'
		        patterns: #( '*.sf' '*.gds' '*.gdsii'  ).
	file ifNil: [ ^ '' ].
	^ file
]

{ #category : #'*GdsFeel-StreamFormat-UI-Pharo' }
GdsStreamFormatReader class >> chooseSampleFileName [

	"self chooseSampleFileName"

	| fileName |
	fileName := GdsFeelMorphic
		        chooseFullFileName: 'Choose GDS File'
		        patterns: #( '*.sf' '*.gds' '*.gdsii'  ).
	^ fileName
]

{ #category : #'*GdsFeel-StreamFormat-UI-Pharo' }
GdsStreamFormatReader class >> exampleAllRecordsFormUser [

	"self exampleAllRecordsFormUser"

	| inst |
	inst := self exampleInstanceFromUser.
	^ inst allRecords
]

{ #category : #'*GdsFeel-StreamFormat-UI-Pharo' }
GdsStreamFormatReader class >> exampleInstanceFromUser [

	"self exampleInstanceFromUser"

	| fileName |
	fileName := self chooseSampleFileName.
	fileName ifEmpty: [ ^ nil ].
	^ self fromStreamFormatPath: fileName
]
