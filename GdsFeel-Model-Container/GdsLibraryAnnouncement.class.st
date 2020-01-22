"
A GdsLibraryAnnouncement is abstract class.

Instance Variables

"
Class {
	#name : #GdsLibraryAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'library'
	],
	#category : #'GdsFeel-Model-Container'
}

{ #category : #'as yet unclassified' }
GdsLibraryAnnouncement >> library [
	^library
]

{ #category : #'as yet unclassified' }
GdsLibraryAnnouncement >> library: aGdsLibrary [
	library := aGdsLibrary.
]
