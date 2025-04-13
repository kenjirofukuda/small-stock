Class {
	#name : #GdsPrimitiveDrawer,
	#superclass : #GdsElementDrawer,
	#category : 'GdsFeel-UI-Drawer'
}

{ #category : #drawing }
GdsPrimitiveDrawer >> drawItemFeedbackOn: aCanvas [
	morph drawItemLineSegmentsOn: aCanvas.
]

{ #category : #drawing }
GdsPrimitiveDrawer >> fillOutlineOn: aCanvas [ 
	morph 
		penColor:  self elementFill
		during: [
			morph 
				drawOn: aCanvas
				fillPolyLineVertices: element dataOutlinePoints].

]

{ #category : #drawing }
GdsPrimitiveDrawer >> strokeOutlineOn: aCanvas [
	self strokeVerticesOn: aCanvas
]
