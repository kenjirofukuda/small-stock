"
A GdsStreamFormatReader is StreamFormat record splitter.


Instance Variables
	stream:		<BinayFIleStream>

stream
	- dont use MultiByteFileStream.

"
Class {
	#name : #GdsStreamFormatReader,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#classVars : [
		'TypeCodeMap'
	],
	#category : #'GdsFeel-Model-StreamFormat'
}

{ #category : #'user interface' }
GdsStreamFormatReader class >> chooseSampleFile [

	"self chooseSampleFile"

	| file |
	file := GdsFeelMorphic
		        chooseFullFileName: 'Choose sampleFile'
		        extensions: #( 'sf' 'gds' 'gdsii' ).
	file ifNil: [ ^ nil ].
	^ file
]

{ #category : #example }
GdsStreamFormatReader class >> example [

	"self example"

	| inst |
	inst := self exampleInstance.
	^ inst allRecords
]

{ #category : #example }
GdsStreamFormatReader class >> exampleInstance [

	"self exampleInstance"

	| file |
	file := self chooseSampleFile.
	file ifNil: [ ^ nil ].
	^ self fromStreamFormatPath: file
]

{ #category : #'instance creation' }
GdsStreamFormatReader class >> fromStreamFormatPath: aString [

	"self exampleInstance"

	| inst |
	inst := self new stream:
		        (File openForReadFileNamed: aString fullName).
	^ inst
]

{ #category : #'data format' }
GdsStreamFormatReader class >> headerSpec [

	^ { 
		  #( 16r00 HEADER ).
		  #( 16r01 BGNLIB ).
		  #( 16r02 LIBNAME ).
		  #( 16r03 UNITS ).
		  #( 16r04 ENDLIB ).
		  #( 16r05 BGNSTR ).
		  #( 16r06 STRNAME ).
		  #( 16r07 ENDSTR ).
		  #( 16r08 BOUNDARY ).
		  #( 16r09 PATH ).
		  #( 16r0A SREF ).
		  #( 16r0B AREF ).
		  #( 16r0C TEXT ).
		  #( 16r0D LAYER ).
		  #( 16r0E DATATYPE ).
		  #( 16r0F WIDTH ).
		  #( 16r10 XY ).
		  #( 16r11 ENDEL ).
		  #( 16r12 SNAME ).
		  #( 16r13 COLROW ).
		  #( 16r14 TEXTNODE ).
		  #( 16r15 NODE ).
		  #( 16r16 TEXTTYPE ).
		  #( 16r17 PRESENTATION ).
		  #( 16r18 SPACING ).
		  #( 16r19 STRING ).
		  #( 16r1A STRANS ).
		  #( 16r1B MAG ).
		  #( 16r1C ANGLE ).
		  #( 16r1D UINTEGER ).
		  #( 16r1E USTRING ).
		  #( 16r1F REFLIBS ).
		  #( 16r20 FONTS ).
		  #( 16r21 PATHTYPE ).
		  #( 16r22 GENERATIONS ).
		  #( 16r23 ATTRTABLE ).
		  #( 16r24 STYPTABLE ).
		  #( 16r25 STRTYPE ).
		  #( 16r26 ELFLAGS ).
		  #( 16r27 ELKEY ).
		  #( 16r28 LINKTYPE ).
		  #( 16r29 LINKKEYS ).
		  #( 16r2A NODETYPE ).
		  #( 16r2B PROPATTR ).
		  #( 16r2C PROPVALUE ).
		  #( 16r2D BOX ).
		  #( 16r2E BOXTYPE ).
		  #( 16r2F PLEX ).
		  #( 16r30 BGNEXTN ).
		  #( 16r31 ENDTEXTN ).
		  #( 16r32 TAPENUM ).
		  #( 16r33 TAPECODE ).
		  #( 16r34 STRCLASS ).
		  #( 16r35 RESERVED ).
		  #( 16r36 FORMAT ).
		  #( 16r37 MASK ).
		  #( 16r38 ENDMASKS ).
		  #( 16r39 LIBDIRSIZE ).
		  #( 16r3A SRFNAME ).
		  #( 16r3B LIBSECUR ) }
]

{ #category : #initialization }
GdsStreamFormatReader class >> initialize [

	"self initialize"

	TypeCodeMap := self lookupTypeCodeMap
]

{ #category : #private }
GdsStreamFormatReader class >> lookupTypeCodeMap [

	| map |
	map := Dictionary new.
	self headerSpec do: [ :each | map at: each first put: each second ].
	^ map
]

{ #category : #initialization }
GdsStreamFormatReader class >> typeForCode: aByte [

	^ TypeCodeMap at: aByte ifAbsent: [ #UNKOWN ]
]

{ #category : #accessing }
GdsStreamFormatReader >> allRecords [

	^ Array streamContents: [ :s | 
		  self allRecordsDo: [ :each | s nextPut: each ] ]
]

{ #category : #enumerating }
GdsStreamFormatReader >> allRecordsDo: aBlock [

	| record |
	self reset.
	record := nil.
	[ 
	record := self nextRecord.
	record isNil ] whileFalse: [ aBlock value: record ]
]

{ #category : #api }
GdsStreamFormatReader >> nextByteArray [

	| restSize bytes recordSize |
	recordSize := self recordSize.
	recordSize < 0 ifTrue: [ ^ #(  ) ].
	restSize := recordSize - 2.
	restSize <= 0 ifTrue: [ ^ #(  ) ].
	bytes := (stream next: restSize) asByteArray.
	^ bytes
]

{ #category : #api }
GdsStreamFormatReader >> nextRecord [

	"^[GdsStreamRecord new bytes: self nextByteArray] on: Error do: [:ex | nil]."

	| bytes |
	bytes := self nextByteArray.
	bytes ifEmpty: [ ^ nil ].
	^ GdsStreamRecord new bytes: bytes
]

{ #category : #accessing }
GdsStreamFormatReader >> recordSize [

	| buff |
	stream atEnd ifTrue: [ ^ -1 ].
	buff := (stream next: 2) asByteArray.
	^ buff unsignedShortAt: 1 bigEndian: true
]

{ #category : #api }
GdsStreamFormatReader >> reset [

	"stream reset."

	self assert: [ stream position = 0 ]
]

{ #category : #accessing }
GdsStreamFormatReader >> stream: aStream [

	stream := aStream
]

{ #category : #api }
GdsStreamFormatReader >> unreadRecord: aGdsStreamRecord [

	self unreadSize: aGdsStreamRecord countBytes + 2
]

{ #category : #api }
GdsStreamFormatReader >> unreadSize: aInteger [

	stream skip: aInteger negated
]
