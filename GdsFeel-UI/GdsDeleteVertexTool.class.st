Class {
	#name : #GdsDeleteVertexTool,
	#superclass : #GdsMovePointTool,
	#category : #'GdsFeel-UI-Tools'
}

{ #category : #'as yet unclassified' }
GdsDeleteVertexTool >> canFinish [
	^morph itemDeleteVertexEnabled not.
]

{ #category : #'as yet unclassified' }
GdsDeleteVertexTool >> drawFeedbackOn: aLocalCanvas [
	morph drawItemLineSegmentsOn: aLocalCanvas width: 2.
]

{ #category : #'as yet unclassified' }
GdsDeleteVertexTool >> eachAction [
	analisysResult := GeometryUtils 
		analisysSegmentsAt: (self snapedWorldPoint2) pointArray: self currentItem vertices.
	"analisysResult explore."
	replaceVertexIndex := self lookupReplaceVertexIndex. 
	self currentItem removeVertexAt: replaceVertexIndex.
]

{ #category : #'as yet unclassified' }
GdsDeleteVertexTool >> eventAction [
	self repeatEachAction.
	self prompt: self promptMessage.
	morph invalidBounds: self calcUpdateBounds .
]

{ #category : #'as yet unclassified' }
GdsDeleteVertexTool >> promptMessage [
	^'Identify the Vertex to Delete:'.
]

{ #category : #'as yet unclassified' }
GdsDeleteVertexTool >> toolDidChange [
	self prompt: self promptMessage.
]
