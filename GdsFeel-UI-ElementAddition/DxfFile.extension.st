Extension { #name : #DxfFile }

{ #category : #'*GdsFeel-UI-ElementAddition' }
DxfFile class >> fromUser [
	<script>
	| file  |
	file := GdsFeelMorphic
		chooseFullFileName: 'Choose dxf file'
		extensions: #('dxf').
	file ifNil: [^ nil].
	^ DxfFile new file: file; yourself.
	
	
]

{ #category : #'*GdsFeel-UI-ElementAddition' }
DxfFile class >> inspectFromUser [
	<script>
	self fromUser inspect.
	
]
