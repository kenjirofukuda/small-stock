Extension { #name : 'Point' }

{ #category : '*GdsFeel-UI' }
Point >> mark [
	GdsStructureEditorMorph topmost markPoints: (Array with: self)
]
