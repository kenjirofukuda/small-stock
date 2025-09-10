Class {
	#name : #GdsStructureReferenceDrawer,
	#superclass : #GdsReferenceDrawer,
	#category : #'GdsFeel-UI-Drawer'
}

{ #category : #testing }
GdsStructureReferenceDrawer >> canDisplayExtent [

	^ self canDisplayKindForKey: 'SE'
]

{ #category : #testing }
GdsStructureReferenceDrawer >> canDisplayOrigin [

	^ self canDisplayKindForKey: 'SO'
]
