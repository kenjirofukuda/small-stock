Class {
	#name : #KFBrowserComponent,
	#superclass : #WAComponent,
	#instVars : [
		'browser'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #accessing }
KFBrowserComponent >> browser [
	^ browser
]

{ #category : #accessing }
KFBrowserComponent >> browser: anObject [
	browser := anObject
]
