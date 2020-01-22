Class {
	#name : #DxfMtext,
	#superclass : #DxfShape,
	#instVars : [
		'text'
	],
	#classVars : [
		'TextMatcher'
	],
	#category : #'KFDxf-Model'
}

{ #category : #'class initialization' }
DxfMtext class >> initialize [
	"self initialize"
	TextMatcher := '{(.+);(.+)}' asRegex.
]

{ #category : #'as yet unclassified' }
DxfMtext >> attachmentPointCode [
	^ self numberByNumber: 71 default: 0.  
]

{ #category : #'as yet unclassified' }
DxfMtext >> drawingDirectionCode [
	^ self numberByNumber: 72 default: 0.  
]

{ #category : #accessing }
DxfMtext >> lookupText [
	| basicResult |
	basicResult := self rawText.
	(basicResult first = ${ and: basicResult last = $})
		ifFalse: [ ^ basicResult ].
	basicResult := basicResult allButFirst allButLast.
	(basicResult includes: $;)
		ifFalse: [ ^ basicResult ].	
	^ (basicResult findTokens: ';') last
]

{ #category : #deprecated }
DxfMtext >> lookupTextRegExp [
	| basicResult |
	basicResult := self rawText.
	[TextMatcher 
		matchesIn: basicResult
		subexpressionsDo: [ :expression :expressionFragments | ^ expressionFragments last ]]
		on: Error do: [ :ex | ].
	^ basicResult
]

{ #category : #'as yet unclassified' }
DxfMtext >> ls [
	^ self numberByNumber: 44 default: 0.0.  
]

{ #category : #'as yet unclassified' }
DxfMtext >> m [
	^ self numberByNumber: 71 default: 0.0.  
]

{ #category : #printing }
DxfMtext >> printOn: aStream [ 
	super printOn: aStream.
	aStream nextPut: $(.
	self text printOn: aStream.
	aStream nextPut: $).	
]

{ #category : #'as yet unclassified' }
DxfMtext >> rawText [
	^ self encodedStringByNumber: 1 
]

{ #category : #accessing }
DxfMtext >> text [
	^ text ifNil: [ text := self lookupText ]
]

{ #category : #accessing }
DxfMtext >> width [
	^ self numberByNumber: 41 default: 0.0.  
]

{ #category : #'as yet unclassified' }
DxfMtext >> width46 [
	^ self numberByNumber: 46 default: 0.0.  
]
