Class {
	#name : #GdsStructureAnnouncement,
	#superclass : #GdsLibraryAnnouncement,
	#instVars : [
		'structure'
	],
	#category : #'GdsFeel-Model-Container'
}

{ #category : #accessing }
GdsStructureAnnouncement >> structure [
	^ structure
]

{ #category : #accessing }
GdsStructureAnnouncement >> structure: anObject [
	structure := anObject
]
