"
TODO: 

inst var allPackageNames refresh if .PackageAdded  global events. 
"
Class {
	#name : #KFPackageListComponent,
	#superclass : #KFBrowserComponent,
	#instVars : [
		'allPackageNames'
	],
	#category : #'KFSeaside-Demos'
}

{ #category : #accessing }
KFPackageListComponent >> allPackageNames [
	^ allPackageNames
		ifNil: [ allPackageNames := self lookupAllPackageNames ]
]

{ #category : #accessing }
KFPackageListComponent >> lookupAllPackageNames [
	^ RPackageOrganizer default packageNames asArray sort
]

{ #category : #rendering }
KFPackageListComponent >> renderContentOn: html [
	html div
		class: 'packageList';
		with: [ html unorderedList
				class: 'expand';
				with: [ RPackageOrganizer default packageNames asArray sort
						collect: [ :pkgSymbol | 
							html listItem
								class: 'wideMarginList package';
								with: [ html image url: KFBrowserFileLibrary / #packagePng.
									html anchor
										callback: [ self browser classesOf: pkgSymbol ];
										with: pkgSymbol asString ] ] ] ]
]
