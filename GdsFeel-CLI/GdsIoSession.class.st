"
A GdsIoSession is xxxxxxxxx.

Instance Variables
	records:		<OrderedCollection>
	session:		<Integer>

records
	- xxxxx

session
	- xxxxx

"
Class {
	#name : 'GdsIoSession',
	#superclass : 'Object',
	#instVars : [
		'session',
		'records'
	],
	#category : 'GdsFeel-CLI-Service',
	#package : 'GdsFeel-CLI',
	#tag : 'Service'
}

{ #category : 'as yet unclassified' }
GdsIoSession >> addRecord: aGdsIoRecord [
	records ifNil: [ records := OrderedCollection new ].
	records add: aGdsIoRecord
]

{ #category : 'as yet unclassified' }
GdsIoSession >> asString [
	records ifEmpty: [ ^ '' ].
	records size = 1
		ifTrue: [ ^ records first asString ].
	^ (records collect: [ :each | each asString ]) joinUsing: String cr
]

{ #category : 'as yet unclassified' }
GdsIoSession >> hasMoreData [
	^ records last hasMoreData
]

{ #category : 'as yet unclassified' }
GdsIoSession >> initialize [
	super initialize.
	records := OrderedCollection new
]

{ #category : 'as yet unclassified' }
GdsIoSession >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	records size = 1
		ifTrue: [ aStream print: records first asString ].
	aStream nextPut: $)
]

{ #category : 'as yet unclassified' }
GdsIoSession >> session [
	^ session
]

{ #category : 'as yet unclassified' }
GdsIoSession >> session: aNumber [
	session := aNumber
]
