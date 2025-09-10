Extension { #name : #Point }

{ #category : #'*GdsFeel-UI-Extension' }
Point >> mark [

	GdsStructureEditorMorph topmost markPoints: (Array with: self)
]
