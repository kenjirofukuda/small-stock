"
A GdsString is special case of DataVector.

CHARACTER VECTOR Data type on GDSII.

Inherited Instance Variables
	values:		<Array<GdsCharacter>>



"
Class {
	#name : 'GdsString',
	#superclass : 'GdsVector',
	#category : 'GdsFeel-CLI-Data',
	#package : 'GdsFeel-CLI',
	#tag : 'Data'
}

{ #category : 'test' }
GdsString class >> acceptRegexPattern [
	^ '".*"'
]

{ #category : 'private' }
GdsString class >> fromAsciiValues: asciiValues [
	| elements |
	elements := asciiValues
		collect: [ :asciiValue | GdsCharacter fromAsciiValue: asciiValue ].
	^ self withAll: elements
]

{ #category : 'instance creation' }
GdsString class >> fromLiteral: aString [
	| realContents |
	aString isByteString
		ifFalse: [ ^ self syntaxError: 'STRING NOT OCTET VALUE.' ].
	aString size >= 2
		ifFalse: [ ^ self syntaxError: 'STRING NOT QUOTED.' ].
	(aString first = $" and: [ aString last = $" ])
		ifFalse: [ ^ self syntaxError: 'STRING NOT QUOTED.' ].
	aString = '""'
		ifTrue: [ ^ GdsNull instance ].
	realContents := aString copyFrom: 2 to: aString size - 1.
	^ self fromSmalltalkString: realContents
]

{ #category : 'instance creation' }
GdsString class >> fromSmalltalk: anObject [
	^ self fromSmalltalkString: anObject
]

{ #category : 'instance creation' }
GdsString class >> fromSmalltalkString: aString [
	| s msg c level markBuff resultBuff handled asciiValue |
	s := aString readStream.
	markBuff := WriteStream on: String new.
	resultBuff := WriteStream on: String new.
	msg := 'Character embed code mismatch <>'.
	level := 0.
	[ s atEnd ]
		whileFalse: [ c := s next.
			handled := false.
			c = $<
				ifTrue: [ level = 0
						ifFalse: [ ^ self syntaxError: msg ].
					level := level + 1.
					handled := true ].
			c = $>
				ifTrue: [ level = 1
						ifFalse: [ ^ self syntaxError: msg ].
					level := level - 1.
					handled := true ].
			(handled not and: [ level = 1 ])
				ifTrue: [ markBuff nextPut: c.
					handled := true ].
			(handled not and: [ level = 0 ])
				ifTrue: [ resultBuff nextPut: c.
					handled := true ].
			(s atEnd or: [ c = $> ])
				ifTrue: [ markBuff contents
						ifNotEmpty: [ "Transcript cr show: {aString . markBuff contents}."
							asciiValue := GdsCharacter
								asciiValueInsideCharMarkLiteral: markBuff contents.
							(asciiValue isKindOf: Integer)
								ifTrue: [ resultBuff nextPut: (Character value: asciiValue) ].
							markBuff reset ] ] ].
	level = 0
		ifFalse: [ ^ self syntaxError: msg ].
	^ self fromAsciiValues: resultBuff contents asByteArray asArray
]

{ #category : 'test' }
GdsString class >> isAcceptableSmalltalkObject: anObject [
	(anObject isKindOf: Collection)
		ifFalse: [ ^ false ].
	anObject ifEmpty: [ ^ false ].
	^ anObject
		allSatisfy: [ :each | GdsCharacter isAcceptableSmalltalkObject: each ]
]

{ #category : 'convert' }
GdsString >> applySymbol: aSymbol to: aObject [
	^ self illigalDataMode
]

{ #category : 'convert' }
GdsString >> gplSourceString [
	^ '"' , self gplString , '"'
]

{ #category : 'testing' }
GdsString >> isCharVector [
	^ true
]

{ #category : 'printing' }
GdsString >> printGplOn: aStream [
	aStream
		nextPutAll: ((values collect: [ :elm | elm gplString ]) joinUsing: '')
]

{ #category : 'testing' }
GdsString >> sameAsInteger [
	^ false
]
