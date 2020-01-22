"
A GdsItems is collection of GdsItem.

activate only one of item from 0 to 9.

Instance Variables
	items:		<Array<GdsItemContext>>
	structure:		<GdsStructure>
	zeroBasedIndex:		<SmallInteger>

items
	- xxxxx

structure
	- xxxxx

zeroBasedIndex
	- xxxxx

"
Class {
	#name : #GdsItems,
	#superclass : #Model,
	#instVars : [
		'items',
		'zeroBasedIndex',
		'structure'
	],
	#category : #'GdsFeel-Model-EditSpace'
}

{ #category : #dependents }
GdsItems >> addDependent: anObject [ 
	super addDependent: anObject .
	items do: [ :i | i addDependent: anObject ]
]

{ #category : #accessing }
GdsItems >> atNumber: aZeroBasedItemIndex [
	^items detect: [:each | each number = aZeroBasedItemIndex] ifNone:[]
	
]

{ #category : #actions }
GdsItems >> current [
	^self atNumber: zeroBasedIndex
	
]

{ #category : #accessing }
GdsItems >> current: aZeroBasedIndex [
	zeroBasedIndex := aZeroBasedIndex.
	self changed: #current.
	^self current.
	
	
]

{ #category : #private }
GdsItems >> forgetStructure [
	"items do: [ :each |  each forgetStructure]."
	
]

{ #category : #initialization }
GdsItems >> initialize [
	super initialize.
	items := OrderedCollection new.
	zeroBasedIndex := GdsCompatibility default itemNumberMin.
	GdsCompatibility default itemNumberRange  do: [:each | 
		| item |
		item := GdsItemContext newWithNumber: each.
		item items: self.
		items add: item]
	
]

{ #category : #initialization }
GdsItems >> release [
	items release.
	super release.
]

{ #category : #dependents }
GdsItems >> removeDependent: anObject [ 
	super removeDependent: anObject .
	items do: [ :i | i removeDependent: anObject ]
]

{ #category : #accessing }
GdsItems >> structure [
	^ structure
]

{ #category : #accessing }
GdsItems >> structure: aGdsStructure [
	structure := aGdsStructure.
	items do: [ :each |  each structure: aGdsStructure].
	
]
