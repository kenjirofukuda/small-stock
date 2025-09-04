accessing
uniqueSandboxLibraryName

	^ String streamContents: [ :s | 
		  s << 'SB'.
		  s << (Date today yyyymmdd copyReplaceAll: '-' with: '')
		  "s << (Time now print24 copyReplaceAll: ':' with: '')" ]