Extension { #name : #GdsInform }

{ #category : #'*GdsFeel-SF-Inform-UI-Pharo' }
GdsInform class >> makeGDSreaderSample [
	| inform |
	inform := self sampleReleaseInstance.
	inform run.
	inform saveLibrary.
	
		 

]

{ #category : #'*GdsFeel-SF-Inform-UI-Pharo' }
GdsInform class >> reMakeGDSreaderSample [

	"self reMakeGDSreaderSample"

	<script>
	| file |
	file := './GdsFeel/BGHIER.DB' asFileReference.
	file ensureDelete.
	self makeGDSreaderSample
]
