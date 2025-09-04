A GdsStreamRecord is inner class of GdsStreamFormatReader.

Instance Variables
	bytes:		<ByteArray>
	dataBytes:		<ByteArray>
	type:		<Symbol>

bytes
	- {recordKind, dataType, dataBytes}

dataBytes
	- pure data witout recordKind, dataType

type
	- #XY, #ANGLE, #MAG etc. 
