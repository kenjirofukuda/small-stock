Extension { #name : #TwkPost }

{ #category : #'*TowerKit-Magritte' }
TwkPost >> descriptionBeamMountSpan [
	<magritteDescription>
	^ MANumberDescription new
		priority: 40;
		label: '梁設置区画番号';
		accessor: #beamMountSpan;
		comment: '梁を何番の区画に設置するかを指定します';
		yourself
]

{ #category : #'*TowerKit-Magritte' }
TwkPost >> descriptionGrandSpanSize [
	<magritteDescription>
	^ MANumberDescription new
		priority: 30;
		label: '地中埋設区画数';
		accessor: #grandSpanSize;
		comment: '地中に埋設されるとなされる区間数を指定';
		yourself
]

{ #category : #'*TowerKit-Magritte' }
TwkPost >> descriptionName [
	<magritteDescription>
	^ MAStringDescription new
		priority: 10;
		label: '支柱名';
		accessor: #name;
		beRequired;
		addCondition: [ :v | v matchesRegex: '.\d+$' ] labelled: '名称は番号で終わる必要があります。';
		comment: '支柱を識別する番号を伴います';
		yourself
]

{ #category : #'*TowerKit-Magritte' }
TwkPost >> descriptionNumber [
	<magritteDescription>
	^ MANumberDescription new
		priority: 20;
		label: '支柱番号';
		accessor: #number;
		beReadonly;		
		comment: '支柱を識別する番号を伴います';
		yourself
]

{ #category : #'*TowerKit-Magritte' }
TwkPost >> descriptionSpanValues [
	"<magritteDescription>"
	^ MAToManyScalarRelationDescription new
		priority: 40;
		label: '区画深さの配列';
		accessor: #spanValues;
		comment: '深さを定義する数の集合';
		classes: { Number };
		yourself
]
