Class {
	#name : #GdsStructureDuplicated,
	#superclass : #GdsStructureAnnouncement,
	#instVars : [
		'sourceStructure'
	],
	#category : #'GdsFeel-Model-Container'
}

{ #category : #accessing }
GdsStructureDuplicated >> sourceStructure [
	^ sourceStructure 
]

{ #category : #accessing }
GdsStructureDuplicated >> sourceStructure: aGdsStructure [
	sourceStructure := aGdsStructure.
]
