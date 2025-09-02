Class {
	#name : #GdaStructure,
	#superclass : #GdaModel,
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
		'referencedStructures'
	],
	#category : #'GdsFeel-Model-Atomic'
}

{ #category : #accessing }
GdaStructure class >> dtd [

	^ '
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
GdaStructure class >> dtd2 [

	^ '
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
GdaStructure class >> fromLibrary: aGdsLibrary structureNamed: aString [

	^ self basicNew initialize
		  library: aGdsLibrary;
		  name: aString;
		  yourself
]

{ #category : #accessing }
GdaStructure class >> keyNumberForInStructure [

	^ 1
]

{ #category : #'instance creation' }
GdaStructure class >> new [

	^ self error: 'cann''t instanciate. create only GdsLibrary'
]

{ #category : #accessing }
GdaStructure class >> safeNoElementDataExtent [

	^ -100 @ -100 corner: 100 @ 100
]

{ #category : #accessing }
GdaStructure >> addElement: aGdsElement [

	self
		addElement: aGdsElement
		keyNumberFill: aGdsElement keyNumberFilled not
]

{ #category : #accessing }
GdaStructure >> addElement: aGdsElement keyNumberFill: aBoolean [

	"| refLayer |"

	"colElements add: aGdsElement."

	elements ifNil: [ elements := Array new ].
	elements := elements copyWith: aGdsElement.
	dataExtentForElements := nil.
	aGdsElement structure: self.

	aBoolean ifTrue: [ "aGdsElement hasLayer
		ifTrue: [
			refLayer := layers atNumber: aGdsElement layerNumber.
			]." 
		aGdsElement keyNumber: self nextKeyNumber ]
]

{ #category : #initialization }
GdaStructure >> allDispose [

	self class allInstVarNames do: [ :each | 
		self instVarNamed: each put: nil ]
]

{ #category : #printing }
GdaStructure >> attributesOn: aDictionary [

	aDictionary at: 'name' put: self name.
	aDictionary at: 'created' put: self timeCreated printString.
	aDictionary at: 'modified' put: self timeModified printString
]

{ #category : #accessing }
GdaStructure >> children [

	^ self elements
]

{ #category : #private }
GdaStructure >> clearCache [

	referencedStructures := nil
]

{ #category : #debug }
GdaStructure >> clonedElements: elementCollection appendOn: aOrderedCollection fromToBlock: aBlock [

	elementCollection do: [ :each | 
		| cloned |
		cloned := each copy.
		cloned instVarNamed: 'keyNumber' put: nil.
		aBlock value: each value: cloned.
		aOrderedCollection add: cloned ]
]

{ #category : #initialization }
GdaStructure >> coerceStructureName: aString [

	| partial |
	partial := aString copyReplaceAll: ' ' with: '_'.
	"FIXME"
	^ partial
]

{ #category : #private }
GdaStructure >> comitDirty [

	| element |
	element := self popDirtyReservedArea.
	element ifNotNil: [ 
		dirtyElements ifNil: [ dirtyElements := OrderedCollection new ].
		dirtyElements add: element ].
	self changed: #dirty
]

{ #category : #accessing }
GdaStructure >> copyName [

	^ self name , '_COPY'
]

{ #category : #copying }
GdaStructure >> copyNamed: aNewName [

	| newInstance |
	newInstance := self copy.
	newInstance removeAllElements.
	self elements do: [ :e | newInstance addElement: e copy ].
	newInstance idSelection idClear.
	newInstance currentItem holdsElement ifTrue: [ 
		newInstance currentItem unget ].
	newInstance privateName: aNewName.
	self library addStructure: newInstance.
	"newInstance forceSave.
	announcement := GdsStructureDuplicated new
		                structure: newInstance;
		                sourceStructure: self;
		                yourself.
	self announcer announce: announcement.
	self library announcer announce: announcement.
	GdsStation default announcer announce: announcement."
	^ newInstance
]

{ #category : #accessing }
GdaStructure >> dataExtentForElements [

	dataExtentForElements ifNil: [ 
		dataExtentForElements := self lookupDataExtentForElements ].
	^ dataExtentForElements
]

{ #category : #accessing }
GdaStructure >> dataExtentForFittingView [

	self elements isEmpty ifTrue: [ ^ self safeNoElementDataExtent ].
	^ self dataExtentForElements
]

{ #category : #'accessing - analisys' }
GdaStructure >> directReferenceElements [

	^ self elements select: [ :e | e isReference ]
]

{ #category : #accessing }
GdaStructure >> dirty [

	self removedElements ifNotEmpty: [ ^ true ].
	dirtyElements ifNil: [ ^ false ].
	^ dirtyElements notEmpty
]

{ #category : #copying }
GdaStructure >> duplicate [

	^ self copyNamed: self uniqCopyName
]

{ #category : #accessing }
GdaStructure >> elements [

	"elements ifNil: [ self library file isFile ifTrue: [ self load ] ]."

	^ elements ifNil: [ #(  ) ] ifNotNil: [ elements ]
]

{ #category : #debug }
GdaStructure >> findNearestElementByPoint: aPoint [

	^ self findNearestElementByPoint: aPoint elements: self liveElements
]

{ #category : #debug }
GdaStructure >> findNearestElementByPoint: aPoint elements: filteredElements [

	^ (self findNearestElementsByPoint: aPoint elements: filteredElements)
		  first
]

{ #category : #debug }
GdaStructure >> findNearestElementsByPoint: aPoint elements: filteredElements [

	| distanceOrderElements insideElements |
	filteredElements ifEmpty: [ ^ nil ].
	filteredElements size = 1 ifTrue: [ ^ filteredElements ].
	insideElements := #(  ).
	"insideElements := filteredElements
		select: [:each  | each findBounds containsPoint: aPoint ]."
	insideElements ifEmpty: [ insideElements := filteredElements ].
	distanceOrderElements := insideElements sort: [ :a :b | 
		                         (a distanceTo: aPoint)
		                         < (b distanceTo: aPoint) ].
	^ distanceOrderElements
]

{ #category : #private }
GdaStructure >> flushDirtyInfo [

	dirtyReservedArea := nil.
	dirtyElements := nil
]

{ #category : #'accessing - analisys' }
GdaStructure >> indirectReferencedStructureNames [

	^ self indirectReferencedStructures collect: [ :each | each name ]
]

{ #category : #'accessing - analisys' }
GdaStructure >> indirectReferencedStructures [

	| refs set |
	set := Set new.
	refs := self referencedStructures.
	set addAll: refs.
	[ refs isEmpty ] whileFalse: [ 
		refs do: [ :each | 
			refs := each indirectReferencedStructures.
			set addAll: refs ] ].
	^ set asArray
]

{ #category : #initialization }
GdaStructure >> initialize [

	| time |
	super initialize.
	time := DateAndTime now.
	timeCreated := time copy.
	timeModified := time copy.
	"colElements := OrderedCollection new."
	elements := nil.
	maxKeyNumber := nil
]

{ #category : #testing }
GdaStructure >> isLeaf [

	^ (self elements detect: [ :e | e isReference ] ifNone: [  ]) isNil
]

{ #category : #testing }
GdaStructure >> isOpen [

	^ library isOpen
]

{ #category : #testing }
GdaStructure >> isStructure [

	^ true
]

{ #category : #testing }
GdaStructure >> isTransient [

	^ library isTransient
]

{ #category : #accessing }
GdaStructure >> labelString [

	^ String streamContents: [ :s | 
		  self dirty ifTrue: [ s nextPutAll: '* ' ].
		  s nextPutAll: self name ]
]

{ #category : #accessing }
GdaStructure >> layers [

	self libraryLayers ifNotNil: [ :it | ^ it ].
	^ self localLayers
]

{ #category : #initialization }
GdaStructure >> library [

	^ library
]

{ #category : #initialization }
GdaStructure >> library: aGdsLibrary [

	library ifNotNil: [ 
		self error: 'library already set. int this structure' ].
	library := aGdsLibrary
]

{ #category : #accessing }
GdaStructure >> libraryLayers [

	library ifNil: [ ^ nil ].
	^ library layers
]

{ #category : #accessing }
GdaStructure >> liveElements [

	^ self elements reject: [ :each | 
		  each state = #inTrush or: [ each damaged ] ]
]

{ #category : #accessing }
GdaStructure >> localLayers [

	^ layers
]

{ #category : #private }
GdaStructure >> lookupDataExtentForElements [

	^ self lookupDataExtentForElementsChooserBlock: [ :element | true ]
]

{ #category : #private }
GdaStructure >> lookupDataExtentForElementsChooserBlock: aElementBlock [

	| bounds |
	bounds := GeometryUtils minusBounds.
	(self liveElements select: aElementBlock) do: [ :e | 
		bounds := bounds merge: e dataBounds ].
	^ bounds
]

{ #category : #'key generator' }
GdaStructure >> lookupMaxKeyNumber [

	| filledElements |
	filledElements := self elements select: [ :each | 
		                  each keyNumberFilled ].
	filledElements
		ifEmpty: [ ^ 0 ]
		ifNotEmpty: [ 
		^ (filledElements collect: [ :each | each keyNumber ]) max ]
]

{ #category : #'accessing - analisys' }
GdaStructure >> lookupReferencedStructures [

	^ self library structures select: [ :each | 
		  each directReferenceElements anySatisfy: [ :el | 
			  el structureName sameAs: self name ] ]
]

{ #category : #private }
GdaStructure >> lookupUsingLayerNumbers [

	| numberSet |
	numberSet := (self elements
		              select: [ :each | each hasLayer ]
		              thenCollect: [ :each | each layerNumber ]) asSet.
	"Pharo: asSortedArray "
	^ numberSet asArray sorted
]

{ #category : #accessing }
GdaStructure >> maxDepth [

	| walker maxDepth |
	walker := GdaStructureWalker new.
	maxDepth := 0.
	walker walk: self do: [ maxDepth := maxDepth max: walker depth ].
	^ maxDepth
]

{ #category : #'key generator' }
GdaStructure >> maxKeyNumber [

	maxKeyNumber ifNil: [ maxKeyNumber := self lookupMaxKeyNumber ].
	^ maxKeyNumber
]

{ #category : #private }
GdaStructure >> memberMatcher: memberName [

	| m |
	m := '([^.]+)\.(\d+)\.(gdsfeelbeta)' asRegex.
	(m matches: memberName) ifTrue: [ ^ m ].
	^ nil
]

{ #category : #attribute }
GdaStructure >> name [

	^ name
]

{ #category : #initialization }
GdaStructure >> name: aStructureName [

	name ifNotNil: [ ^ self error: 'structure name already set.' ].
	name := self coerceStructureName: aStructureName
]

{ #category : #'key generator' }
GdaStructure >> nextKeyNumber [

	| newValue |
	newValue := self maxKeyNumber + 1.
	maxKeyNumber := newValue.
	^ newValue
]

{ #category : #private }
GdaStructure >> popDirtyReservedArea [

	dirtyReservedArea ifNil: [ ^ nil ].
	dirtyReservedArea ifNotEmpty: [ ^ dirtyReservedArea removeLast ]
]

{ #category : #copying }
GdaStructure >> postCopy [

	super postCopy.
	elements := elements collect: [ :e | e copy ].
	layers := layers copy
]

{ #category : #printing }
GdaStructure >> printOn: aStream [

	super printOn: aStream.
	aStream nextPutAll: '('.
	aStream nextPutAll: self name.
	aStream nextPutAll: ')'
]

{ #category : #copying }
GdaStructure >> privateName: aName [

	name := aName
]

{ #category : #private }
GdaStructure >> pushDirtyReservedArea: aGdsElement [

	"!!!NOTE!!!"

	"if this effect is active. then after must send #comitDirty."

	dirtyReservedArea ifNil: [ 
		dirtyReservedArea := OrderedCollection new ].
	dirtyReservedArea add: aGdsElement
]

{ #category : #'accessing - analisys' }
GdaStructure >> referenceEnabledStructureNames [

	| ignoreNames |
	ignoreNames := self indirectReferencedStructureNames.
	^ self library structureNames reject: [ :each | 
		  (each sameAs: self name) or: [ ignoreNames includes: each ] ]
]

{ #category : #'accessing - analisys' }
GdaStructure >> referencedStructureNames [

	^ self referencedStructures collect: [ :each | each name ]
]

{ #category : #'accessing - analisys' }
GdaStructure >> referencedStructures [

	^ referencedStructures ifNil: [ 
		  referencedStructures := self lookupReferencedStructures ]
]

{ #category : #initialization }
GdaStructure >> release [

	timeCreated := nil.
	timeModified := nil.
	"colElements ifNotNil: [ colElements do: [:each | each release]].
	colElements := nil."
	elements ifNotNil: [ elements do: [ :each | each release ] ].
	elements := nil.
	maxKeyNumber := nil.
	layers release.
	layers := nil.
	name := nil.
	super release
]

{ #category : #accessing }
GdaStructure >> removeAllElements [

	^ self removeElements: self elements
]

{ #category : #accessing }
GdaStructure >> removeElement: aGdsElement [

	self removeElements: (Array with: aGdsElement)
]

{ #category : #accessing }
GdaStructure >> removeElements: aGdsElementCollection [

	"| announcement |"

	aGdsElementCollection ifEmpty: [ ^ self ].
	"announcement := GdsElementRemoved new elements: aGdsElementCollection."
	elements := elements copyWithoutAll: aGdsElementCollection.
	dataExtentForElements := nil.
	dirtyElements ifNotNil: [ "self announcer announce: announcement" "self setDirty: true." 
		dirtyElements removeAllFoundIn: aGdsElementCollection ]
]

{ #category : #accessing }
GdaStructure >> removedElements [

	^ self elements select: [ :each | each state = #inTrush ]
]

{ #category : #private }
GdaStructure >> revertDirty [

	self popDirtyReservedArea
]

{ #category : #accessing }
GdaStructure >> safeNoElementDataExtent [

	^ self class safeNoElementDataExtent
]

{ #category : #private }
GdaStructure >> strictMemberMatcher: memberName [

	| m |
	m := ('(' , self name , '\.(\d+)\.(gdsfeelbeta)') asRegex.
	(m matches: memberName) ifTrue: [ ^ m ].
	^ nil
]

{ #category : #'accessing - analisys' }
GdaStructure >> subStructures [

	^ (self directReferenceElements collect: [ :e | e refStructure ])
		  asSet asArray
]

{ #category : #attribute }
GdaStructure >> timeCreated [

	timeCreated ifNil: [ timeCreated := DateAndTime now ].
	^ timeCreated
]

{ #category : #attribute }
GdaStructure >> timeModified [

	timeModified ifNil: [ timeModified := DateAndTime now ].
	^ timeModified
]

{ #category : #accessing }
GdaStructure >> uniqCopyName [

	| uniqName strucNames |
	strucNames := self library structureNames.
	uniqName := self name , '_COPY'.
	[ strucNames includes: uniqName ] whileTrue: [ 
		uniqName := uniqName , '_COPY' ].
	^ uniqName
]

{ #category : #private }
GdaStructure >> usingLayerNumbers [

	^ self lookupUsingLayerNumbers
]
