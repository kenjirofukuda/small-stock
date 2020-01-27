Extension { #name : #TwkPost }

{ #category : #'*TowerKit-ExcelInput' }
TwkPost >> crossOrdersExcelInput [
	^ Array with: #(#front 1 2 3) with: #(#left 4 5 6) with: #(#back 7 8 9) with: #(right 10 11 12)
]

{ #category : #'*TowerKit-ExcelInput' }
TwkPost >> fromExcelInputMap: aDictionary builder: aTwkBuilderForExcel [
	super fromExcelInputMap: aDictionary builder: aTwkBuilderForExcel.
	self beamMountSpan: (aDictionary at: 'beamMountIndex').	
]
