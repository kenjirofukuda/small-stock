"
A GdsStructure is holdes collection of GdsElement.

element member of GdsLibrary.

Instance Variables
	colElements:		<Array<GdsElement>>
	dataExtentForElements:		<Rectangle<Float>>>
	database:		<GdsLibrary>
	dirtyElements:		<Array<GdsElement>>
	dirtyReservedArea:		<Array<GdsElement>>
	maxKeyNumber:		<Integer>
	name:		<String>
	savedName:		<String>
	storagePath:		<String>
	timeCreated:		<DateAndTime>
	timeModified:		<DateAndTime>

colElements
	- xxxxx

dataExtentForElements
	- xxxxx

database
	- xxxxx

dirtyElements
	- xxxxx

dirtyReservedArea
	- xxxxx

maxKeyNumber
	- xxxxx

name
	- xxxxx

savedName
	- xxxxx

storagePath
	- xxxxx

timeCreated
	- xxxxx

timeModified
	- xxxxx

"
Class {
	#name : #GdsStructure,
	#superclass : #GdsModel,
	#traits : 'TGdsExchange',
	#classTraits : 'TGdsExchange classTrait',
	#instVars : [
		'name',
		'dataExtentForElements',
		'timeModified',
		'timeCreated',
		'dirtyReservedArea',
		'dirtyElements',
		'maxKeyNumber',
		'layers',
		'elements',
		'library',
		'idContext',
		'item',
		'referencedStructures',
		'savedName'
	],
	#category : #'GdsFeel-Model-Container'
}

{ #category : #accessing }
GdsStructure class >> dtd [
	^'
<!DOCTYPE structure [
<!ELEMENT structure (element*)>
<!ELEMENT element (vertices,ashape*)>
<!ELEMENT ashape EMPTY>
<!ELEMENT vertices (xy+)>
<!ELEMENT xy (#PCDATA)>  
<!-- {xy}34.5 27.8{/xy} separator character is one space between x to y --> 

<!ATTLIST structure name CDATA #REQUIRED>
<!ATTLIST structure created CDATA #REQUIRED>  <!-- iso8601 -->
<!ATTLIST structure modified CDATA #REQUIRED> <!-- iso8601 -->

<!ATTLIST element type CDATA #REQUIRED>       <!-- boundary path boxtext sref aref -->
<!ATTLIST element keyNumber CDATA #REQUIRED>  <!-- uniq integer value in structure. v > 0 -->
<!ATTLIST element dataType CDATA #IMPLIED>    <!-- integer value -->
<!ATTLIST element layerNumber CDATA #IMPLIED> <!-- 0 .. 63 if strict GDSII -->
<!ATTLIST element width CDATA #IMPLIED>       <!-- foat value -->

<!ATTLIST element sname CDATA #IMPLIED>
<!ATTLIST element angle CDATA #IMPLIED>       <!-- 0.0 .. 360.0 -->
<!ATTLIST element mag CDATA #IMPLIED>
<!ATTLIST element reflected CDATA #IMPLIED>

<!ATTLIST ashape rows CDATA #IMPLIED>
<!ATTLIST ashape cols CDATA #IMPLIED>
<!ATTLIST ashape row-spacing CDATA #IMPLIED>
<!ATTLIST ashape column-spacing CDATA #IMPLIED>
]>'
]

{ #category : #accessing }
GdsStructure class >> dtd2 [
	^'
<!DOCTYPE structure [
<!ELEMENT structure (element*,property-set1*)>
<!ELEMENT element (vertices,ashape*,property-set1*)>
<!ELEMENT ashape EMPTY>
<!ELEMENT property-set1 (property1+)>
<!ELEMENT property1 EMPTY>
<!ELEMENT vertices (xy+)>
<!ELEMENT xy (#PCDATA)>  
<!-- {xy}34.5 27.8{/xy} separator character is one space between x to y --> 

<!ATTLIST structure name CDATA #REQUIRED>
<!ATTLIST structure created CDATA #REQUIRED>  <!-- iso8601 -->
<!ATTLIST structure modified CDATA #REQUIRED> <!-- iso8601 -->

<!ATTLIST element type CDATA #REQUIRED>       <!-- boundary path boxtext sref aref -->
<!ATTLIST element keyNumber CDATA #REQUIRED>  <!-- uniq integer value in structure. v > 0 -->
<!ATTLIST element dataType CDATA #IMPLIED>    <!-- integer value -->
<!ATTLIST element layerNumber CDATA #IMPLIED> <!-- 0 .. 63 if strict GDSII -->
<!ATTLIST element width CDATA #IMPLIED>       <!-- foat value -->

<!ATTLIST element sname CDATA #IMPLIED>
<!ATTLIST element angle CDATA #IMPLIED>
<!ATTLIST element mag CDATA #IMPLIED>
<!ATTLIST element reflected CDATA #IMPLIED>

<!ATTLIST ashape rows CDATA #IMPLIED>
<!ATTLIST ashape cols CDATA #IMPLIED>
<!ATTLIST ashape row-spacing CDATA #IMPLIED>
<!ATTLIST ashape column-spacing CDATA #IMPLIED>

<!ATTLIST property1 key CDATA #REQUIRED>
<!ATTLIST property1 value CDATA #REQUIRED>

]>'
]

{ #category : #'instance creation' }
GdsStructure class >> fromLibrary: aGdsLibrary structureNamed: aString [
	^(self basicNew initialize)
		library: aGdsLibrary;
		name: aString;
		yourself.
]

{ #category : #'as yet unclassified' }
GdsStructure class >> keyNumberForInStructure [
	^1
]

{ #category : #'instance creation' }
GdsStructure class >> new [ 
	^self error: 'cann''t instanciate. create only GdsLibrary'
]

{ #category : #accessing }
GdsStructure class >> safeNoElementDataExtent [
	^(-100 @ -100) corner: (100 @ 100)
]

{ #category : #accessing }
GdsStructure >> addElement: aGdsElement [
	self addElement: aGdsElement keyNumberFill: aGdsElement keyNumberFilled not.
]

{ #category : #accessing }
GdsStructure >> addElement: aGdsElement keyNumberFill: aBoolean [
	"| refLayer |"
	"colElements add: aGdsElement."
	elements ifNil: [ elements := Array new ].
	elements := elements copyWith: aGdsElement.
	dataExtentForElements := nil.
	aGdsElement structure: self.

	aBoolean
		ifTrue: [aGdsElement keyNumber: self nextKeyNumber].
		
	"aGdsElement hasLayer
		ifTrue: [
			refLayer := layers atNumber: aGdsElement layerNumber.
			]."
	
]

{ #category : #initialization }
GdsStructure >> allDispose [
	self class allInstVarNames  do: [ :each |
		self instVarNamed: each put: nil.
		 ]

	
]

{ #category : #printing }
GdsStructure >> attributesOn: aDictionary [
	aDictionary at: 'name' put: self name.
	aDictionary at: 'created' put: self timeCreated printString.
	aDictionary at: 'modified' put: self timeModified printString.
	
]

{ #category : #updating }
GdsStructure >> changedIdGroup [
	self updateIdState.
	self changed: #tstructEnabled.			
	self changed: #unIdEnabled.
	self changed: #idClearEnabled.			
	self changed: #idDeleteEnabled.			
	self changed: #idNotEmpty.			

]

{ #category : #accessing }
GdsStructure >> children [
	^ self elements
]

{ #category : #'as yet unclassified' }
GdsStructure >> clearCache [
	referencedStructures := nil.
]

{ #category : #debug }
GdsStructure >> clonedElements: elementCollection appendOn: aOrderedCollection fromToBlock: aBlock [
	elementCollection
		do: [ :each | 
			| cloned |
			cloned := each copy.
			cloned instVarNamed: 'keyNumber' put: nil.
			aBlock value: each value: cloned.
			aOrderedCollection add: cloned ]
]

{ #category : #'objects from disk' }
GdsStructure >> closeDiscard [
	self closeSaving: false.
]

{ #category : #testing }
GdsStructure >> closeEnabled [
	^ self currentItem putEnabled not and: [ self idSelection isEmpty ]
]

{ #category : #'objects from disk' }
GdsStructure >> closeSaving: aBoolean [
	| announcement |
	aBoolean ifTrue: [self save].
	self privateClose.
	announcement := (GdsStructureClosed new) 
		structure: self;
		library: self library;
		yourself.
	self announcer announce: announcement.
	self library announcer announce: announcement.	
	GdsStation default announcer announce: announcement.
]

{ #category : #'objects from disk' }
GdsStructure >> closeWithSave [
	self closeSaving: true.
]

{ #category : #private }
GdsStructure >> comitDirty [
	|element |
	element := self popDirtyReservedArea.
	element 
		ifNotNil: [
			dirtyElements ifNil: [dirtyElements := OrderedCollection new].
			dirtyElements add: element].
	self changed: #dirty.		
]

{ #category : #'as yet unclassified' }
GdsStructure >> copyName [
	^ self name, '_COPY'
]

{ #category : #copying }
GdsStructure >> copyNamed: aNewName [
	| newInstance announcement |
	newInstance := self copy.
	newInstance removeAllElements.
	self elements do: [ :e | newInstance addElement: e copy. ].
	newInstance idSelection idClear.
	newInstance currentItem holdsElement ifTrue: [newInstance currentItem unget].	
	newInstance privateName: aNewName.
	self library addStructure: newInstance.
	newInstance forceSave.
	announcement := GdsStructureDuplicated new
				structure: newInstance;
				sourceStructure: self;
				yourself.
	self announcer announce: announcement.
	self library announcer announce: announcement.	
	GdsStation default announcer announce: announcement.
	^ newInstance
]

{ #category : #'edit chanel' }
GdsStructure >> currentItem [
	^ item
	
]

{ #category : #accessing }
GdsStructure >> dataExtentForElements [
	dataExtentForElements ifNil: [dataExtentForElements := self lookupDataExtentForElements ].
	^dataExtentForElements.
]

{ #category : #accessing }
GdsStructure >> dataExtentForFittingView [
	self elements isEmpty 
		ifTrue: [^self safeNoElementDataExtent.].
	^self dataExtentForElements.
]

{ #category : #accessing }
GdsStructure >> dataExtentForIdElements [
	| bBox |
	bBox := GeometryUtils minusBounds.
	self idSelection elements do: [ :e | bBox := bBox quickMerge: e dataBounds  ].
	^ bBox
]

{ #category : #'accessing - analisys' }
GdsStructure >> directReferenceElements [
	^ self  elements select: [:e | e isReference ].
]

{ #category : #accessing }
GdsStructure >> dirty [
	self removedElements ifNotEmpty: [^true].
	dirtyElements ifNil: [^false].
	^dirtyElements notEmpty.

]

{ #category : #copying }
GdsStructure >> duplicate [
	^ self copyNamed: self uniqCopyName.

]

{ #category : #accessing }
GdsStructure >> elements [
	elements 
		ifNil: [
			self library file isFile
				ifTrue: [
					self load ] ]. 			 
	^ elements
		ifNil: [ #() ]
		ifNotNil: [ elements ].
]

{ #category : #'accessing - resource' }
GdsStructure >> extractDirectory [
	^ library extractDirectory / self nameWithExtension
]

{ #category : #'accessing - resource' }
GdsStructure >> fileNameRevision: anInteger [
	^{self name . anInteger asString . 'gdsfeelbeta'}
		joinUsing: '.'
]

{ #category : #'objects from disk' }
GdsStructure >> filePattern [
	^(self name, '.*', '.gdsfeelbeta').

]

{ #category : #example }
GdsStructure >> fillExampleInstance [
	self currentItem boundary.
	self currentItem layerNumber: 1.
	self currentItem ce: 0@0.
	self currentItem ce: 0@100.
	self currentItem ce: 0@100.
	self currentItem ce: 0@100.
	self currentItem ce: 0@100.
	self currentItem ce: 100@100.
	self currentItem ce: 100@0.
	self currentItem put.
	self currentItem path.
	self currentItem layerNumber: 3.
	self currentItem ce: 0@0.
	self currentItem ce: 0@100.
	self currentItem ce: 100@100.
	self currentItem ce: 100@0.
	self currentItem translate: 20@30.
	self currentItem put.

]

{ #category : #debug }
GdsStructure >> findNearestElementByPoint: aPoint [
	^self findNearestElementByPoint: aPoint elements: self liveElements. 
]

{ #category : #debug }
GdsStructure >> findNearestElementByPoint: aPoint elements: filteredElements [
	^ (self findNearestElementsByPoint: aPoint  elements: filteredElements) first.
]

{ #category : #debug }
GdsStructure >> findNearestElementsByPoint: aPoint elements: filteredElements [
	| distanceOrderElements insideElements |
	filteredElements
		ifEmpty: [^nil].
	filteredElements size = 1
		ifTrue: [ ^ filteredElements ].
	insideElements := #().
	"insideElements := filteredElements
		select: [:each  | each findBounds containsPoint: aPoint ]."	
	insideElements ifEmpty: [insideElements := filteredElements].	
	distanceOrderElements := insideElements
		sort: [:a :b | (a dist: aPoint) < (b dist: aPoint)].
	^ distanceOrderElements.
]

{ #category : #private }
GdsStructure >> flushDirtyInfo [
	dirtyReservedArea := nil.
	dirtyElements := nil.
]

{ #category : #'objects from disk' }
GdsStructure >> forceSave [
	self save: true.

]

{ #category : #debug }
GdsStructure >> idCopyOffset: aPoint [
	| newElements |
	newElements := OrderedCollection new.
	self 
		clonedElements: self idSelection elements 
		appendOn: newElements 
		fromToBlock: [:from :to |
			to moveRelative: aPoint from: from.].
	self idSelection idClear.
	newElements do: [:each |
		self addElement: each.
		self idSelection idAdd: each keyNumber.
		self pushDirtyReservedArea: each.].
	self comitDirty.
	
	
]

{ #category : #debug }
GdsStructure >> idDelete [
	| targets |
	targets := self idSelection elements copy.
	targets do: [ :each | 
			self pushDirtyReservedArea: each.
			"each wipe" ].
	self removeElements: targets
]

{ #category : #'as yet unclassified' }
GdsStructure >> idExplode [
	(self idSelection elements select: [ :e | e explodable ])
		do: [ :each | 
			(each refStructure elements collect: [ :e | e copy ])
				do: [ :eachCopied |
					eachCopied removeKeyNumber. 
					eachCopied moveRelative: each strans offset.
					self addElement: eachCopied ] ].
	self idDelete
]

{ #category : #debug }
GdsStructure >> idMoveOffset: aPoint [
	self idSelection elements do: [:each | 
		each moveRelative: aPoint.
		self pushDirtyReservedArea: each].
	dataExtentForElements := nil.
	self comitDirty.
	
	
]

{ #category : #'as yet unclassified' }
GdsStructure >> idSelectWithBlock: aElementBlock [
	(self elements select: aElementBlock)
		do: [ :e | self idSelection idAdd: e keyNumber ]
]

{ #category : #'edit chanel' }
GdsStructure >> idSelection [
	^ idContext
]

{ #category : #'as yet unclassified' }
GdsStructure >> idStructureNamed: aStructureName origin: aOriginPoint [
	| s newElements|
	self idSelection isEmpty ifTrue: [ ^ self ].
	s := self library newStructureNamed: aStructureName.
	newElements := OrderedCollection new.
	self 
		clonedElements: self idSelection elements 
		appendOn: newElements 
		fromToBlock: [:from :to |
			to moveRelative: aOriginPoint negated from: from.			
			s addElement: to ].
	newElements do: [ :e | e statusNumber: GdsElement inDatabaseStausNumber ].
	s forceSave.
	
]

{ #category : #'accessing - analisys' }
GdsStructure >> indirectReferencedStructureNames [
	^self indirectReferencedStructures collect: [:each | each name]	 
]

{ #category : #'accessing - analisys' }
GdsStructure >> indirectReferencedStructures [
	| refs set |
	set := Set new.
	refs := self referencedStructures.
	set addAll: refs.
	[refs isEmpty]
		whileFalse: [
			refs 
				do: [:each |
					refs := each indirectReferencedStructures.
					set addAll: refs]].
	^set asArray.
		
	 
]

{ #category : #initialization }
GdsStructure >> initialize [
	| time |
	super initialize.	
	time := DateAndTime now.
	timeCreated := time copy.
	timeModified := time copy.
	"colElements := OrderedCollection new."
	elements := nil.
	maxKeyNumber := nil.
	layers := GdsLayers new.
	idContext := GdsIdContext new.
	idContext structure: self.
	item := (GdsItemContext newWithNumber: 0) structure: self; yourself.
	
]

{ #category : #initialization }
GdsStructure >> initializeEditContext [
	idContext := GdsIdContext new.
	idContext structure: self.
	item := (GdsItemContext newWithNumber: 0) structure: self; yourself.
	dirtyElements := nil.
	dirtyReservedArea := nil.
	
]

{ #category : #testing }
GdsStructure >> isLeaf [
	^(self elements detect: [ :e | e isReference ] ifNone: [  ])
		isNil
]

{ #category : #testing }
GdsStructure >> isOpen [
	^library isOpen
]

{ #category : #testing }
GdsStructure >> isTransient [
	^ library isTransient
]

{ #category : #'edit chanel' }
GdsStructure >> items [
	library ifNil:[^nil].
	library station ifNil:[^nil].
	^library station items.
]

{ #category : #'xml/json data exchange' }
GdsStructure >> jsonElementsOn: aDictionary [
	aDictionary at: 'elements' put: self elements.
	
]

{ #category : #accessing }
GdsStructure >> kinds [
	self library ifNil: [^nil].
	^self library kinds
]

{ #category : #accessing }
GdsStructure >> labelString [
	^String streamContents: [:s |
		self dirty ifTrue: [s nextPutAll: '* '].
		s nextPutAll: self name].
]

{ #category : #printing }
GdsStructure >> latestContents [
	self isOpen
		ifTrue: [ ^self latestFile readStream contents ]
		ifFalse: [ library zipArchiveDo: [ :zip | | s |
				s := (zip memberNamed: self latestZipMemberName) contentStreamFromEncoding: 'UTF-8'.
				s text.
				^s contents]]
]

{ #category : #accessing }
GdsStructure >> latestFile [
	self isOpen ifFalse: [ ^self error: 'illigal call. structure/library not open.' ].
	^self latestObject: self memberFiles getBasenameBlock: [ :f | f basename ]. 

]

{ #category : #private }
GdsStructure >> latestObject: aCollection getBasenameBlock: aBlock [
	^((aCollection 
		select: [ :obj | (self revisonOfName: (aBlock value: obj)) >= 0 ])
		sort: [ :obj1 :obj2 | 
				(self revisonOfName: (aBlock value: obj1))
			 < (self revisonOfName: (aBlock value: obj2)) ])
				last.
]

{ #category : #private }
GdsStructure >> latestZipMemberName [
	| dirPath |
	dirPath := self relativeDirectoryName , '/'.
	^self latestObject: self zipMemberNames getBasenameBlock: [ :zipMemberPath | 
		zipMemberPath allButFirst: dirPath size].
]

{ #category : #accessing }
GdsStructure >> layers [
	self libraryLayers ifNotNil: [ :it | ^ it ].
	^ self localLayers
]

{ #category : #initialization }
GdsStructure >> library [
	^ library

]

{ #category : #initialization }
GdsStructure >> library: aGdsLibrary [.
	library ifNotNil: [ self error: 'library already set. int this structure' ].
	library := aGdsLibrary.
	

]

{ #category : #accessing }
GdsStructure >> libraryLayers [
	library ifNil: [^nil].
	^library layers
]

{ #category : #accessing }
GdsStructure >> liveElements [
	^self elements reject: [:each | 
		each state = #inTrush or: [each damaged]].
]

{ #category : #'objects from disk' }
GdsStructure >> load [
			self storageFile isFile
				ifTrue: [
					GdsFeel
						xmlDocumentFile: self storageFile 
						documentBlock: [:doc | self loadFromXmlDocument: doc]].
]

{ #category : #'objects from disk' }
GdsStructure >> loadFromAttributes: aDictionary [
	| iso8601 tempName |
	
	iso8601 := (aDictionary at: 'created' ifAbsent: [self timeCreatedForStorage]) asString.
	iso8601
		ifNotNil: [timeCreated := DateAndTime fromString: iso8601].

	iso8601 := (aDictionary at: 'modified' ifAbsent: [self timeModifiedForStorage]) asString.
	iso8601
		ifNotNil: [timeModified := DateAndTime fromString: iso8601].
		
	tempName := aDictionary at: 'name' ifAbsent: [].
	tempName
		ifNotNil: [savedName := tempName].
	
]

{ #category : #'objects from disk' }
GdsStructure >> loadFromXmlDocument: aXMLDocument [
	| structureNode |
	structureNode := aXMLDocument findElementNamed: #structure.
	structureNode
		elementsDo: [ :node | 
			(GdsElement classForType: (node attributes at: 'type'))
				ifNotNil: [ :clazz | 
					| element success |
					success := true.
					element := clazz fromXmlNode: node.
					[ element fixGeometryError ]
						on: Error
						do: [ :ex | 
							success := false.
							ex traceCr.
							structureNode traceCr ].
					success
						ifTrue: [ self addElement: element ] ] ].
	self loadFromAttributes: structureNode attributes.
	self flushDirtyInfo
	"
	| doc contents |

	contents := String streamContents: [ :s |
		s << GdsStructure dtd.
		s << self sampleStructure latestContents].	
	doc := XMLDOMParser parse:  contents.
	createdString := ((XPath for: 'structure/@created') in: doc) first.
	modifiedString := ((XPath for: 'structure/@modified') in: doc) first.	
	elements := ((XPath for: 'structure/*') in: doc) collect: [:node | GdsElement2 fromXMLNode: node ]	
	"
]

{ #category : #accessing }
GdsStructure >> localLayers [
	^layers
]

{ #category : #private }
GdsStructure >> lookupDataExtentForElements [
	^ self lookupDataExtentForElementsChooserBlock: [:element | true]

]

{ #category : #private }
GdsStructure >> lookupDataExtentForElementsChooserBlock: aElementBlock [
	| bounds |
	bounds := GeometryUtils minusBounds.
	(self liveElements select: aElementBlock) do: [:e |
		bounds := bounds merge: e dataBounds.].
	^bounds
]

{ #category : #'key generator' }
GdsStructure >> lookupMaxKeyNumber [
	| filledElements | 
	filledElements := self elements select: [:each | each keyNumberFilled].
	filledElements 
		ifEmpty: [^0]
		ifNotEmpty: [^(filledElements collect: [:each | each keyNumber]) max].
]

{ #category : #'accessing - analisys' }
GdsStructure >> lookupReferencedStructures [
	^self library structures 
		select: [:each | each directReferenceElements anySatisfy: [:el | el structureName sameAs: self name] ]

]

{ #category : #private }
GdsStructure >> lookupUsingLayerNumbers [
	| numberSet |
	numberSet := (self elements 
		select: [:each | each hasLayer] 
		thenCollect: [:each | each layerNumber]) asSet.
	"Pharo: asSortedArray "
	^numberSet asArray sorted.
]

{ #category : #updating }
GdsStructure >> markDirty [
	self currentItem holdsElement 
		ifTrue: [self pushDirtyReservedArea: self currentItem editElement]
		ifFalse: [
			self liveElements ifNotEmpty: [
				self pushDirtyReservedArea: self liveElements last]].
	self changed: #dirty.
	
]

{ #category : #updating }
GdsStructure >> markDirtySelectors [
	^#(geometry wipe newElement layer layerNumber width pathtype angle mag sname)
]

{ #category : #accessing }
GdsStructure >> maxDepth [
	| walker maxDepth|
	walker := GdsStructureWalker new.
	maxDepth := 0.
	walker walk: self do: [ maxDepth := maxDepth max: walker depth ].
	^ maxDepth
]

{ #category : #'key generator' }
GdsStructure >> maxKeyNumber [
	maxKeyNumber ifNil: [maxKeyNumber := self lookupMaxKeyNumber].
	^maxKeyNumber
	
	
]

{ #category : #'accessing - resource' }
GdsStructure >> maxRevName [
	| revs files |
	self extractDirectory ensureCreateDirectory.
	files := self extractDirectory filesMatching: self filePattern.
	revs := files collect: [ :f | (f basename findTokens: '.') second asInteger].
	revs ifEmpty: [revs := Array with: 1].
	^self fileNameRevision: revs max.
]

{ #category : #private }
GdsStructure >> memberFiles [
	self isOpen ifFalse: [ ^self error: 'illigal call. library not extaracted.' ].
	^(library extractDirectory  / self relativeDirectoryName)
		files collect: [ :file | file ]. 
]

{ #category : #private }
GdsStructure >> memberMatcher: memberName [
	| m|
	m :=  '([^.]+)\.(\d+)\.(gdsfeelbeta)' asRegex .
	(m matches: memberName)
		ifTrue: [ ^m ].
	^nil. 
]

{ #category : #attribute }
GdsStructure >> name [
	^name.
]

{ #category : #initialization }
GdsStructure >> name: aStructureName [ 
	name ifNotNil: [ ^self error: 'structure name already set.' ].
	name := GdsCompatibility default coerceStructureName:  aStructureName.
	

]

{ #category : #attribute }
GdsStructure >> nameWithExtension [
	^self name, self newExtension 
]

{ #category : #attribute }
GdsStructure >> newExtension [
	^'.', self newExtensionBody
]

{ #category : #attribute }
GdsStructure >> newExtensionBody [
	^'structure'
]

{ #category : #'key generator' }
GdsStructure >> nextKeyNumber [
	| newValue |
	newValue := self maxKeyNumber + 1.
	maxKeyNumber := newValue.
	^newValue
	
]

{ #category : #private }
GdsStructure >> popDirtyReservedArea [
	dirtyReservedArea ifNil: [^nil].
	dirtyReservedArea ifNotEmpty: [^dirtyReservedArea removeLast].
	
]

{ #category : #copying }
GdsStructure >> postCopy [
	super postCopy.
	elements := elements collect: [ :e | e copy].
	layers := layers copy.
	savedName := nil.
	self initializeEditContext.
	
]

{ #category : #'accessing - resource' }
GdsStructure >> previewFile [
	^ self library sessionDirectory / self nameWithExtension / 'preview.png'
]

{ #category : #printing }
GdsStructure >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '('.
	aStream nextPutAll: self name.
	aStream nextPutAll: ')'.	
]

{ #category : #printing }
GdsStructure >> privateClose [
	"self items ifNotNil: [self items forgetStructure]."
	self idSelection ifNotNil: [self idSelection forgetStructure].
	dirtyElements := nil.
]

{ #category : #copying }
GdsStructure >> privateName: aName [
	name := aName.
	
]

{ #category : #private }
GdsStructure >> pushDirtyReservedArea: aGdsElement [
	"!!!NOTE!!!"
	"if this effect is active. then after must send #comitDirty."
	dirtyReservedArea ifNil: [dirtyReservedArea := OrderedCollection new].
	dirtyReservedArea add: aGdsElement.
	
]

{ #category : #'accessing - analisys' }
GdsStructure >> referenceEnabledStructureNames [
	| ignoreNames |
	ignoreNames := self indirectReferencedStructureNames.
	^ self  library structureNames 
		reject: [ :each | (each sameAs: self  name) or: [ignoreNames includes: each]]
]

{ #category : #'accessing - analisys' }
GdsStructure >> referencedStructureNames [
	^self referencedStructures collect: [:each | each name].
]

{ #category : #'accessing - analisys' }
GdsStructure >> referencedStructures [
	^ referencedStructures ifNil: [ referencedStructures := self lookupReferencedStructures ]
]

{ #category : #private }
GdsStructure >> relativeDirectoryName [
	"'SAMPLE.structure'"
	^String streamContents: [:s | s << self name; << '.structure']. 
]

{ #category : #initialization }
GdsStructure >> release [
	idContext := nil.
	item := nil.
	timeCreated := nil.
	timeModified := nil.
	"colElements ifNotNil: [ colElements do: [:each | each release]].
	colElements := nil."
	elements ifNotNil: [ elements do: [:each | each release]].
	elements := nil.
	maxKeyNumber := nil.
	layers release.
	layers := nil.
	name := nil.
	super release.

	
]

{ #category : #accessing }
GdsStructure >> removeAllElements [
	^ self removeElements: self elements.
]

{ #category : #accessing }
GdsStructure >> removeElement: aGdsElement [
	self removeElements: (Array with: aGdsElement).
]

{ #category : #accessing }
GdsStructure >> removeElements: aGdsElementCollection [
	| announcement|
	aGdsElementCollection ifEmpty: [ ^ self  ].
	announcement := GdsElementRemoved new elements: aGdsElementCollection.
	elements := elements copyWithoutAll: aGdsElementCollection.
	dataExtentForElements := nil.
	dirtyElements ifNotNil: [dirtyElements removeAllFoundIn: aGdsElementCollection ].
	self announcer announce: announcement.
	"self setDirty: true."
	
]

{ #category : #accessing }
GdsStructure >> removedElements [
	^self elements select: [:each | each state = #inTrush].
]

{ #category : #private }
GdsStructure >> revertDirty [
	self popDirtyReservedArea.
	self changed: #dirty.
]

{ #category : #private }
GdsStructure >> revisonOfName: memberName [
	| m|
	m := self memberMatcher: memberName.
	m ifNil: [ ^-1 ].
	m subexpressionCount < 4 ifTrue: [ ^-2 ].
	"((m subexpression: 1) sameAs: self name) ifFalse: [ ^-3 ]."
	^(m subexpression: 3) asInteger.	
]

{ #category : #accessing }
GdsStructure >> safeNoElementDataExtent [
	^self class safeNoElementDataExtent
]

{ #category : #'objects from disk' }
GdsStructure >> save [
	"now force save. but adhook bug fix."
	self save: true.

]

{ #category : #'objects from disk' }
GdsStructure >> save: aForceBoolean [
	self
		saveBlock: [ GdsFeel fileOutXmlTopElement: self asXmlElement toFile: self storageFile ]
		force: aForceBoolean
]

{ #category : #'objects from disk' }
GdsStructure >> saveBlock: aBlock [
	self saveBlock: aBlock force: false
]

{ #category : #'objects from disk' }
GdsStructure >> saveBlock: aBlock force: aBoolean [
	aBoolean
		ifFalse: [
			self dirty ifFalse: [^self]].
	timeModified := DateAndTime now.
	aBlock value.
	self flushDirtyInfo.
	"self setDirty: false.	"
]

{ #category : #'key generator' }
GdsStructure >> saveUsingSelector: savingSelector [
	self dirty ifFalse: [^self].
	timeModified := DateAndTime now.
	self perform: savingSelector.
	self flushDirtyInfo.
	"self setDirty: false.	"
]

{ #category : #'accessing - resource' }
GdsStructure >> storageFile [
	^ self extractDirectory  / self maxRevName

]

{ #category : #private }
GdsStructure >> strictMemberMatcher: memberName [
	| m|
	m :=  ('(', self name , '\.(\d+)\.(gdsfeelbeta)') asRegex .
	(m matches: memberName)
		ifTrue: [ ^m ].
	^nil. 
]

{ #category : #'accessing - analisys' }
GdsStructure >> subStructures [
	^ (self directReferenceElements collect: [ :e | e refStructure ]) asSet asArray
]

{ #category : #attribute }
GdsStructure >> timeCreated [
	timeCreated ifNil: [timeCreated := DateAndTime now].
	^timeCreated.
]

{ #category : #accessing }
GdsStructure >> timeCreatedForStorage [
	self storageFile isFile
		ifTrue: [ ^ DateAndTime fromSeconds: self storageFile creationTime ].
	^nil
	
]

{ #category : #attribute }
GdsStructure >> timeModified [
	timeModified ifNil: [timeModified := DateAndTime now].
	^timeModified.
]

{ #category : #accessing }
GdsStructure >> timeModifiedForStorage [
	self storageFile isFile
		ifTrue: [ ^ DateAndTime fromSeconds: self storageFile modificationTime ].
	^nil
	
]

{ #category : #'xml/json data exchange' }
GdsStructure >> topElementName [
	^'structure'

]

{ #category : #'as yet unclassified' }
GdsStructure >> uniqCopyName [
	| uniqName strucNames |
	strucNames := self library structureNames.
	uniqName := self name, '_COPY'.
	[strucNames includes: uniqName]
		whileTrue: [ uniqName := uniqName, '_COPY' ].
	^ uniqName.

]

{ #category : #updating }
GdsStructure >> update: anObject [.
	GdsFeel ifDebugOn: [:s |
		s nextPutAll:  self class printString.
		s nextPutAll: ' recieve: '.
		s nextPutAll: anObject printString.].
	(self markDirtySelectors includes: anObject)
		ifTrue: [
			self markDirty.
			dataExtentForElements := nil.
			self changed: #geometry.
			self changed].
	anObject == #geometry
		ifTrue: [
			dataExtentForElements := nil.
			self changed.].
	anObject == #unget
		ifTrue: [
			self revertDirty].
	({ #put . #wipe . #idDelete } includes: anObject)
		ifTrue: [
			self comitDirty.
			self changed: anObject].
	anObject == #get
		ifTrue: [self changed].
	"anObject == #id
		ifTrue: [
			self changedIdGroup.			
			self changed]."
	anObject == #tstructEnabled
		ifTrue: [self changed: #tstructEnabled].
	anObject == self currentItem
		ifTrue: [self changed: #geometry].		
	super update: anObject.
]

{ #category : #debug }
GdsStructure >> updateIdState [
	| idKeys colChangedElements|
	self idSelection ifNil: [^self].
	idKeys := self idSelection keyNumbers.
	colChangedElements := OrderedCollection new.
	(self liveElements reject: [:each | each state = #inItem])
		do: [:each | 
			(idKeys includes: each keyNumber)
				ifTrue: [
						each statusNumber ~= GdsElement inIdStausNumber
							ifTrue: [
								each statusNumber: GdsElement inIdStausNumber.
								colChangedElements add: each] ]
				ifFalse: [
						each statusNumber = GdsElement inIdStausNumber
							ifTrue: [
								each statusNumber: GdsElement inDatabaseStausNumber.
								colChangedElements add: each]]].
	self changed: colChangedElements asArray.
]

{ #category : #private }
GdsStructure >> usingLayerNumbers [
	^self lookupUsingLayerNumbers
]

{ #category : #'xml/json data exchange' }
GdsStructure >> xmlElementOn: aXmlElement [
	self liveElements do: [ :each | aXmlElement addNode: each asXmlElement ].

]

{ #category : #private }
GdsStructure >> zipMemberNames [
	library zipArchiveDo: [ :zip | 
		^zip memberNames select: [ :path |
			(path asLowercase beginsWith: self relativeDirectoryName asLowercase)
				and: [ path asLowercase endsWith: '.gdsfeelbeta' ]]].
	^#().
]
