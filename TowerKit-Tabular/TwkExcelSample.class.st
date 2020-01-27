Class {
	#name : #TwkExcelSample,
	#superclass : #Object,
	#category : #'TowerKit-Tabular'
}

{ #category : #'as yet unclassified' }
TwkExcelSample class >> chooseExcelFile [
	<script>
	^ (UIManager default  chooseFileMatching: #('*.xlsm' '*.xlsx')) .
]

{ #category : #'as yet unclassified' }
TwkExcelSample class >> example [
	 | sheet |
	sheet := self exampleWorksheet.
	"sheet explore."
	(sheet rows collect: [ :r | (sheet dataAtCol: 3 row: r) ] thenSelect: [ :each | each notNil ] )  asSet asArray sorted explore
]

{ #category : #'as yet unclassified' }
TwkExcelSample class >> exampleChooseWorkBook [
	self exampleWorkbook explore.
]

{ #category : #'as yet unclassified' }
TwkExcelSample class >> exampleFile [
	 ^ (self excelFiles select: [ :f | (f basename indexOfSubCollection:  '重量風圧') > 0 ] )  atRandom
]

{ #category : #'as yet unclassified' }
TwkExcelSample class >> exampleWorkbook [
	^  (XLSXImporter import: self chooseExcelFile ) 
]

{ #category : #'as yet unclassified' }
TwkExcelSample class >> exampleWorksheet [
	^ self exampleWorkbook worksheetNamed: '重量風圧'
]

{ #category : #'as yet unclassified' }
TwkExcelSample class >> excelFiles [
	^ self sourcePath allChildren select: [ :f | #('xlsx' 'xlsm') anySatisfy: [:s | f extension sameAs: s  ]]
]

{ #category : #'as yet unclassified' }
TwkExcelSample class >> sourcePath [
	^ FileLocator home / 'Dropbox' / 'Models' / 'E8'
]
