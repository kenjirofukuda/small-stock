Class {
	#name : 'GdsDirectSegmentTool',
	#superclass : 'GdsQuickPointsTool',
	#category : 'GdsFeel-UI-Tools',
	#package : 'GdsFeel-UI',
	#tag : 'Tools'
}

{ #category : 'as yet unclassified' }
GdsDirectSegmentTool >> acceptFromPoint: aPoint1 toPoint: aPoint2 [
	self putPathFrom: aPoint1 to: aPoint2
]

{ #category : 'as yet unclassified' }
GdsDirectSegmentTool >> drawRubberBandOn: aLocalCanvas currentPoint: aPoint [ 
	self 
		drawRubberBandOn: aLocalCanvas 
		currentPoint: aPoint 
		segmentBlock: [
			:pt1 :pt2 |
			morph drawOn: aLocalCanvas lineFrom: pt1 to: pt2.].
]

{ #category : 'as yet unclassified' }
GdsDirectSegmentTool >> putPathFrom: aPoint1 to: aPoint2 [
	self currentItem putPathFrom: aPoint1 to: aPoint2

]
