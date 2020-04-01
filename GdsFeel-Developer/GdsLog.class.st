Class {
	#name : #GdsLog,
	#superclass : #Object,
	#instVars : [
		'logStream',
		'category'
	],
	#category : #'GdsFeel-Developer-Debug'
}

{ #category : #'as yet unclassified' }
GdsLog >> beginLog [
	logStream := WriteStream on: ''
]

{ #category : #'as yet unclassified' }
GdsLog >> category [
	^ category
]

{ #category : #'as yet unclassified' }
GdsLog >> category: aCategory [
	category := aCategory
]

{ #category : #'as yet unclassified' }
GdsLog >> endLog [
	logStream ifNil: [ ^ self ].
	logStream position = 0
		ifTrue: [ ^ self ].
	(Workspace new contents: logStream contents)
		openLabel: self category asString
]

{ #category : #'as yet unclassified' }
GdsLog >> println: anObject [
	logStream cr.
	logStream nextPutAll: anObject asString
]
