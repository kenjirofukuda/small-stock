Class {
	#name : #GdsBoxTextDrawer,
	#superclass : #GdsPrimitiveDrawer,
	#category : 'GdsFeel-UI-Drawer'
}

{ #category : #testing }
GdsBoxTextDrawer >> canDisplayOrigin [
	^ self canDisplayKindForKey: 'TO'
]

{ #category : #drawing }
GdsBoxTextDrawer >> drawItemFeedbackOn: aCanvas [
	self strokeOutlineOn: aCanvas.
]

{ #category : #drawing }
GdsBoxTextDrawer >> fillOutlineOn: aCanvas [
	"No Fill"
]

{ #category : #drawing }
GdsBoxTextDrawer >> strokeOutlineOn: aCanvas [ 
	| savedColor |
	(self canDisplayKindForKey: 'TX') ifFalse: [ ^ self ].
	morph fastDrawing ifTrue: [ ^ self ].
	savedColor := morph penColor.
	"morph penColor: self penColor."
	morph 
		drawOn: aCanvas
		fittingStrokeStringOrig: element contents
		bounds: element dataBounds.
	morph penColor: savedColor
]
