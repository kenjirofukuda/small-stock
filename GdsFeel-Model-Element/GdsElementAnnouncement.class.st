Class {
	#name : #GdsElementAnnouncement,
	#superclass : #Announcement,
	#instVars : [
		'elements'
	],
	#category : #'GdsFeel-Model-Element'
}

{ #category : #accessing }
GdsElementAnnouncement >> element [
	^ elements first
]

{ #category : #accessing }
GdsElementAnnouncement >> element: aGdsElement [
	self elements: (Array with: aGdsElement)
]

{ #category : #accessing }
GdsElementAnnouncement >> elements [
	^ elements copy
]

{ #category : #accessing }
GdsElementAnnouncement >> elements: aGdsElementCollection [
	elements := aGdsElementCollection copy.
]
