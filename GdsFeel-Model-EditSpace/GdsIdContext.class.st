"
A GdsIdContext is element identify selection context.

Instance Variables

"
Class {
	#name : #GdsIdContext,
	#superclass : #Object,
	#instVars : [
		'structure',
		'ids'
	],
	#category : #'GdsFeel-Model-EditSpace'
}

{ #category : #accessing }
GdsIdContext >> elements [
	| set |
	self isEmpty ifTrue: [^#() copy].
	set := ids asSet.	
	^self structure liveElements select: [:each | set includes: each keyNumber].
]

{ #category : #testing }
GdsIdContext >> enabled [
	^ self notEmpty
]

{ #category : #private }
GdsIdContext >> forgetStructure [
	self idClear.
	self structure ifNotNil: [ids announcer unsubscribe: self structure].
	self structure: nil.
	
]

{ #category : #'id operation' }
GdsIdContext >> id: keyNumber [ 
	self privateIdClear.
	self idAdd: keyNumber.
	self changed: #id
]

{ #category : #'id operation' }
GdsIdContext >> idAdd: keyNumber [ 
	self assert: [keyNumber isInteger].
	ids add: keyNumber.
]

{ #category : #'id operation' }
GdsIdContext >> idAddAll: keyNumberCollection [ 
	self assert: [keyNumberCollection isCollection].
	ids addAll: keyNumberCollection.
]

{ #category : #'id operation' }
GdsIdContext >> idClear [
	self privateIdClear.
]

{ #category : #testing }
GdsIdContext >> idClearEnabled [
	^self notEmpty.
]

{ #category : #'id operation' }
GdsIdContext >> idDelete [
	self structure idDelete.	 
	self privateIdClear.
]

{ #category : #testing }
GdsIdContext >> idDeleteEnabled [
	^self notEmpty.
]

{ #category : #accessing }
GdsIdContext >> idsProerpty [
	^ ids
]

{ #category : #initalize }
GdsIdContext >> initialize [
	ids := OrderedCollection new asValueHolder.
	structure := nil asValueHolder.
	ids
		whenChangedDo: [ structure value ifNotNil: [ :s | s updateIdState ] ]
]

{ #category : #testing }
GdsIdContext >> isEmpty [
	self structure ifNil: [ ^ true].
	ids ifNil: [ ^ true].
	^ ids value isEmpty.
]

{ #category : #accessing }
GdsIdContext >> keyNumbers [
	^ ids value asSet
]

{ #category : #testing }
GdsIdContext >> notEmpty [
	^ self isEmpty not
]

{ #category : #private }
GdsIdContext >> privateIdClear [
	ids removeAll.
	

]

{ #category : #accessing }
GdsIdContext >> structure [
	^ structure value
]

{ #category : #accessing }
GdsIdContext >> structure: aGdsStructure [
	structure value: aGdsStructure.
		
]

{ #category : #'id operation' }
GdsIdContext >> unId: keyNumber [
	ids
		remove: keyNumber
		ifAbsent: [ Transcript
				cr;
				show: '*** WARNING *** UNID: ';
				show: keyNumber printString;
				show: ' not in id selection' ]
]

{ #category : #'id operation' }
GdsIdContext >> unIdAll: keyNumberCollection. [ 
	self assert: [keyNumberCollection isCollection].
	ids removeAllFoundIn: keyNumberCollection.	
]
