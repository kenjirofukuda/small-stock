Extension { #name : #DxfDataGroup }

{ #category : #'*GdsFeel-Model-ElementAddition' }
DxfDataGroup >> printDxfOn: aStream [ 
	aStream nextPutAll: (code asString trimBoth padLeftTo: 4).
	aStream ensureCr.
	aStream nextPutAll: self data asString.
	aStream ensureCr.
	
]
