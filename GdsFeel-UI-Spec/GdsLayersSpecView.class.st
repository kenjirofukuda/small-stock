Class {
	#name : 'GdsLayersSpecView',
	#superclass : 'GdsStatesSpecView',
	#category : 'GdsFeel-UI-Spec',
	#package : 'GdsFeel-UI-Spec'
}

{ #category : 'as yet unclassified' }
GdsLayersSpecView class >> open [
	<script>
	self new model: GdsStation default library layers ; openWithSpec.
]

{ #category : 'as yet unclassified' }
GdsLayersSpecView >> viewForItem: aGdsLayer [
	^ self viewForItemBySpec: aGdsLayer
]

{ #category : 'as yet unclassified' }
GdsLayersSpecView >> viewForItemByDummyString: aGdsLayer [
	viewMap ifNil: [ viewMap := Dictionary new ].
	^ viewMap at: aGdsLayer ifAbsentPut: [ aGdsLayer asString]
]

{ #category : 'as yet unclassified' }
GdsLayersSpecView >> viewForItemByMorph: aGdsLayer [
	viewMap ifNil: [ viewMap := Dictionary new ].
	^ viewMap at: aGdsLayer ifAbsentPut: [ (GdsLayerStateMorph new layer: aGdsLayer; yourself) ]
]

{ #category : 'as yet unclassified' }
GdsLayersSpecView >> viewForItemBySpec: aGdsLayer [
	viewMap ifNil: [ viewMap := Dictionary new ].
	^ viewMap at: aGdsLayer ifAbsentPut: [ (GdsLayerSpecView new layer: aGdsLayer; buildWithSpec) ]
]
