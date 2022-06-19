Class {
	#name : #GplSourceComponent,
	#superclass : #GplFamilyComponent,
	#instVars : [
		'scanner'
	],
	#category : #'GdsFeel-Seaside-Gpl'
}

{ #category : #'as yet unclassified' }
GplSourceComponent class >> handlerName [
	^ 'gds/gpl-source'
]

{ #category : #'as yet unclassified' }
GplSourceComponent class >> initialize [
	"self initialize."

	WAAdmin register: self asApplicationAt: self handlerName
]

{ #category : #'as yet unclassified' }
GplSourceComponent >> files [
	^ GdsDocumentCenter lookupGplSources
]

{ #category : #'as yet unclassified' }
GplSourceComponent >> viewComponentClass [
	^ GplSourceViewComponent
]
