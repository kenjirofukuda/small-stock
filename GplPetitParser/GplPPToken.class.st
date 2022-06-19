Class {
	#name : #GplPPToken,
	#superclass : #PPToken,
	#instVars : [
		'comments'
	],
	#category : #'GplPetitParser-Grammar'
}

{ #category : #accessing }
GplPPToken >> comments [
	^ comments
]

{ #category : #accessing }
GplPPToken >> comments: anArray [
	comments := anArray
]

{ #category : #accessing }
GplPPToken >> length [
	^ self size
]
