accessing - points
dataOutlinePoints

	"self dataBounds"

	^ GeometryUtils verticesFromBounds:
		  (Rectangle encompassing: self vertices)