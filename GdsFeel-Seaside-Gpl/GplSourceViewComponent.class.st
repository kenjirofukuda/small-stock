Class {
	#name : #GplSourceViewComponent,
	#superclass : #KFTextViewComponent,
	#instVars : [
		'scanner'
	],
	#category : #'GdsFeel-Seaside-Gpl'
}

{ #category : #'as yet unclassified' }
GplSourceViewComponent >> postBinding [
	fileTarget fileChangedDo: [ scanner := nil ]
]

{ #category : #rendering }
GplSourceViewComponent >> renderContentOn: html [
	self file ifNil: [ ^ self ].
	(self scanner tokensIgnoreSpace: false)
		do: [ :token | self renderToken: token on: html ]
]

{ #category : #'as yet unclassified' }
GplSourceViewComponent >> renderToken: aToken on: html [
	aToken type = #cr
		ifTrue: [ ^ html break ].
	aToken type = #space
		ifTrue: [ ^ html code
				class: aToken type asString;
				with: [ aToken length timesRepeat: [ html space ] ] ].
	(aToken type = #reserved or: [ aToken type = #operator ])
		ifTrue: [ ^ self renderToken: aToken on: html lowercase: true ].
	self renderToken: aToken on: html lowercase: false
]

{ #category : #'as yet unclassified' }
GplSourceViewComponent >> renderToken: aToken on: html lowercase: aBoolean [
	| s |
	s := aToken fragment.
	aBoolean
		ifTrue: [ s := s asLowercase ].
	html code
		class: aToken type asString;
		with: s
]

{ #category : #accessing }
GplSourceViewComponent >> scanner [
	scanner ifNil: [ scanner := GplScanner fromFile: self file ].
	^ scanner
]

{ #category : #hooks }
GplSourceViewComponent >> style [
	^ '
code { 
	font-size: 18px;	
}

.reserved { 
	font-weight: bold;
	color: darkblue;
}

.operator { 
	color: darkblue;
}	

	

.gdsiiMethod { 
	color: darkgreen;
}	


.unresolved { 
	font-style: italic;
}	


.string { 
	color: purple;
}	

.number { 
	color: brown;
}	

.comment { 
	color: gray;
}	
	

	'
]
