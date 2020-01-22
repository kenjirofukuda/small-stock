Class {
	#name : #DxfDataGroup,
	#superclass : #Object,
	#instVars : [
		'code',
		'data'
	],
	#category : #'KFDxf-Model'
}

{ #category : #'as yet unclassified' }
DxfDataGroup class >> newFromCode: aCode data: aData [
	^ self new code: aCode; data: aData asString ; yourself
]

{ #category : #converting }
DxfDataGroup >> asArray [
	^ Array with: self code with: self data
]

{ #category : #converting }
DxfDataGroup >> asPair [
	^ self asArray
]

{ #category : #accessing }
DxfDataGroup >> code [
	^ code 
]

{ #category : #accessing }
DxfDataGroup >> code: aCode [
	code := aCode asString trim asInteger.
]

{ #category : #accessing }
DxfDataGroup >> data [
	^ data
]

{ #category : #accessing }
DxfDataGroup >> data: aData [
	data := aData
]

{ #category : #accessing }
DxfDataGroup >> encodedString [
	^ [self data convertFromEncoding: 'utf-8'] on: Error do: [ :ex | ex return: (self data convertFromEncoding: 'sjis') ]
]

{ #category : #testing }
DxfDataGroup >> isBeginSection [
	^ self code = 0 and: [ self data trim sameAs: 'SECTION' ]
]

{ #category : #testing }
DxfDataGroup >> isBeginTable [
	^ self code = 0 and: [ self data trim sameAs: 'TABLE' ]
]

{ #category : #testing }
DxfDataGroup >> isEndSection [
	^ self code = 0 and: [ self data trim sameAs: 'ENDSEC' ]
]

{ #category : #testing }
DxfDataGroup >> isEndTable [
	^ self code = 0 and: [ self data trim sameAs: 'ENDTAB' ]
]

{ #category : #testing }
DxfDataGroup >> isSectionName [
	^ self code = 2 
]

{ #category : #testing }
DxfDataGroup >> isSeparator [
	^ #(0 2) includes: self code 
]

{ #category : #printing }
DxfDataGroup >> printOn: aStream [
	(code asString trimBoth padLeftTo: 4) printOn: aStream.
	aStream nextPut: $,.
	data printOn: aStream.
	
]
