Class {
	#name : #GdoLibrary,
	#superclass : #Object,
	#instVars : [
		'lastModified',
		'lastAccessed',
		'libName',
		'userUnit',
		'meterUnit',
		'databaseUnit',
		'structures'
	],
	#category : #'GdsFeel-SF-Inform-Core'
}

{ #category : #'adding/removing protocols' }
GdoLibrary >> addStructure: aGdoStructure [ 
	structures add: aGdoStructure
]

{ #category : #accessing }
GdoLibrary >> databaseUnit [
	^ databaseUnit
]

{ #category : #accessing }
GdoLibrary >> databaseUnit: aNumber [
	databaseUnit := aNumber
]

{ #category : #initialization }
GdoLibrary >> initialize [ 
	structures := OrderedCollection new
]

{ #category : #accessing }
GdoLibrary >> lastAccessed [

	^ lastAccessed
]

{ #category : #accessing }
GdoLibrary >> lastAccessed: aDateAndTime [ 
	lastAccessed := aDateAndTime
]

{ #category : #accessing }
GdoLibrary >> lastModified [

	^ lastModified
]

{ #category : #accessing }
GdoLibrary >> lastModified: aDateAndTime [ 
	lastModified := aDateAndTime
]

{ #category : #accessing }
GdoLibrary >> libName [

	^ libName
]

{ #category : #accessing }
GdoLibrary >> libName: aString [ 
	libName := aString
]

{ #category : #accessing }
GdoLibrary >> meterUnit [

	^ meterUnit
]

{ #category : #accessing }
GdoLibrary >> meterUnit: aNumber [ 
	meterUnit := aNumber
]

{ #category : #accessing }
GdoLibrary >> structures [

	^ structures
]

{ #category : #accessing }
GdoLibrary >> structures: anObject [

	^ structures := anObject
]

{ #category : #accessing }
GdoLibrary >> userUnit [
	^ userUnit
]

{ #category : #accessing }
GdoLibrary >> userUnit: aNumber [ 
	userUnit := aNumber.
	self databaseUnit: aNumber reciprocal asInteger.	
]
