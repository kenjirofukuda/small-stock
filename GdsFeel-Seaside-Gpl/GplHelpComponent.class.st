Class {
	#name : #GplHelpComponent,
	#superclass : #GplFamilyComponent,
	#category : #'GdsFeel-Seaside-Gpl'
}

{ #category : #'as yet unclassified' }
GplHelpComponent class >> handlerName [
	^ 'gds/gpl-help'
]

{ #category : #'as yet unclassified' }
GplHelpComponent class >> initialize [
	"self initialize."

	WAAdmin register: self asApplicationAt: self handlerName
]

{ #category : #'as yet unclassified' }
GplHelpComponent >> files [
	^ GdsDocumentCenter lookupHelps
]
