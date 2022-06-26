Class {
	#name : #KFTextViewComponent,
	#superclass : #WAComponent,
	#instVars : [
		'fileSelector',
		'fileTarget'
	],
	#category : #'KFSeaside-Components'
}

{ #category : #accessing }
KFTextViewComponent >> contents [
	^ self file readStream contents asString
]

{ #category : #accessing }
KFTextViewComponent >> file [
	fileTarget ifNil: [ ^ nil ].
	fileSelector ifNil: [ ^ nil ].
	^ fileTarget perform: fileSelector
]

{ #category : #rendering }
KFTextViewComponent >> formatCount: anInteger [
	^ anInteger asString padLeftTo: 5 with: Character space
]

{ #category : #'as yet unclassified' }
KFTextViewComponent >> getFileSelector: aSelector [
	fileSelector := aSelector
]

{ #category : #'as yet unclassified' }
KFTextViewComponent >> postBinding [
	
]

{ #category : #rendering }
KFTextViewComponent >> renderContentOn: html [
	self renderTextOn: html
]

{ #category : #rendering }
KFTextViewComponent >> renderLine: aString on: html [
	html code
		class: 'source';
		with: aString
]

{ #category : #rendering }
KFTextViewComponent >> renderLineCount: anInteger on: html [
	html code
		class: 'lineCount';
		with: (self formatCount: anInteger)
]

{ #category : #rendering }
KFTextViewComponent >> renderPlainSourceOn: html [
	self file ifNil: [ ^ self ].
	html
		preformatted: [ html code
				class: 'source';
				with: [ html text: self contents ] ]
]

{ #category : #rendering }
KFTextViewComponent >> renderTextOn: html [
	| lineCount |
	self file ifNil: [ ^ self ].
	lineCount := 1.
	self contents
		linesDo: [ :line | 
			html
				preformatted: [ self showsLineNumber
						ifTrue: [ self renderLineCount: lineCount on: html ].
					self renderLine: line on: html ].
			lineCount := lineCount + 1 ]
]

{ #category : #'as yet unclassified' }
KFTextViewComponent >> showsLineNumber [
	^ true
]

{ #category : #'as yet unclassified' }
KFTextViewComponent >> sourceTarget: aClassOrObject [
	fileTarget := aClassOrObject
]

{ #category : #hooks }
KFTextViewComponent >> style [
	^ '
.source {
	font-size: 18px;
}

.lineCount {
	font-size: 14px;
}

pre {
	margin: 0px;
	padding: 0px;
}

code.lineCount {
	margin-right: 4px;
	color: gray;
}

'
]
