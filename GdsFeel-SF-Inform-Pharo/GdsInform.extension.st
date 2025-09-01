Extension { #name : #GdsInform }

{ #category : #'*GdsFeel-SF-Inform-Pharo' }
GdsInform >> saveLibrary [

	library ifNil: [ ^ self ].
	(GdsLibrary exists: library libName) ifTrue: [ 
		^ self inform: 'Already exist.' ].
	self saveLibraryWithArchive: true
]

{ #category : #'*GdsFeel-SF-Inform-Pharo' }
GdsInform >> saveLibraryWithArchive: aBoolean [

	library unitString: 'MICRON'. "TODO: fix"
	library makeFolder.
	library structures do: [ :each | each save: true ].
	library autoAllocateLayerColors.
	"library layers explore."
	aBoolean ifTrue: [ library close ]
]
