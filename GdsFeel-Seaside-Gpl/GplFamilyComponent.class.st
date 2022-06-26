Class {
	#name : #GplFamilyComponent,
	#superclass : #KFSimpleFileViewComponent,
	#category : #'GdsFeel-Seaside-Gpl'
}

{ #category : #'as yet unclassified' }
GplFamilyComponent >> familyClasses [
	^ GplFamilyComponent allSubclasses
]

{ #category : #'as yet unclassified' }
GplFamilyComponent >> initialize [
	super initialize.
	self
		addDecoration: (GplGroupDecoration new groupClasses: self familyClasses)
]
