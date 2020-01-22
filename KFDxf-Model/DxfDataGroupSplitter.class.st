Class {
	#name : #DxfDataGroupSplitter,
	#superclass : #Object,
	#instVars : [
		'dataGroups',
		'stream',
		'beginBlock',
		'endBlock',
		'containsBegin',
		'containsEnd'
	],
	#category : #'KFDxf-Model'
}

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter class >> forSectionOn: aGroupCodes [
	| splitter |
	splitter := self on: aGroupCodes.
	splitter beginBlock: [ :dataGroup | dataGroup isBeginSection ].
	splitter endBlock: [ :dataGroup | dataGroup isEndSection ].
	^ splitter
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter class >> on: aCollection [
	^ self new dataGroups: aCollection; yourself
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> beginBlock: aDataGroupBlock [
	beginBlock := aDataGroupBlock
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> containsBegin: aBoolean [
	containsBegin := aBoolean
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> containsEnd: aBoolean [
	containsEnd := aBoolean
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> dataGroups: aCollection [
	dataGroups := aCollection asArray.
	stream := ReadStream on: dataGroups.
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> endBlock: aDataGroupBlock [
	endBlock := aDataGroupBlock
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> handleDataGroup: aDxfDataGroup [
	(beginBlock value: aDxfDataGroup)
		ifTrue: [ 
			self createActiveContainer.
			containsBegin 
				ifTrue: [ self pushToActive: aDxfDataGroup ].
			 ^ self ].
	(endBlock value: aDxfDataGroup)
		ifTrue: [ 
			containsEnd 
				ifTrue: [ self pushToActive: aDxfDataGroup ].
			 ^ self ].			
	self pushToActive: aDxfDataGroup
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> initialize [
	super initialize.
	containsBegin := false.
	containsEnd := false.	
	
]

{ #category : #'as yet unclassified' }
DxfDataGroupSplitter >> split [
	dataGroups ifNil: [ ^ #() ].	
	beginBlock ifNil: [ ^ dataGroups ].	
	endBlock ifNil: [ ^ dataGroups ].		
	[stream atEnd]
		whileFalse: [ | dataGroup |
			dataGroup := stream next.
			self handleDataGroup: dataGroup
			 ]
				

]
