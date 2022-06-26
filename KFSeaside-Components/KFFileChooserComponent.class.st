Class {
	#name : #KFFileChooserComponent,
	#superclass : #WAComponent,
	#instVars : [
		'file',
		'files'
	],
	#category : #'KFSeaside-Components'
}

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> file [
	^ file value
]

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> file: aFileReference [
	file value: aFileReference
]

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> fileChangedDo: aBlock [
	file whenChangedDo: aBlock
]

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> files [
	files ifNil: [ Array empty copy ].
	^ files sort: [ :a :b | a basename < b basename ]
]

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> files: aFileReferences [
	self assert: (aFileReferences isKindOf: Collection).
	files := aFileReferences
]

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> initialize [
	super initialize.
	file := nil asValueHolder
]

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> renderBasenamesOn: html [
	html unorderedList
		with: [ self files
				do: [ :fRef | 
					html
						listItem: [ html anchor
								callback: [ self file: fRef ];
								with: fRef basename ] ] ]
]

{ #category : #'as yet unclassified' }
KFFileChooserComponent >> renderContentOn: html [
	self renderBasenamesOn: html
]
