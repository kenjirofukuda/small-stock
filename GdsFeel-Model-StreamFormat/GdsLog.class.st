"
Instance Variables
	category:		<String>
	logStream:	<WriteStream>

"
Class {
	#name : #GdsLog,
	#superclass : #Object,
	#instVars : [
		'logStream',
		'category'
	],
	#category : #'GdsFeel-Model-StreamFormat'
}

{ #category : #logging }
GdsLog >> beginLog [

	logStream := WriteStream on: ''
]

{ #category : #accessing }
GdsLog >> category [

	^ category
]

{ #category : #accessing }
GdsLog >> category: aCategory [

	category := aCategory
]

{ #category : #logging }
GdsLog >> endLog [

	logStream ifNil: [ ^ self ].
	logStream position = 0 ifTrue: [ ^ self ].
	UIManager default edit: logStream contents label: self category asString.
]

{ #category : #logging }
GdsLog >> println: anObject [

	logStream cr.
	logStream nextPutAll: anObject asString
]
