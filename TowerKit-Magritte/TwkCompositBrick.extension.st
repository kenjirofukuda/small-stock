Extension { #name : #TwkCompositBrick }

{ #category : #'*TowerKit-Magritte' }
TwkCompositBrick >> checkReadonly [
	name ifNil: [^ false ].
	^ self existsOnStorage.
]

{ #category : #'*TowerKit-Magritte' }
TwkCompositBrick >> descriptionName [
	<magritteDescription>
	^ MAStringDescription new
		priority: 10;
		label: 'ライブラリ名称';
		accessor: #name;
		addCondition: [ :v | v notEmpty ] labelled: '必ず指定する必要があります。';
		addCondition: [ :v | v isByteString ] labelled: '半角英数字のみが指定可能です
';
		addCondition: [ :v | v isByteString ] labelled: '半角英数字のみが指定可能です
';

		addCondition: [ :v | (self class new name: v) existsOnStorage not ] labelled: '指定したライブラリ名はすでに存在します
';

		beRequired;
		readonly: self checkReadonly;
		comment: '自動作成されるフォルダなどに採用されます。';
		yourself
]

{ #category : #'*TowerKit-Magritte' }
TwkCompositBrick >> descriptionPosts [
	"<magritteDescription>"
	^ MAToManyRelationDescription new
		priority: 40;
		label: '支柱群';
		accessor: #posts;
		comment: '支柱の集合';
		classes: { TwkPost };
		yourself
]
