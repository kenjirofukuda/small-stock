Class {
	#name : #GeometryUtilsTest,
	#superclass : #TestCase,
	#category : #GeometryUtils
}

{ #category : #tests }
GeometryUtilsTest >> testMinusBounds [
	"minusBounds allways negative rectangle"
	self assert: GeometryUtils minusBounds origin > GeometryUtils minusBounds corner.
]
