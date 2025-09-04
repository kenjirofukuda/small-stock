"
Instance Variables
	countMap:		<Dictionary<Symbol, Integer>>
	typeOrder:		<Collection<Pair<(#required | #optional), HeaderSymbol>>>
	element:		<GdsElement>
	inform:		<GdsInform>
	structure:		<GdsStructure>

"
Class {
	#name : #GdsStreamLoopContext,
	#superclass : #GdsLoopContext,
	#instVars : [
		'element',
		'structure',
		'countMap',
		'typeOrder',
		'inform'
	],
	#category : #'GdsFeel-SF-Core'
}

{ #category : #validations }
GdsStreamLoopContext >> addOptional: aSymbol [

	typeOrder add: { 
			#optional.
			aSymbol }.
	self using: aSymbol
]

{ #category : #validations }
GdsStreamLoopContext >> addRequired: aSymbol [

	typeOrder add: { 
			#required.
			aSymbol }.
	self using: aSymbol
]

{ #category : #validations }
GdsStreamLoopContext >> checkPreRequiredConsumed: aSymbol [

	self checkPreRequiredConsumed: aSymbol abort: true
]

{ #category : #validations }
GdsStreamLoopContext >> checkPreRequiredConsumed: aSymbol abort: abort [

	| preRequiredKeys |
	preRequiredKeys := self preRequiredKeysFor: aSymbol.
	preRequiredKeys do: [ :each | 
		(self hasEntry: each) ifFalse: [ 
			| msg |
			msg := inform missingField: aSymbol ofElement: element.
			inform stderr: msg.
			abort ifTrue: [ inform error: msg ] ] ]
]

{ #category : #validations }
GdsStreamLoopContext >> countOf: aSymbol [

	self using: aSymbol.
	^ countMap at: aSymbol
]

{ #category : #accessing }
GdsStreamLoopContext >> element: aGdsElement [

	element := aGdsElement
]

{ #category : #testing }
GdsStreamLoopContext >> hasEntry: aSymbol [

	^ (self countOf: aSymbol) >= 1
]

{ #category : #initialization }
GdsStreamLoopContext >> initialize [

	super initialize.
	countMap := Dictionary new.
	typeOrder := OrderedCollection new
]

{ #category : #validations }
GdsStreamLoopContext >> preRequiredKeysFor: aSymbol [

	| keys orderStream |
	keys := self requiredOrder.
	(keys includes: aSymbol) ifFalse: [ ^ #(  ) ].
	orderStream := keys readStream.
	^ (orderStream upTo: aSymbol) allButLast
]

{ #category : #validations }
GdsStreamLoopContext >> requiredConsumed: aSymbol [

	| orderStream preRequiredKeys |
	orderStream := self requiredOrder readStream.
	preRequiredKeys := (orderStream upTo: aSymbol) allButLast.
	^ preRequiredKeys allSatisfy: [ :each | self hasEntry: each ]
]

{ #category : #validations }
GdsStreamLoopContext >> requiredOrder [

	^ typeOrder
		  select: [ :each | each first = #required ]
		  thenCollect: [ :each | each second ]
]

{ #category : #accessing }
GdsStreamLoopContext >> setInform: aGdsInform [

	inform := aGdsInform
]

{ #category : #'key specs' }
GdsStreamLoopContext >> setupAREFkeys [

	"
	FULL SPEC:
	AREF [ELFLAGS] [PLEX] SNAME [STRANS [MAG] [ANGLE]] COLROW XY 
	[PROPATTR PROPVALUE]* ENDEL
	
	MINIMUM CASE:
	SREF SNAME XY ENDEL
	"

	self addOptional: #ELFLAGS.
	self addOptional: #PLEX.
	self addRequired: #SNAME.
	self addOptional: #STRANS.
	self addOptional: #MAG.
	self addOptional: #ANGLE.
	self addRequired: #XY.
	self addOptional: #PROPATTR.
	self addOptional: #PROPVALUE.
	self addRequired: #ENDEL
]

{ #category : #'key specs' }
GdsStreamLoopContext >> setupBOUNDARYkeys [

	"
	FULL SPEC: 
	BOUNDARY [ELFLAGS] [PLEX] LAYER DATATYPE  XY [PROPATTR PROPVALUE]* ENDEL	
	
	MINIMUM CASE:
	BOUNDARY  LAYER DATATYPE  XY ENDEL
	"

	self addOptional: #ELFLAGS.
	self addOptional: #PLEX.
	self addRequired: #LAYER.
	self addRequired: #DATATYPE.
	self addRequired: #XY.
	self addOptional: #PROPATTR.
	self addOptional: #PROPVALUE.
	self addRequired: #ENDEL
]

{ #category : #'key specs' }
GdsStreamLoopContext >> setupPATHkeys [

	"
	FULL SPEC: 
	PATH [ELFLAGS] [PLEX] LAYER DATATYPE [PATHTYPE][WIDTH] XY
	[PROPATTR PROPVALUE]* ENDEL
	
	MINIMUM CASE:
	PATH  LAYER DATATYPE  XY ENDEL
	"

	self addOptional: #ELFLAGS.
	self addOptional: #PLEX.
	self addRequired: #LAYER.
	self addRequired: #DATATYPE.
	self addOptional: #PATHTYPE.
	self addOptional: #WIDTH.
	self addRequired: #XY.
	self addOptional: #PROPATTR.
	self addOptional: #PROPVALUE.
	self addRequired: #ENDEL
]

{ #category : #'key specs' }
GdsStreamLoopContext >> setupSREFkeys [

	"
	FULL SPEC:
	SREF [ELFLAGS] [PLEX] SNAME [STRANS [MAG] [ANGLE]] XY 
	[PROPATTR PROPVALUE]* ENDEL
	
	MINIMUM CASE:
	SREF SNAME XY ENDEL
	"

	self addOptional: #ELFLAGS.
	self addOptional: #PLEX.
	self addRequired: #SNAME.
	self addOptional: #STRANS.
	self addOptional: #MAG.
	self addOptional: #ANGLE.
	self addRequired: #XY.
	self addOptional: #PROPATTR.
	self addOptional: #PROPVALUE.
	self addRequired: #ENDEL
]

{ #category : #'key specs' }
GdsStreamLoopContext >> setupTEXTkeys [

	"
	FULL SPEC: 
	TEXT [ELFLAGS] [PLEX] LAYER TEXTYPE [PRESENTATION] [PATHTYPE] [WIDTH] 
	[STRANS [MAG] [ANGLE]] XY STRING 
	[PROPATTR PROPVALUE]* ENDEL
	
	MINIMUM SPEC:
	TEXT  LAYER TEXTYPE  XY STRING ENDEL
	"

	self addOptional: #ELFLAGS.
	self addOptional: #PLEX.
	self addRequired: #LAYER.
	self addRequired: #TEXTTYPE. "NOT #DATATYPE"
	self addOptional: #PRESENTATION.
	self addOptional: #PATHTYPE.
	self addOptional: #WIDTH.
	self addOptional: #STRANS.
	self addOptional: #MAG.
	self addOptional: #ANGLE.
	self addRequired: #XY.
	self addRequired: #STRING.
	self addOptional: #PROPATTR.
	self addOptional: #PROPVALUE.
	self addRequired: #ENDEL
]

{ #category : #accessing }
GdsStreamLoopContext >> structure: aGdsStructure [

	structure := aGdsStructure
]

{ #category : #'switch flow' }
GdsStreamLoopContext >> switchAREF: record [

	| handled |
	#AREF = record type ifTrue: [ ^ self upCount: #AREF ].
	handled := self switchElementBegin: record.
	handled ifTrue: [ ^ self ].
	handled := self switchSNAME: record.
	handled ifTrue: [ ^ self ].
	handled := self switchSTRANS: record.
	handled ifTrue: [ ^ self ].
	#COLROW = record type ifTrue: [ 
		| ints |
		ints := record int2Array.
		element columnCount: ints first.
		element rowCount: ints second.
		^ self upCount: #COLROW ].
	handled := self switchElementEnd: record.
	handled ifTrue: [ ^ self ]
]

{ #category : #'switch flow' }
GdsStreamLoopContext >> switchBOUNDARY: record [

	| handled |
	#BOUNDARY = record type ifTrue: [ ^ self upCount: #BOUNDARY ].
	handled := self switchElementBegin: record.
	handled ifTrue: [ ^ self ].
	handled := self switchPrimitiveBegin: record.
	handled ifTrue: [ ^ self ].
	handled := self switchElementEnd: record.
	handled ifTrue: [ ^ self ]
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchElementBegin: record [

	#ELFLAGS = record type ifTrue: [ "FIXME" ].
	#PLEX = record type ifTrue: [ "FIXME" ].
	^ false
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchElementEnd: record [

	^ self switchElementEnd: record usingXY: true
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchElementEnd: record usingXY: usingXY [

	| handled |
	(usingXY and: [ #XY = record type ]) ifTrue: [ 
		handled := self switchXY: record.
		handled ifTrue: [ ^ true ] ].
	#PROPATTR = record type ifTrue: [ "FIXME" ].
	#PROPVALUE = record type ifTrue: [ "FIXME" ].
	#ENDEL = record type ifTrue: [ 
		self checkPreRequiredConsumed: record type.
		self result: { 
				false.
				element }.
		self break: true.
		self upCount: #ENDEL.
		^ true ].
	^ false
]

{ #category : #'switch flow' }
GdsStreamLoopContext >> switchPATH: record [

	| handled |
	#PATH = record type ifTrue: [ ^ self upCount: #PATH ].
	handled := self switchElementBegin: record.
	handled ifTrue: [ ^ self ].
	handled := self switchPrimitiveBegin: record.
	handled ifTrue: [ ^ self ].
	handled := self switchWireContext: record.
	handled ifTrue: [ ^ self ].
	handled := self switchElementEnd: record.
	handled ifTrue: [ ^ self ]
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchPrimitiveBegin: record [

	#LAYER = record type ifTrue: [ 
		element layerNumber: record int2.
		self upCount: #LAYER.
		^ true ].
	"TODO: not have DATATYPE elements"
	#DATATYPE = record type ifTrue: [ 
		element datatype: record int2.
		self upCount: #DATATYPE.
		^ true ].
	^ false
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchSNAME: record [

	| structureName |
	(self hasEntry: #SNAME) ifTrue: [ ^ false ].
	#SNAME = record type ifFalse: [ 
		^ inform stderr:
			  (inform missingField: record type ofElement: element) ].
	structureName := record asString.
	structureName isEmptyOrNil ifTrue: [ 
		^ inform abort:
			  (inform missingField: record type ofElement: element) ].
	element structureName: record asString.
	self upCount: #SNAME.
	^ true
]

{ #category : #'switch flow' }
GdsStreamLoopContext >> switchSREF: record [

	| handled |
	#SREF = record type ifTrue: [ ^ self upCount: #SREF ].
	handled := self switchElementBegin: record.
	handled ifTrue: [ ^ self ].
	handled := self switchSNAME: record.
	handled ifTrue: [ ^ self ].
	handled := self switchSTRANS: record.
	handled ifTrue: [ ^ self ].
	handled := self switchElementEnd: record.
	handled ifTrue: [ ^ self ]
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchSTRANS: record [

	#STRANS = record type ifTrue: [ 
		self checkPreRequiredConsumed: record type.
		element strans setReflected: record isReflected.
		element strans setAngleAbsolute: record isAbsAngle.
		element strans setMagAbsolute: record isAbsMag.
		self upCount: #STRANS.
		^ true ].
	#MAG = record type ifTrue: [ 
		(self hasEntry: #STRANS) ifFalse: [ "TODO: MISSING REQUIRED ERROR HANDLE"
			 ].
		element mag: record real8.
		self upCount: #MAG.
		^ true ].
	#ANGLE = record type ifTrue: [ 
		(self hasEntry: #STRANS) ifFalse: [ "TODO: MISSING REQUIRED ERROR HANDLE"
			 ].
		element angle: record real8.
		self upCount: #ANGLE.
		^ true ].
	^ false
]

{ #category : #'switch flow' }
GdsStreamLoopContext >> switchTEXT: record [

	| handled |
	#TEXT = record type ifTrue: [ ^ self upCount: #TEX ].
	handled := self switchPrimitiveBegin: record.
	handled ifTrue: [ ^ self ].
	#PRESENTATION = record type ifTrue: [ "FIXME" ].
	handled := self switchWireContext: record.
	handled ifTrue: [ ^ self ].
	handled := self switchSTRANS: record.
	handled ifTrue: [ ^ self ].
	handled := self switchXY: record.
	handled ifTrue: [ ^ self ].
	#STRING = record type ifTrue: [ "FIXME" ].
	handled := self switchElementEnd: record usingXY: false.
	handled ifTrue: [ ^ self ]
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchWireContext: record [

	#PATHTYPE = record type ifTrue: [ 
		element pathtype: record int2.
		self upCount: #PATHTYPE.
		^ true ].
	#WIDTH = record type ifTrue: [ 
		element width:
			(record int4 asUserFromDBU: inform library databaseUnit).
		self upCount: #WIDTH.
		^ true ].
	^ false
]

{ #category : #'switch flow common' }
GdsStreamLoopContext >> switchXY: record [

	#XY = record type ifTrue: [ 
		| points |
		self checkPreRequiredConsumed: record type.
		points := record pointsDividedByDatabaseUnit:
			          inform library databaseUnit.
		element vertices: points.
		(element type == #aref or: [ element type == #sref ]) ifTrue: [ 
			element xy: points first ].
		element type == #aref ifTrue: [ 
			| col row mat |
			"
AREF: Exactly 3 pairs
                        1:  Array reference point
                        2:  column_space*columns+reference_x
                        3:  row_space*rows+reference_y
"
			element xy: points first.
			mat := element transform.
			col := mat invertPoint: points second.
			"col x negative
						ifTrue: [self error: 'error in AREF! Found a y-axis mirrored array. This is impossible so I''m exiting'.].
					col y abs > 1e-10
						ifTrue: [self error: 'Error in AREF! The second point in XY is broken']."
			row := mat invertPoint: points third.
			"row x abs > 1e-10
						ifTrue: [self error: 'Error in AREF! The third point in XY is broken'].	"
			element xStep: ((col x / element columnCount) asFloat roundTo:
					 inform library userUnit).
			element yStep:
				((row y / element rowCount) asFloat roundTo:
					 inform library userUnit)
			"row y negative 
						ifTrue: [element yStep: element yStep negated]" ].
		self upCount: #XY.
		^ true ].
	^ false
]

{ #category : #validations }
GdsStreamLoopContext >> upCount: aSymbol [

	self using: aSymbol.
	countMap at: aSymbol put: (countMap at: aSymbol) + 1
]

{ #category : #validations }
GdsStreamLoopContext >> using: aSymbol [

	countMap at: aSymbol ifAbsentPut: [ 0 ]
]

{ #category : #validations }
GdsStreamLoopContext >> usingCounts: aSymbolArray [

	aSymbolArray do: [ :each | self using: aSymbolArray ]
]
