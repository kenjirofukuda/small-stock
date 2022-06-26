"
GdsInputBuffer flush.


"
Class {
	#name : #KFInputBufferFlushed,
	#superclass : #Announcement,
	#instVars : [
		'stringContents'
	],
	#category : #'KFConsole-Model'
}

{ #category : #accesing }
KFInputBufferFlushed >> stringContents [
	^ stringContents
]

{ #category : #accessing }
KFInputBufferFlushed >> stringContents: aString [
	stringContents := aString
]
