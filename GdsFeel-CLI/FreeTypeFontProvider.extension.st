Extension { #name : #FreeTypeFontProvider }

{ #category : #'*GdsFeel-CLI-CommandShell-extension' }
FreeTypeFontProvider >> macOSXFolderDirectories [
	"Answer the Mac OS X font folder paths.
	This needs some FFI code, but for the time being, we guess these and omit the user fonts folder"
	
	^{'/System/Library/Fonts' . '/Library/Fonts' . FileLocator home / 'Library' / 'Fonts'}
		collect: [ :each| each asFileReference ]
		thenSelect: [ :each| each exists ].
]
