Class {
	#name : #GdsObservation,
	#superclass : #Object,
	#instVars : [
		'selector',
		'observer'
	],
	#category : #'GdsFeel-Foundation-Notification'
}

{ #category : #'as yet unclassified' }
GdsObservation >> observer [
	^observer
]

{ #category : #'as yet unclassified' }
GdsObservation >> observer: anObserver [
	observer := anObserver.
]

{ #category : #'as yet unclassified' }
GdsObservation >> performWith: argument [
	observer perform: selector  with: argument.
]

{ #category : #printing }
GdsObservation >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."

	aStream nextPutAll: 'Obs('.
	aStream
		print: observer.
	aStream nextPutAll: ')'.
		
]

{ #category : #'as yet unclassified' }
GdsObservation >> selector [
	^selector
]

{ #category : #'as yet unclassified' }
GdsObservation >> selector: aSymbol [
	selector := aSymbol
]
