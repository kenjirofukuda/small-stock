Class {
	#name : #GdsAcCircleDrawer,
	#superclass : #GdsPrimitiveDrawer,
	#category : #'GdsFeel-UI-ElementAddition'
}

{ #category : #drawing }
GdsAcCircleDrawer >> fillOutlineOn: aCanvas [ 
]

{ #category : #drawing }
GdsAcCircleDrawer >> strokeOutlineOn: aCanvas [
	self strokeVerticesOn: aCanvas points: element dataOutlinePoints.  
]
