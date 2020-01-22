Class {
	#name : #DxfFile,
	#superclass : #DxfDataGroups,
	#instVars : [
		'file',
		'lines',
		'sections'
	],
	#category : #'KFDxf-Model'
}

{ #category : #'as yet unclassified' }
DxfFile class >> example [
	"self example explore."
	^ DxfFile	 new file: (FileLocator home / 'Desktop' / 'Untitled3.dxf'); dataGroups; explore.
]

{ #category : #note }
DxfFile class >> sampleSize [
	^ 3339965
]

{ #category : #note }
DxfFile class >> spyResult1 [
^ '
 - 109188 tallies, 109368 msec.

**Tree**
--------------------------------
Process: (40s) Morphic UI Process: nil
--------------------------------
99.7% {109019ms} DxfContainer>>splitSections
  99.6% {108965ms} DxfContainer>>dataGroups
    99.6% {108965ms} DxfContainer>>lookupDataGroups
      99.2% {108521ms} DxfContainer>>lines
        99.2% {108521ms} DxfContainer>>lookupLines
          98.8% {108050ms} MultiByteFileStream(PositionableStream)>>nextLine
            98.4% {107603ms} MultiByteFileStream>>upToAnyOf:do:
              96.9% {106012ms} WriteStream>>nextPut:
                96.9% {105963ms} WideString(ByteString)>>at:put:
                  95.1% {104011ms} WideString>>at:put:
                  1.8% {1919ms} WideString class>>from:
                    1.7% {1898ms} primitives

**Leaves**
95.1% {104024ms} WideString>>at:put:
1.7% {1898ms} WideString class>>from:

**Memory**
	old			+7,593,540 bytes
	young		+3,149,504 bytes
	used		+10,743,044 bytes
	free		-1,899,604 bytes

**GCs**
	full			1 totalling 340ms (0.0% uptime), avg 340.0ms
	incr		243 totalling 745ms (1.0% uptime), avg 3.0ms
	tenures		233 (avg 1 GCs/tenure)
	root table	0 overflows
'
]

{ #category : #accessing }
DxfFile >> accadver [
	^ self headerSection accadver
]

{ #category : #accessing }
DxfFile >> dataGroups [
	^ dataGroups ifNil: [ dataGroups := self lookupDataGroups ]
]

{ #category : #initialization }
DxfFile >> dumpLines [
	"DxfContainer sample dumpLines"
	self file readStreamDo: [ :s |
		s converter: ShiftJISTextConverter new.
		[s atEnd ]
			 whileFalse: [
				s nextLine traceCr.]
		].
]

{ #category : #accessing }
DxfFile >> file [
	^ file
]

{ #category : #accessing }
DxfFile >> file: aFileReference [
	file := aFileReference asFileReference.
]

{ #category : #accessing }
DxfFile >> headerSection [
	^ self sectionNamed: 'HEADER'
]

{ #category : #initialization }
DxfFile >> initialize [
	super initialize.
	file := nil.
]

{ #category : #utility }
DxfFile >> layerOf: aDxfShape [ 
	^ self layerOf: aDxfShape default: nil 
]

{ #category : #utility }
DxfFile >> layerOf: aDxfShape default: v [
	^ self layers detect: [ :each | each name sameAs: aDxfShape layerName ] ifNone: [ v ]
]

{ #category : #accessing }
DxfFile >> layers [
	(self sectionNamed: 'TABLES')
		ifNotNil: [ :s |
			(s tableNamed: 'LAYER')
				ifNotNil: [ :table | ^ table layers ]
			 ].
	^ #()
]

{ #category : #accessing }
DxfFile >> lineTypes [
	(self sectionNamed: 'TABLES')
		ifNotNil:
			[ :s | (s tableNamed: 'LTYPE') ifNotNil: [ :table | ^ table lineTypes ] ].
	^ #()
]

{ #category : #accessing }
DxfFile >> lines [
	""
	^ lines ifNil: [ lines := self lookupLines  ]
]

{ #category : #private }
DxfFile >> lookupDataGroups [
	| index group |
	^ Array streamContents: [ :arrayStream | 
		index := 0.
		self lines do: [ :line | 
			index even
				ifTrue: [ 
					group := DxfDataGroup new.
					group code: line]
				ifFalse: [
					group 
						ifNotNil: [ 
							group data: line.
							arrayStream nextPut: group.
							group := nil ]].
				index := index + 1.
			].
	]
]

{ #category : #initialization }
DxfFile >> lookupLines [
	"DxfContainer sample dumpLines"
	^ self lookupLinesWithConvertor: (TextConverter newForEncoding: nil).
]

{ #category : #initialization }
DxfFile >> lookupLinesWithConvertor: aTextConverttor [
	"DxfContainer sample dumpLines"
	^ Array streamContents: [ :arrayStream | 
		self file readStreamDo: [ :s |
			aTextConverttor
				ifNotNil: [s converter: aTextConverttor].
			[s atEnd ]
				 whileFalse: [
					arrayStream nextPut: s nextLine ] ] ]
]

{ #category : #accessing }
DxfFile >> name [
	"Answer a name for the receiver.  This is used generically in the title of certain inspectors, such as the referred-to inspector, and specificially by various subsystems.  By default, we let the object just print itself out..  "

	^ self printString 
]

{ #category : #accessing }
DxfFile >> sectionNamed: aString [
	^ self sections detect: [ :section | section name sameAs: aString ] ifNone: [  ] 
]

{ #category : #accessing }
DxfFile >> sections [
	^ sections ifNil: [ sections := self splitSections ]
]

{ #category : #accessing }
DxfFile >> shapes [
	(self sectionNamed: 'ENTITIES')
		ifNotNil: [ :s |
			^ s shapes
			 ].
	^ #()
]

{ #category : #private }
DxfFile >> splitSections [
	| section index beginSectionIndex handled |
	section := nil.
	index := 0.
	^ Array streamContents: [ :arrayStream |
		self dataGroups do: [ :dataGroup |
			section 
				ifNil: [
					dataGroup isBeginSection
						ifTrue: [
							section := DxfSection new.
							beginSectionIndex := index ]]
			 	ifNotNil: [
					handled := false.
					(dataGroup isSectionName and: [ index == (beginSectionIndex + 1)])
						ifTrue: [ 
							section name: dataGroup data.
							handled := true].		
					(handled not and: [dataGroup isEndSection])
						ifTrue: [
							arrayStream nextPut: section .
							section := nil .
							handled := true].
					handled not 
						ifTrue: [
							section addDataGroup: dataGroup 			].
			].
			index := index + 1.				
		]  
	]
]
