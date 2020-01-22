Class {
	#name : #GdsKindsSpecView,
	#superclass : #GdsStatesSpecView,
	#category : #'GdsFeel-UI-Spec'
}

{ #category : #'as yet unclassified' }
GdsKindsSpecView class >> open [
	<script>
	self new kinds: GdsKinds new; openWithSpec.
]

{ #category : #'as yet unclassified' }
GdsKindsSpecView >> kinds: aGdsKinds [
	self model: aGdsKinds
]

{ #category : #'as yet unclassified' }
GdsKindsSpecView >> viewForItem: aGdsKind [
	viewMap ifNil: [ viewMap := Dictionary new ].
	^ viewMap at: aGdsKind ifAbsentPut: [ (GdsKindSpecView new model: aGdsKind; buildWithSpec) ]

]
