Class {
	#name : #KFSimpleFileViewComponent,
	#superclass : #WAComponent,
	#instVars : [
		'chooser',
		'view'
	],
	#category : #'KFSeaside-Components'
}

{ #category : #'as yet unclassified' }
KFSimpleFileViewComponent class >> initialize [
	"self initialize."

	WAAdmin register: self asApplicationAt: 'kf/simple-file-view'
]

{ #category : #hooks }
KFSimpleFileViewComponent >> children [
	^ Array with: chooser with: view
]

{ #category : #'as yet unclassified' }
KFSimpleFileViewComponent >> chooserComponentClass [
	^ KFFileChooserComponent
]

{ #category : #'as yet unclassified' }
KFSimpleFileViewComponent >> files [
	^ Array empty
]

{ #category : #initialization }
KFSimpleFileViewComponent >> initialize [
	super initialize.
	chooser := self chooserComponentClass new.
	chooser files: self files.
	view := self viewComponentClass new.
	view sourceTarget: chooser.
	view getFileSelector: #file.
	view postBinding
]

{ #category : #rendering }
KFSimpleFileViewComponent >> renderContentOn: html [
	html
		table: [ html
				tableRow: [ html tableData
						class: 'chooser';
						with: [ html render: chooser ].
					html tableData
						class: 'view';
						with: [ html render: view ] ] ]
]

{ #category : #'as yet unclassified' }
KFSimpleFileViewComponent >> style [
	^ '
.chooser {
	vertical-align:top;
}

.view {
	vertical-align:top;
}
'
]

{ #category : #'as yet unclassified' }
KFSimpleFileViewComponent >> viewComponentClass [
	^ KFTextViewComponent
]
