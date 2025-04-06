Class {
	#name : 'GplToken',
	#superclass : 'GplAtomicToken',
	#instVars : [
		'argumentType',
		'subtokens',
		'index'
	],
	#classVars : [
		'BuiltinMethods',
		'GdsiiMethods',
		'ReservedKeywords'
	],
	#category : 'GdsFeel-CLI-Kernel',
	#package : 'GdsFeel-CLI',
	#tag : 'Kernel'
}

{ #category : 'specs' }
GplToken class >> builtinMethods [
	^ BuiltinMethods
		ifNil: [ BuiltinMethods := self lookupBuiltinMethods asSet ]
]

{ #category : 'specs' }
GplToken class >> dataTypeKeywords [
	^ #('BOOLEAN' 'CHAR' 'INTEGER' 'INTEGER2' 'REAL' 'REAL2' 'LIST')
]

{ #category : 'specs' }
GplToken class >> flowControlKeywords [
	^ #('IF' 'THEN' 'ELSE' 'ELIF' 'ENDIF' 'FOR' 'WHILE' 'DO' 'ENDDO' 'UNTIL' 'GOTO' 'SWITCH' 'OF' 'CASE' 'OUT' 'ENDSWITCH')
]

{ #category : 'specs' }
GplToken class >> gdsiiMethods [
	^ GdsiiMethods
		ifNil: [ GdsiiMethods := self lookupGdsiiMethods asSet ]
]

{ #category : 'specs' }
GplToken class >> implementedDyadicMethods [
	^ #('RESHAPE')
]

{ #category : 'specs' }
GplToken class >> implementedMonadicMethods [
	^ #('ABS' 'FLOOR' 'CEILING' 'EXP' 'LN' 'PI' 'SIN' 'COS' 'TAN' 'ARCTAN' 'NOT')
]

{ #category : 'instance creation' }
GplToken class >> initialize [
	"self initialize"

	super initialize.
	BuiltinMethods := nil.
	GdsiiMethods := nil.
	ReservedKeywords := nil
]

{ #category : 'specs' }
GplToken class >> inspectMonadicMethods [
	^ #('TYPEOF' 'SHAPE' 'RANK' 'SIZE' 'LENGTH')
]

{ #category : 'testing' }
GplToken class >> isBuiltinMethod: aString [
	^ self builtinMethods includes: aString asUppercase
]

{ #category : 'testing' }
GplToken class >> isGdsiiMethod: aString [
	^ self gdsiiMethods includes: aString asUppercase
]

{ #category : 'testing' }
GplToken class >> isProgramOnlyKeyword: aString [
	^ self programOnlyKeywords includes: aString asUppercase
]

{ #category : 'testing' }
GplToken class >> isReservedKeyword: aString [
	^ self reservedKeywords includes: aString asUppercase
]

{ #category : 'specs' }
GplToken class >> lookupBuiltinMethods [
	^ #('TYPEOF' 'SHAPE' 'RANK' 'LENGTH' 'SIZE' 'IOTA' 'INDEXOF' 'GRADEUP' 'GRADEDOWN' 'SORT' 'SORTDOWN' 'ABS' 'FLOOR' 'CEILING' 'EXP' 'LN' 'PI' 'SIN' 'COS' 'TAN' 'ARCTAN' 'NOT')
		,
			#('RESHAPE' 'IN' 'INDEXOF' 'INDECES_OF' 'MOD' 'MIN' 'MAX' 'MIN_MAX' 'POWER' 'LOGBASE' 'EQ' 'LT' 'GT' 'LEQ' 'GEQ' 'NEQ' 'AND' 'OR' 'NAND' 'NOR' 'XOR' 'BITAND' 'BITOR' 'BITXOR')
	"
[ | words1 |
	words1 := GplToken builtinMethods asSet.
	words2 := GplScanner operatorSpec collect: [ :assoc | assoc  ]
] value.

"
]

{ #category : 'specs' }
GplToken class >> lookupGdsiiMethods [
	^ #('BLUE' 'CYAN' 'GREEN' 'MAGENTA' 'RED' 'WHITE' 'YELLOW')
		,
			#('ABSANGLE' 'ABSMAG' 'ABSTATION' 'ABSWIDTH' 'ADDPLEX' 'ADDRT' 'ANGLE' 'ARC' 'AREF' 'AREFMARK' 'ASCALE' 'ASHAPE' 'AUTOHOLD' 'AND' 'ANDNOT' 'BACKUP' 'BINDATTR' 'BINDFONTS' 'BOUNDARY' 'BOUNDARYMARK' 'BOX' 'BOXTYPE' 'BROKEN' 'BSCALE' 'BSTRUCT' 'BUTTON' 'BUTTONMODE' 'BITAND' 'BITOR' 'BITXOR' 'BOUNDARYAREA' 'CE' 'CH' 'CHECKEXTERIOR1' 'CHECKEXTERIOR2' 'CHECKINTERIOR' 'CIRCLE' 'CIRCLESIZE' 'CLEAR' 'CLOSE' 'CLOSELIB' 'CLOSEREF1' 'CLOSEREF2' 'CLRPROP' 'COLORBY' 'COMMANDS' 'CONTEXT' 'COORDS' 'CRACL' 'CSTRUCT' 'CUTPATHIN' 'CUTPATHOUT' 'CARTESIAN' 'CEKEY' 'CFORMAT' 'CHECKAREA' 'CLOSESTTO' 'CRTTYPE' 'DACL' 'DASHED' 'DATACOPY' 'DATADELETE' 'DATADRAW' 'DATAMAGNIFY' 'DATAMOVE' 'DATAOVERSIZE' 'DATAPAN' 'DATAREDRAW' 'DATAREFLECT' 'DATAROTATE' 'DATASETVIEW' 'DATATYPE' 'DATAVIEWMOVE' 'DATAZOOM' 'DB' 'DE' 'DEFATTR' 'DEFMODE' 'DFUNCTION' 'DIGMODE' 'DIRECTORY' 'DISK' 'DISPLAYSTAT' 'DLN' 'DOTTED' 'DS' 'DSTRUCT' 'DVERT' 'DATAEXTENT' 'DATAVIEW' 'DAY' 'DIGIN' 'DROUND' 'DSELECT' 'EDATA' 'EDGE' 'ENAME' 'ENDLOG' 'ENTERTEXT' 'EREF' 'ESTAT' 'ESTRUCT' 'EXPLODE' 'EXPUNGE' 'EXECUTE' 'EXPINPUT' 'FCCONT' 'FCHATR' 'FCOPY' 'FDELETE' 'FILLA' 'FILLBY' 'FILLC' 'FILLD' 'FILLET' 'FILLSET' 'FINDDATA' 'FINIT' 'FLAYER' 'FLAYEROFF' 'FLAYERON' 'FLINK' 'FLIST' 'FONT' 'FONTINFO' 'FPRINT' 'FRELEASE' 'FRENAME' 'FUNCTIONS' 'FUNLINK' 'FETCH' 'FILEINFO' 'FILLB' 'FORMAT' 'GEDMODE' 'GET' 'GETITEM' 'GETP' 'GPL' 'GRID' 'GSCALE' 'GEDCOORDS' 'GEDELEMENT' 'GETEL' 'GLOBALTOLOCAL' 'GTIME' 'HARDCOPY' 'HARDLOCKS' 'HELP' 'HORIZFIRST' 'IB' 'ICOPY' 'ID' 'IDADD' 'IDCANGLE' 'IDCBOXTYPE' 'IDCDATATYPE' 'IDCFONT' 'IDCLAYER' 'IDCLEAR' 'IDCMAG' 'IDCNODETYPE' 'IDCOPY' 'IDCPATHTYPE' 'IDCTEXTTYPE' 'IDCWIDTH' 'IDDELETE' 'IDEXPLODE' 'IDMARK' 'IDMOVE' 'IDOVERSIZE' 'IDPATHEXP' 'IDREFLECT' 'IDROTATE' 'IDSTRUCT' 'IDSUMMARY' 'IDTEXTEXP' 'IDWINDOW' 'IDWINSTRUCT' 'IE' 'IFILE' 'IITEM' 'IMOVE' 'INACL' 'INFORM' 'INITDISPLAY' 'INITLIB' 'INTCHECKMODE' 'INTRT' 'ISTAT' 'ITEM' 'ITEMCOPY' 'ITEMMARK' 'ITEMREFLECT' 'ITEMREVERSE' 'ITEMROTATE' 'IDKEYS' 'INDICESOF' 'INPUTMASK' 'INSIDEBOUNDARY' 'INTERSECT' 'JOBABORT' 'JOBCREATE' 'JOBINFO' 'JOBLOG' 'JOBPRIORITY' 'JOBSTART' 'JOBSUSPEND' 'JOIN' 'JOBID' 'KEYSTRUCT' 'KEYCE' 'KEYMARK' 'LACL' 'LASTCOORD' 'LAYER' 'LAYERTYPE' 'LEVEL' 'LISTATTR' 'LISTDISPLAY' 'LISTGEN' 'LISTLIB' 'LISTREF1' 'LISTREF2' 'LOAD' 'LOCALTOGLOBAL' 'LOG' 'LOWERCASE' 'LSTAT' 'LAYERSIN' 'LINEINTERSECT' 'MAG' 'MARK' 'MARKSIZE' 'MASKFREE' 'MASKS' 'MASKSAVE' 'MEMORY' 'MENU' 'MENUMOVE' 'MERGELIB' 'MOVE' 'MOVEPOINT' 'MASKRESTORE' 'MEMBER' 'MINMAX' 'MSELECT' 'NAMES' 'NEWANGLE' 'NEWBOXTYPE' 'NEWDATATYPE' 'NEWFONT' 'NEWLAYER' 'NEWMAG' 'NEWNODETYPE' 'NEWPATHTYPE' 'NEWTEXTTYPE' 'NEWUNITS' 'NEWWIDTH' 'NODE' 'NODETYPE' 'NAMESBOUND' 'NAMESOPEN' 'NSELECT' 'OCTAGONAL' 'ODATA' 'ONAME' 'OPENDISPLAY' 'OPENLIB' 'OPENREF1' 'OPENREF2' 'OPTIONS' 'OREF' 'ORTHINT' 'OSTRUCT' 'OUTFORM' 'OUTFORM3' 'OUTPUTCHANGE' 'OUTPUTMASK' 'OUTPUTPATH' 'OUTPUTVIEW' 'OR' 'PAN' 'PATH' 'PATHEDGE' 'PATHMARK' 'PATHTYPE' 'PAUSE' 'PLEXMODE' 'PLOTSTAT' 'PROPVALUE' 'PUT' 'PUTALL' 'PATHBOUNDARY' 'PLEX' 'POLAR' 'PUTEL' 'QUIT' 'R3' 'RACL' 'RCSTRUCT' 'RECOVERLIB' 'REDO' 'REDRAW' 'REFL' 'REMOVE' 'REVERT' 'RJOB' 'RMENU' 'RS' 'RSCALE' 'RSCREEN' 'RSTRUCT' 'RT' 'RTDIGMODE' 'RULER' 'ROUND' 'ROUNDMASK' 'SAVE' 'SAVEDISPLAY' 'SB' 'SBTYPE' 'SBTYPEOFF' 'SBTYPEON' 'SCELL' 'SDTYPE' 'SDTYPEOFF' 'SDTYPEON' 'SEGS' 'SETCOLORS' 'SETDIG' 'SETLEVEL' 'SETTAB' 'SETVIEW' 'SHOWDEFAULTS' 'SHOWREFS' 'SHOWSNAPS' 'SKIND' 'SKINDOFF' 'SKINDON' 'SLAYER' 'SLAYEROFF' 'SLAYERON' 'SLIMSIZE' 'SNAME' 'SNAP' 'SNAPCE' 'SNAPSIZE' 'SNTYPE' 'SNTYPEOFF' 'SNTYPEON' 'SOLID' 'SPLIT' 'SPOOLQ' 'SREF' 'SREFMARK' 'SSTAT' 'SSTRUCT' 'STADPY' 'START' 'STRAIGHT' 'STREAMOUT' 'STRETCH' 'STRETCHCELL' 'STTYPE' 'STTYPEOFF' 'STTYPEON' 'STYLEBY' 'SUBRT' 'SUBS' 'SUMMARY' 'SYSDPY' 'SYSTAT' 'SLEEP' 'STADPYINFO' 'STANUM' 'STRUCINFO' 'STRUCLIST' 'STRUCOPEN' 'STRUCREFS' 'SUBSET' 'SYSN' 'TABMODE' 'TEMPLATE' 'TEMPLATEMARK' 'TEMPREF1' 'TEMPREF2' 'TEXT' 'TEXTFONT' 'TEXTMARK' 'TEXTTYPE' 'TIME' 'TJUST' 'TREE' 'TSTRUCT' 'TABTYPE' 'TEXTINPUT' 'TOD' 'UNDO' 'UNGET' 'UNID' 'UNIDWINDOW' 'UNMARK' 'UPDISPLAY' 'UPLIB' 'UPLOWCASE' 'UPPERCASE' 'USER' 'USERPROP' 'USTRUCT' 'UNDERSIZE' 'UNION' 'USELECT' 'VBTYPE' 'VBTYPEOFF' 'VBTYPEON' 'VDTYPE' 'VDTYPEOFF' 'VDTYPEON' 'VECTORCOUNT' 'VERTFIRST' 'VIEWEXTENT' 'VIEWMOVE' 'VKIND' 'VKINDOFF' 'VKINDON' 'VLAYER' 'VLAYEROFF' 'VLAYERON' 'VLEVELS' 'VLT' 'VMODE' 'VNTYPE' 'VNTYPEOFF' 'VNTYPEON' 'VSTRUCT' 'VTTYPE' 'VTTYPEOFF' 'VTTYPEON' 'VARS' 'VIEWWINDOW' 'WIDTH' 'WINCOPY' 'WINDELETE' 'WINFENCE' 'WINMOVE' 'WINOPTIONS' 'WINSTRETCH' 'WINSTRUCT' 'WIPE' 'WIPEALL' 'WITEM' 'WSCALE' 'WSCREEN' 'WASTAT' 'XSCALE' 'XOR' 'YSCALE' 'ZOOM' 'ZSCALE')
]

{ #category : 'specs' }
GplToken class >> lookupReservedKeywords [
	"GplToken reservedKeywords"

	^ self methodUnitKeywords , self methodTypeKeywords
		, self flowControlKeywords , self dataTypeKeywords
		, self storageScopeKeywords
]

{ #category : 'specs' }
GplToken class >> methodKindKeywords [
	^ #('PROCEDURE' 'FUNCTION')
]

{ #category : 'specs' }
GplToken class >> methodTypeKeywords [
	^ #('NILADIC' 'MONADIC' 'DYADIC')
]

{ #category : 'specs' }
GplToken class >> methodUnitKeywords [
	^ self methodKindKeywords , #('ENDSUB')
]

{ #category : 'instance creation' }
GplToken class >> newFromTokens: aGplTokens [
	| newToken |
	GplScanner assertGplTokens: aGplTokens.
	self assert: [ aGplTokens isEmpty not ].
	aGplTokens size = 1
		ifTrue: [ ^ aGplTokens first ].	"is a scalar"
	newToken := self new.
	aGplTokens do: [ :each | newToken addSubToken: each ].
	^ newToken
]

{ #category : 'specs' }
GplToken class >> programOnlyKeywords [
	^ (self reservedKeywords , #('RANGE')
		reject: [ :word | #('LOCAL' 'GLOBAL') includes: word ]) asArray
]

{ #category : 'specs' }
GplToken class >> reservedKeywords [
	^ ReservedKeywords
		ifNil: [ ReservedKeywords := self lookupReservedKeywords asSet ]
]

{ #category : 'instance creation' }
GplToken class >> start: s end: e type: aSymbol parser: aGplParser2 [
	^ self new
		start: s end: e type: aSymbol;
		parser: aGplParser2;
		yourself
]

{ #category : 'specs' }
GplToken class >> storageScopeKeywords [
	^ #('EXTERNAL' 'LOCAL' 'GLOBAL')
]

{ #category : 'accessing' }
GplToken >> addSubToken: aGplToken [
	subtokens ifNil: [ subtokens := OrderedCollection new ].
	subtokens add: aGplToken.
	parser ifNil: [ parser := aGplToken parser ].
	type ifNil: [ self type: #vector ]
]

{ #category : 'accessing' }
GplToken >> argumentType: aSymbol [
	self assert: (#(monadic niladic dyadic) includes: aSymbol).
	argumentType := aSymbol
]

{ #category : 'conversion' }
GplToken >> asAtomicToken [
	^ GplAtomicToken new
		start: start;
		end: end;
		type: type;
		parser: parser;
		yourself
]

{ #category : 'conversion' }
GplToken >> asGplValue [
	| clazz |
	self isNull
		ifTrue: [ ^ GdsNull instance ].
	self isString
		ifTrue: [ ^ GdsString fromLiteral: self fragment ].
	self isOperator
		ifTrue: [ ^ self fragment asLowercase asSymbol ].
	clazz := GdsDglType bestClassOfStatement: self fragment.
	clazz ifNotNil: [ ^ clazz fromLiteral: self fragment ].
	self type = #vector
		ifTrue: [ ^ GdsVector withAll: (subtokens collect: [ :t | t asGplValue ]) ].
	^ self
]

{ #category : 'accessing' }
GplToken >> depth [
	^ self depthOfParlen + self depthOfSubscript
]

{ #category : 'accessing' }
GplToken >> depthOfOpen: openFragment close: closeFragment [
	| allTokens level |
	allTokens := self parser tokens.
	level := 0.
	allTokens
		do: [ :each | 
			each fragment = openFragment
				ifTrue: [ level := level + 1.
					each = self
						ifTrue: [ ^ level ] ].
			each fragment = closeFragment
				ifTrue: [ each = self
						ifTrue: [ ^ level ].
					level := level - 1 ].
			each = self
				ifTrue: [ ^ level ] ].
	^ 0
]

{ #category : 'accessing' }
GplToken >> depthOfParlen [
	^ self depthOfOpen: '(' close: ')'
]

{ #category : 'accessing' }
GplToken >> depthOfSubscript [
	^ self depthOfOpen: '[' close: ']'
]

{ #category : 'accessing' }
GplToken >> end [
	self hasSubTokens
		ifTrue: [ ^ (subtokens collect: [ :token | token end ]) max ].
	^ end
]

{ #category : 'conversion' }
GplToken >> extractNegativeNumber [
	"[-5] -> [-][5]"

	| operatorToken numberToken |
	self isNegativeNumber
		ifFalse: [ ^ #() copy ].
	operatorToken := GplToken new
		type: #operator;
		start: self start;
		end: self start;
		parser: self parser;
		yourself.
	numberToken := GplToken new
		type: #number;
		start: self start + 1;
		end: self end;
		parser: self parser;
		yourself.
	^ Array with: operatorToken with: numberToken
]

{ #category : 'accessing' }
GplToken >> fragmentForInspect [
	| base |
	base := self fragment.
	"(base = ':=')
		ifTrue: [
			| leftTokens subScriptClose|
			leftTokens := self leftTokens.
			subScriptClose := leftTokens detect: [:each | each fragment = ']'] ifNone:[nil].
			subScriptClose ifNotNil: [base := '[]:='].
			]."
	argumentType
		ifNotNil: [ base := base , ' (' , argumentType asString , ')' ].
	^ base
]

{ #category : 'accessing' }
GplToken >> fragmentForTest [
	^ self fragment asUppercase
]

{ #category : 'testing' }
GplToken >> hasSubTokens [
	subtokens ifNil: [ ^ false ].
	^ subtokens isEmpty not
]

{ #category : 'private' }
GplToken >> index [
	^ index ifNil: [ index := self lookupIndex ]
]

{ #category : 'initialization' }
GplToken >> initialize [
	super initialize
]

{ #category : 'testing' }
GplToken >> isArithmeticOperator [
	(#('POWER') includes: self fragmentForTest)
		ifTrue: [ ^ true ].
	^ self fragment size = 1
		and: [ '+-*%' includes: self fragment first ]
]

{ #category : 'testing' }
GplToken >> isBreakNegativeNumber [
	#variable = self type
		ifTrue: [ ^ true ].
	#unresolved = self type
		ifTrue: [ ^ true ].
	')' = self fragment
		ifTrue: [ ^ true ].
	']' = self fragment
		ifTrue: [ ^ true ].
	^ false
]

{ #category : 'testing' }
GplToken >> isBuiltinDyadic [
	^ (self type = #operator or: [ self type = #builtinMethod ])
		and: [ self class implementedDyadicMethods
				includes: self fragment asUppercase ]
]

{ #category : 'testing' }
GplToken >> isBuiltinMonadic [
	^ (self type = #operator or: [ self type = #builtinMethod ])
		and: [ self class implementedMonadicMethods
				includes: self fragment asUppercase ]
]

{ #category : 'testing' }
GplToken >> isComment [
	^ self type = #comment
]

{ #category : 'testing' }
GplToken >> isFunctionCall [
	^ self isProcedureCall not
]

{ #category : 'testing' }
GplToken >> isInspectMonadic [
	^ (self type = #operator or: [ self type = #builtinMethod ])
		and:
			[ self class inspectMonadicMethods includes: self fragment asUppercase ]
]

{ #category : 'testing' }
GplToken >> isNegativeNumber [
	^ self isNumber and: [ self fragment beginsWith: '-' ]
]

{ #category : 'testing' }
GplToken >> isNull [
	^ self isString and: [ self fragment = '""' ]
]

{ #category : 'testing' }
GplToken >> isNumber [
	^ self type = #number
]

{ #category : 'testing' }
GplToken >> isOperator [
	^ self type = #operator
]

{ #category : 'testing' }
GplToken >> isProcedureCall [
	^ self leftTokens isEmpty
]

{ #category : 'testing' }
GplToken >> isSpace [
	^ self type = #space
]

{ #category : 'testing' }
GplToken >> isString [
	^ self type = #string
]

{ #category : 'testing' }
GplToken >> isVariableAllowed [
	^ self type = #unresolved or: [ self type = #variable ]
]

{ #category : 'accessing' }
GplToken >> leftFragment [
	self start = 1
		ifTrue: [ ^ '' ].
	^ parser source copyFrom: 1 to: self start - 1
]

{ #category : 'accessing' }
GplToken >> leftTokens [
	^ GplScanner tokensFrom: self leftFragment
]

{ #category : 'accessing' }
GplToken >> leftTokensOfDepth: aDepth [
	^ self leftTokens select: [ :each | each depth = aDepth ]
]

{ #category : 'accessing' }
GplToken >> leftTokensOfSameDepth [
	^ self leftTokensOfDepth: self depth
]

{ #category : 'private' }
GplToken >> lookupIndex [
	parser ifNil: [ ^ 0 ].
	^ parser ranges indexOf: self
]

{ #category : 'private' }
GplToken >> lookupType [
	| s |
	s := self fragment.
	(#('0' '1' 'TRUE' 'FALSE') includes: s)
		ifTrue: [ ^ #number ].
	(s beginsWith: '|')
		ifTrue: [ ^ #comment ].
	(s beginsWith: '"')
		ifTrue: [ ^ #string ].
	('()' includes: s first)
		ifTrue: [ ^ #paren ].
	('[]' includes: s first)
		ifTrue: [ ^ #bracket ].
	',' = s
		ifTrue: [ ^ #operator ].
	';' = s
		ifTrue: [ ^ #operator ].
	':' = s
		ifTrue: [ ^ #labelTerminator ].	"just colon only "
	$: = s last
		ifTrue: [ ^ #label ].
	((s beginsWith: '`') and: [ s endsWith: '''' ])
		ifTrue: [ ^ #comment ].
	(s
		allSatisfy: [ :each | 
			{Character space.
			Character tab} includes: each ])
		ifTrue: [ ^ #space ].
	(GplScanner isOperatorFragment: s)
		ifTrue: [ ^ #operator ].
	(self class isReservedKeyword: s)
		ifTrue: [ ^ #reserved ].
	(self class isBuiltinMethod: s)
		ifTrue: [ ^ #builtinMethod ].
	(self class isGdsiiMethod: s)
		ifTrue: [ ^ #gdsiiMethod ].
	(GplScanner isNumberFragment: s)
		ifTrue: [ ^ #number ].
	^ #unresolved
]

{ #category : 'accessing' }
GplToken >> postfixExpr [
	self fragment = '['
		ifTrue: [ ^ '[]' ].
	^ self fragmentForInspect
]

{ #category : 'accessing' }
GplToken >> rightFragment [
	self end = parser source size
		ifTrue: [ ^ '' ].
	^ parser source copyFrom: self end + 1 to: parser source size
]

{ #category : 'accessing' }
GplToken >> rightTokens [
	| newTokens |
	newTokens := GplScanner tokensFrom: self rightFragment.
	newTokens
		do: [ :each | 
			each parser: self parser.
			each start: self end + each start.
			each end: self end + each end ].
	^ newTokens
]

{ #category : 'accessing' }
GplToken >> rightTokensOfDepth: aDepth [
	^ self rightTokens select: [ :each | each depth = aDepth ]
]

{ #category : 'accessing' }
GplToken >> rightTokensOfSameDepth [
	^ self rightTokensOfDepth: self depth
]

{ #category : 'accessing' }
GplToken >> start [
	self hasSubTokens
		ifTrue: [ ^ (subtokens collect: [ :token | token start ]) min ].
	^ start
]

{ #category : 'accessing' }
GplToken >> type [
	type = #unresolved
		ifTrue: [ self type: self lookupType ].
	^ type
]
