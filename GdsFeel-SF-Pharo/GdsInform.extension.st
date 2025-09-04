Extension { #name : #GdsInform }

{ #category : #'*GdsFeel-SF-Pharo' }
GdsInform class >> makeGDSreaderSample [
	| inform |
	inform := self sampleReleaseInstance.
	inform run.
	inform saveLibrary.
	
		 

]

{ #category : #'*GdsFeel-SF-Pharo' }
GdsInform class >> reMakeGDSreaderSample [

	"self reMakeGDSreaderSample"

	<script>
	| file |
	file := './GdsFeel/BGHIER.DB' asFileReference.
	file ensureDelete.
	self makeGDSreaderSample
]

{ #category : #'*GdsFeel-SF-Pharo' }
GdsInform >> saveLibrary [

	library ifNil: [ ^ self ].
	(GdsLibrary exists: library libName) ifTrue: [ 
		^ self inform: 'Already exist.' ].
	self saveLibraryWithArchive: true
]

{ #category : #'*GdsFeel-SF-Pharo' }
GdsInform >> saveLibraryWithArchive: aBoolean [

	library unitString: 'MICRON'. "TODO: fix"
	library makeFolder.
	library structures do: [ :each | each save: true ].
	library autoAllocateLayerColors.
	"library layers explore."
	aBoolean ifTrue: [ library close ]
]
