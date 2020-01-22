"
A GdsCompatibility is controls GDS II simulation spec level  .

Instance Variables

"
Class {
	#name : #GdsCompatibility,
	#superclass : #Object,
	#classVars : [
		'CompatibilityClass',
		'DefaultCompatibility'
	],
	#category : #'GdsFeel-Model-Basic'
}

{ #category : #'as yet unclassified' }
GdsCompatibility class >> activeClass [
	GdsCompatibility allSubclasses do: [:class |
		class isActive ifTrue: [^ class]].
	^ GdsCompatibility 

]

{ #category : #'as yet unclassified' }
GdsCompatibility class >> checker [
	| clazz |
	clazz := Smalltalk at: #DosFileDirectory ifAbsent: [  ].
	clazz
		ifNotNil: [ ^ clazz new ]
			ifNil: [ 
				clazz := Smalltalk at: #FileSystem ifAbsent: [  ].
				clazz ifNotNil: [ ^ clazz disk ] ] .
	^ nil

]

{ #category : #actions }
GdsCompatibility class >> create [
	CompatibilityClass ifNil: [self setActiveClass].
	^CompatibilityClass new.

]

{ #category : #defaults }
GdsCompatibility class >> default [
	DefaultCompatibility ifNil: [DefaultCompatibility := self create.].
	^DefaultCompatibility.

]

{ #category : #'class initialization' }
GdsCompatibility class >> initialize [
	"self initialize"
	Smalltalk addToStartUpList: self.	

]

{ #category : #testing }
GdsCompatibility class >> isActive [
	^false
]

{ #category : #'as yet unclassified' }
GdsCompatibility class >> setActiveClass [
	CompatibilityClass := self activeClass.

]

{ #category : #'system startup' }
GdsCompatibility class >> startUp [
	self setActiveClass.
	
]

{ #category : #convert }
GdsCompatibility >> checker [
	^self class checker.
]

{ #category : #convert }
GdsCompatibility >> coerceStructureName: aString [
	| partial |
	partial := aString copyReplaceAll: ' ' with: '_' .
	partial ifEmpty: [^'' copy].
	^self checker checkName: partial fixErrors: true.
]

{ #category : #testing }
GdsCompatibility >> elementColorAllowed [
	^true
]

{ #category : #testing }
GdsCompatibility >> isValidLibraryName: aString [ 
	^ (self isValidStorageName: aString) and: 
	[aString matchesRegex: '[A-Z][A-Z0-9$_]+'].
]

{ #category : #testing }
GdsCompatibility >> isValidStorageName: aString [
	(aString includes: Character space)
		ifTrue: [ ^ false ].
	[ self checker checkName: aString fixErrors: false ]
		on: Error
		do: [ :ex | ^ false ].
	self multilingalNameAllowed
		ifFalse: [ ^ (aString isKindOf: WideString) not ].
	^ true
]

{ #category : #testing }
GdsCompatibility >> isValidStructureName: aString [ 
	^self isValidStorageName: aString
]

{ #category : #acessing }
GdsCompatibility >> itemNumberMax [
	^9
]

{ #category : #acessing }
GdsCompatibility >> itemNumberMin [
	^0
]

{ #category : #acessing }
GdsCompatibility >> itemNumberRange [
	^Interval from: self itemNumberMin to: self itemNumberMax. 
]

{ #category : #acessing }
GdsCompatibility >> layerNumberMax [
	^255.
]

{ #category : #acessing }
GdsCompatibility >> layerNumberMin [
	^0.
]

{ #category : #acessing }
GdsCompatibility >> layerNumberRange [
	^Interval from: self layerNumberMin to: self layerNumberMax. 
]

{ #category : #acessing }
GdsCompatibility >> libNameMax [
	^-1
]

{ #category : #testing }
GdsCompatibility >> limitedColorSpace [
	^ self supportedColorSymbols isNotEmpty
]

{ #category : #testing }
GdsCompatibility >> limitedColors [
	^ self supportedColorSymbols collect: [ :colorSymbol | Color perform: colorSymbol].

]

{ #category : #testing }
GdsCompatibility >> multilingalNameAllowed [
	^ true
]

{ #category : #'category name' }
GdsCompatibility >> supportedColorSymbols [
	^#() copy.
]
