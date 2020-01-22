Class {
	#name : #DxfLayer,
	#superclass : #DxfDataGroups,
	#classVars : [
		'ColorIndexMap'
	],
	#category : #'KFDxf-Model'
}

{ #category : #'development support' }
DxfLayer class >> acadcolorsJson [
	"// AutoCAD 0-255 colors mapped with equivalents in HEX and RGB"
	"// source: http://sub-atomic.com/~moses/acadcolors.html"
	"https://gist.githubusercontent.com/kuka/f2a5a77b715531c7ae9beae8d5cbfded/raw/bf858ac0557f4b651e51804d140b157bda344629/autocadcolors.js"
^ '
[{
  "aci": 0,
  "hex": "#000000",
  "rgb": "rgb(0,0,0)"
}, {
  "aci": 1,
  "hex": "#FF0000",
  "rgb": "rgb(255,0,0)"
}, {
  "aci": 2,
  "hex": "#FFFF00",
  "rgb": "rgb(255,255,0)"
}, {
  "aci": 3,
  "hex": "#00FF00",
  "rgb": "rgb(0,255,0)"
}, {
  "aci": 4,
  "hex": "#00FFFF",
  "rgb": "rgb(0,255,255)"
}, {
  "aci": 5,
  "hex": "#0000FF",
  "rgb": "rgb(0,0,255)"
}, {
  "aci": 6,
  "hex": "#FF00FF",
  "rgb": "rgb(255,0,255)"
}, {
  "aci": 7,
  "hex": "#FFFFFF",
  "rgb": "rgb(255,255,255)"
}, {
  "aci": 8,
  "hex": "#414141",
  "rgb": "rgb(65,65,65)"
}, {
  "aci": 9,
  "hex": "#808080",
  "rgb": "rgb(128,128,128)"
}, {
  "aci": 10,
  "hex": "#FF0000",
  "rgb": "rgb(255,0,0)"
}, {
  "aci": 11,
  "hex": "#FFAAAA",
  "rgb": "rgb(255,170,170)"
}, {
  "aci": 12,
  "hex": "#BD0000",
  "rgb": "rgb(189,0,0)"
}, {
  "aci": 13,
  "hex": "#BD7E7E",
  "rgb": "rgb(189,126,126)"
}, {
  "aci": 14,
  "hex": "#810000",
  "rgb": "rgb(129,0,0)"
}, {
  "aci": 15,
  "hex": "#815656",
  "rgb": "rgb(129,86,86)"
}, {
  "aci": 16,
  "hex": "#680000",
  "rgb": "rgb(104,0,0)"
}, {
  "aci": 17,
  "hex": "#684545",
  "rgb": "rgb(104,69,69)"
}, {
  "aci": 18,
  "hex": "#4F0000",
  "rgb": "rgb(79,0,0)"
}, {
  "aci": 19,
  "hex": "#4F3535",
  "rgb": "rgb(79,53,53)"
}, {
  "aci": 20,
  "hex": "#FF3F00",
  "rgb": "rgb(255,63,0)"
}, {
  "aci": 21,
  "hex": "#FFBFAA",
  "rgb": "rgb(255,191,170)"
}, {
  "aci": 22,
  "hex": "#BD2E00",
  "rgb": "rgb(189,46,0)"
}, {
  "aci": 23,
  "hex": "#BD8D7E",
  "rgb": "rgb(189,141,126)"
}, {
  "aci": 24,
  "hex": "#811F00",
  "rgb": "rgb(129,31,0)"
}, {
  "aci": 25,
  "hex": "#816056",
  "rgb": "rgb(129,96,86)"
}, {
  "aci": 26,
  "hex": "#681900",
  "rgb": "rgb(104,25,0)"
}, {
  "aci": 27,
  "hex": "#684E45",
  "rgb": "rgb(104,78,69)"
}, {
  "aci": 28,
  "hex": "#4F1300",
  "rgb": "rgb(79,19,0)"
}, {
  "aci": 29,
  "hex": "#4F3B35",
  "rgb": "rgb(79,59,53)"
}, {
  "aci": 30,
  "hex": "#FF7F00",
  "rgb": "rgb(255,127,0)"
}, {
  "aci": 31,
  "hex": "#FFD4AA",
  "rgb": "rgb(255,212,170)"
}, {
  "aci": 32,
  "hex": "#BD5E00",
  "rgb": "rgb(189,94,0)"
}, {
  "aci": 33,
  "hex": "#BD9D7E",
  "rgb": "rgb(189,157,126)"
}, {
  "aci": 34,
  "hex": "#814000",
  "rgb": "rgb(129,64,0)"
}, {
  "aci": 35,
  "hex": "#816B56",
  "rgb": "rgb(129,107,86)"
}, {
  "aci": 36,
  "hex": "#683400",
  "rgb": "rgb(104,52,0)"
}, {
  "aci": 37,
  "hex": "#685645",
  "rgb": "rgb(104,86,69)"
}, {
  "aci": 38,
  "hex": "#4F2700",
  "rgb": "rgb(79,39,0)"
}, {
  "aci": 39,
  "hex": "#4F4235",
  "rgb": "rgb(79,66,53)"
}, {
  "aci": 40,
  "hex": "#FFBF00",
  "rgb": "rgb(255,191,0)"
}, {
  "aci": 41,
  "hex": "#FFEAAA",
  "rgb": "rgb(255,234,170)"
}, {
  "aci": 42,
  "hex": "#BD8D00",
  "rgb": "rgb(189,141,0)"
}, {
  "aci": 43,
  "hex": "#BDAD7E",
  "rgb": "rgb(189,173,126)"
}, {
  "aci": 44,
  "hex": "#816000",
  "rgb": "rgb(129,96,0)"
}, {
  "aci": 45,
  "hex": "#817656",
  "rgb": "rgb(129,118,86)"
}, {
  "aci": 46,
  "hex": "#684E00",
  "rgb": "rgb(104,78,0)"
}, {
  "aci": 47,
  "hex": "#685F45",
  "rgb": "rgb(104,95,69)"
}, {
  "aci": 48,
  "hex": "#4F3B00",
  "rgb": "rgb(79,59,0)"
}, {
  "aci": 49,
  "hex": "#4F4935",
  "rgb": "rgb(79,73,53)"
}, {
  "aci": 50,
  "hex": "#FFFF00",
  "rgb": "rgb(255,255,0)"
}, {
  "aci": 51,
  "hex": "#FFFFAA",
  "rgb": "rgb(255,255,170)"
}, {
  "aci": 52,
  "hex": "#BDBD00",
  "rgb": "rgb(189,189,0)"
}, {
  "aci": 53,
  "hex": "#BDBD7E",
  "rgb": "rgb(189,189,126)"
}, {
  "aci": 54,
  "hex": "#818100",
  "rgb": "rgb(129,129,0)"
}, {
  "aci": 55,
  "hex": "#818156",
  "rgb": "rgb(129,129,86)"
}, {
  "aci": 56,
  "hex": "#686800",
  "rgb": "rgb(104,104,0)"
}, {
  "aci": 57,
  "hex": "#686845",
  "rgb": "rgb(104,104,69)"
}, {
  "aci": 58,
  "hex": "#4F4F00",
  "rgb": "rgb(79,79,0)"
}, {
  "aci": 59,
  "hex": "#4F4F35",
  "rgb": "rgb(79,79,53)"
}, {
  "aci": 60,
  "hex": "#BFFF00",
  "rgb": "rgb(191,255,0)"
}, {
  "aci": 61,
  "hex": "#EAFFAA",
  "rgb": "rgb(234,255,170)"
}, {
  "aci": 62,
  "hex": "#8DBD00",
  "rgb": "rgb(141,189,0)"
}, {
  "aci": 63,
  "hex": "#ADBD7E",
  "rgb": "rgb(173,189,126)"
}, {
  "aci": 64,
  "hex": "#608100",
  "rgb": "rgb(96,129,0)"
}, {
  "aci": 65,
  "hex": "#768156",
  "rgb": "rgb(118,129,86)"
}, {
  "aci": 66,
  "hex": "#4E6800",
  "rgb": "rgb(78,104,0)"
}, {
  "aci": 67,
  "hex": "#5F6845",
  "rgb": "rgb(95,104,69)"
}, {
  "aci": 68,
  "hex": "#3B4F00",
  "rgb": "rgb(59,79,0)"
}, {
  "aci": 69,
  "hex": "#494F35",
  "rgb": "rgb(73,79,53)"
}, {
  "aci": 70,
  "hex": "#7FFF00",
  "rgb": "rgb(127,255,0)"
}, {
  "aci": 71,
  "hex": "#D4FFAA",
  "rgb": "rgb(212,255,170)"
}, {
  "aci": 72,
  "hex": "#5EBD00",
  "rgb": "rgb(94,189,0)"
}, {
  "aci": 73,
  "hex": "#9DBD7E",
  "rgb": "rgb(157,189,126)"
}, {
  "aci": 74,
  "hex": "#408100",
  "rgb": "rgb(64,129,0)"
}, {
  "aci": 75,
  "hex": "#6B8156",
  "rgb": "rgb(107,129,86)"
}, {
  "aci": 76,
  "hex": "#346800",
  "rgb": "rgb(52,104,0)"
}, {
  "aci": 77,
  "hex": "#566845",
  "rgb": "rgb(86,104,69)"
}, {
  "aci": 78,
  "hex": "#274F00",
  "rgb": "rgb(39,79,0)"
}, {
  "aci": 79,
  "hex": "#424F35",
  "rgb": "rgb(66,79,53)"
}, {
  "aci": 80,
  "hex": "#3FFF00",
  "rgb": "rgb(63,255,0)"
}, {
  "aci": 81,
  "hex": "#BFFFAA",
  "rgb": "rgb(191,255,170)"
}, {
  "aci": 82,
  "hex": "#2EBD00",
  "rgb": "rgb(46,189,0)"
}, {
  "aci": 83,
  "hex": "#8DBD7E",
  "rgb": "rgb(141,189,126)"
}, {
  "aci": 84,
  "hex": "#1F8100",
  "rgb": "rgb(31,129,0)"
}, {
  "aci": 85,
  "hex": "#608156",
  "rgb": "rgb(96,129,86)"
}, {
  "aci": 86,
  "hex": "#196800",
  "rgb": "rgb(25,104,0)"
}, {
  "aci": 87,
  "hex": "#4E6845",
  "rgb": "rgb(78,104,69)"
}, {
  "aci": 88,
  "hex": "#134F00",
  "rgb": "rgb(19,79,0)"
}, {
  "aci": 89,
  "hex": "#3B4F35",
  "rgb": "rgb(59,79,53)"
}, {
  "aci": 90,
  "hex": "#00FF00",
  "rgb": "rgb(0,255,0)"
}, {
  "aci": 91,
  "hex": "#AAFFAA",
  "rgb": "rgb(170,255,170)"
}, {
  "aci": 92,
  "hex": "#00BD00",
  "rgb": "rgb(0,189,0)"
}, {
  "aci": 93,
  "hex": "#7EBD7E",
  "rgb": "rgb(126,189,126)"
}, {
  "aci": 94,
  "hex": "#008100",
  "rgb": "rgb(0,129,0)"
}, {
  "aci": 95,
  "hex": "#568156",
  "rgb": "rgb(86,129,86)"
}, {
  "aci": 96,
  "hex": "#006800",
  "rgb": "rgb(0,104,0)"
}, {
  "aci": 97,
  "hex": "#456845",
  "rgb": "rgb(69,104,69)"
}, {
  "aci": 98,
  "hex": "#004F00",
  "rgb": "rgb(0,79,0)"
}, {
  "aci": 99,
  "hex": "#354F35",
  "rgb": "rgb(53,79,53)"
}, {
  "aci": 100,
  "hex": "#00FF3F",
  "rgb": "rgb(0,255,63)"
}, {
  "aci": 101,
  "hex": "#AAFFBF",
  "rgb": "rgb(170,255,191)"
}, {
  "aci": 102,
  "hex": "#00BD2E",
  "rgb": "rgb(0,189,46)"
}, {
  "aci": 103,
  "hex": "#7EBD8D",
  "rgb": "rgb(126,189,141)"
}, {
  "aci": 104,
  "hex": "#00811F",
  "rgb": "rgb(0,129,31)"
}, {
  "aci": 105,
  "hex": "#568160",
  "rgb": "rgb(86,129,96)"
}, {
  "aci": 106,
  "hex": "#006819",
  "rgb": "rgb(0,104,25)"
}, {
  "aci": 107,
  "hex": "#45684E",
  "rgb": "rgb(69,104,78)"
}, {
  "aci": 108,
  "hex": "#004F13",
  "rgb": "rgb(0,79,19)"
}, {
  "aci": 109,
  "hex": "#354F3B",
  "rgb": "rgb(53,79,59)"
}, {
  "aci": 110,
  "hex": "#00FF7F",
  "rgb": "rgb(0,255,127)"
}, {
  "aci": 111,
  "hex": "#AAFFD4",
  "rgb": "rgb(170,255,212)"
}, {
  "aci": 112,
  "hex": "#00BD5E",
  "rgb": "rgb(0,189,94)"
}, {
  "aci": 113,
  "hex": "#7EBD9D",
  "rgb": "rgb(126,189,157)"
}, {
  "aci": 114,
  "hex": "#008140",
  "rgb": "rgb(0,129,64)"
}, {
  "aci": 115,
  "hex": "#56816B",
  "rgb": "rgb(86,129,107)"
}, {
  "aci": 116,
  "hex": "#006834",
  "rgb": "rgb(0,104,52)"
}, {
  "aci": 117,
  "hex": "#456856",
  "rgb": "rgb(69,104,86)"
}, {
  "aci": 118,
  "hex": "#004F27",
  "rgb": "rgb(0,79,39)"
}, {
  "aci": 119,
  "hex": "#354F42",
  "rgb": "rgb(53,79,66)"
}, {
  "aci": 120,
  "hex": "#00FFBF",
  "rgb": "rgb(0,255,191)"
}, {
  "aci": 121,
  "hex": "#AAFFEA",
  "rgb": "rgb(170,255,234)"
}, {
  "aci": 122,
  "hex": "#00BD8D",
  "rgb": "rgb(0,189,141)"
}, {
  "aci": 123,
  "hex": "#7EBDAD",
  "rgb": "rgb(126,189,173)"
}, {
  "aci": 124,
  "hex": "#008160",
  "rgb": "rgb(0,129,96)"
}, {
  "aci": 125,
  "hex": "#568176",
  "rgb": "rgb(86,129,118)"
}, {
  "aci": 126,
  "hex": "#00684E",
  "rgb": "rgb(0,104,78)"
}, {
  "aci": 127,
  "hex": "#45685F",
  "rgb": "rgb(69,104,95)"
}, {
  "aci": 128,
  "hex": "#004F3B",
  "rgb": "rgb(0,79,59)"
}, {
  "aci": 129,
  "hex": "#354F49",
  "rgb": "rgb(53,79,73)"
}, {
  "aci": 130,
  "hex": "#00FFFF",
  "rgb": "rgb(0,255,255)"
}, {
  "aci": 131,
  "hex": "#AAFFFF",
  "rgb": "rgb(170,255,255)"
}, {
  "aci": 132,
  "hex": "#00BDBD",
  "rgb": "rgb(0,189,189)"
}, {
  "aci": 133,
  "hex": "#7EBDBD",
  "rgb": "rgb(126,189,189)"
}, {
  "aci": 134,
  "hex": "#008181",
  "rgb": "rgb(0,129,129)"
}, {
  "aci": 135,
  "hex": "#568181",
  "rgb": "rgb(86,129,129)"
}, {
  "aci": 136,
  "hex": "#006868",
  "rgb": "rgb(0,104,104)"
}, {
  "aci": 137,
  "hex": "#456868",
  "rgb": "rgb(69,104,104)"
}, {
  "aci": 138,
  "hex": "#004F4F",
  "rgb": "rgb(0,79,79)"
}, {
  "aci": 139,
  "hex": "#354F4F",
  "rgb": "rgb(53,79,79)"
}, {
  "aci": 140,
  "hex": "#00BFFF",
  "rgb": "rgb(0,191,255)"
}, {
  "aci": 141,
  "hex": "#AAEAFF",
  "rgb": "rgb(170,234,255)"
}, {
  "aci": 142,
  "hex": "#008DBD",
  "rgb": "rgb(0,141,189)"
}, {
  "aci": 143,
  "hex": "#7EADBD",
  "rgb": "rgb(126,173,189)"
}, {
  "aci": 144,
  "hex": "#006081",
  "rgb": "rgb(0,96,129)"
}, {
  "aci": 145,
  "hex": "#567681",
  "rgb": "rgb(86,118,129)"
}, {
  "aci": 146,
  "hex": "#004E68",
  "rgb": "rgb(0,78,104)"
}, {
  "aci": 147,
  "hex": "#455F68",
  "rgb": "rgb(69,95,104)"
}, {
  "aci": 148,
  "hex": "#003B4F",
  "rgb": "rgb(0,59,79)"
}, {
  "aci": 149,
  "hex": "#35494F",
  "rgb": "rgb(53,73,79)"
}, {
  "aci": 150,
  "hex": "#007FFF",
  "rgb": "rgb(0,127,255)"
}, {
  "aci": 151,
  "hex": "#AAD4FF",
  "rgb": "rgb(170,212,255)"
}, {
  "aci": 152,
  "hex": "#005EBD",
  "rgb": "rgb(0,94,189)"
}, {
  "aci": 153,
  "hex": "#7E9DBD",
  "rgb": "rgb(126,157,189)"
}, {
  "aci": 154,
  "hex": "#004081",
  "rgb": "rgb(0,64,129)"
}, {
  "aci": 155,
  "hex": "#566B81",
  "rgb": "rgb(86,107,129)"
}, {
  "aci": 156,
  "hex": "#003468",
  "rgb": "rgb(0,52,104)"
}, {
  "aci": 157,
  "hex": "#455668",
  "rgb": "rgb(69,86,104)"
}, {
  "aci": 158,
  "hex": "#00274F",
  "rgb": "rgb(0,39,79)"
}, {
  "aci": 159,
  "hex": "#35424F",
  "rgb": "rgb(53,66,79)"
}, {
  "aci": 160,
  "hex": "#003FFF",
  "rgb": "rgb(0,63,255)"
}, {
  "aci": 161,
  "hex": "#AABFFF",
  "rgb": "rgb(170,191,255)"
}, {
  "aci": 162,
  "hex": "#002EBD",
  "rgb": "rgb(0,46,189)"
}, {
  "aci": 163,
  "hex": "#7E8DBD",
  "rgb": "rgb(126,141,189)"
}, {
  "aci": 164,
  "hex": "#001F81",
  "rgb": "rgb(0,31,129)"
}, {
  "aci": 165,
  "hex": "#566081",
  "rgb": "rgb(86,96,129)"
}, {
  "aci": 166,
  "hex": "#001968",
  "rgb": "rgb(0,25,104)"
}, {
  "aci": 167,
  "hex": "#454E68",
  "rgb": "rgb(69,78,104)"
}, {
  "aci": 168,
  "hex": "#00134F",
  "rgb": "rgb(0,19,79)"
}, {
  "aci": 169,
  "hex": "#353B4F",
  "rgb": "rgb(53,59,79)"
}, {
  "aci": 170,
  "hex": "#0000FF",
  "rgb": "rgb(0,0,255)"
}, {
  "aci": 171,
  "hex": "#AAAAFF",
  "rgb": "rgb(170,170,255)"
}, {
  "aci": 172,
  "hex": "#0000BD",
  "rgb": "rgb(0,0,189)"
}, {
  "aci": 173,
  "hex": "#7E7EBD",
  "rgb": "rgb(126,126,189)"
}, {
  "aci": 174,
  "hex": "#000081",
  "rgb": "rgb(0,0,129)"
}, {
  "aci": 175,
  "hex": "#565681",
  "rgb": "rgb(86,86,129)"
}, {
  "aci": 176,
  "hex": "#000068",
  "rgb": "rgb(0,0,104)"
}, {
  "aci": 177,
  "hex": "#454568",
  "rgb": "rgb(69,69,104)"
}, {
  "aci": 178,
  "hex": "#00004F",
  "rgb": "rgb(0,0,79)"
}, {
  "aci": 179,
  "hex": "#35354F",
  "rgb": "rgb(53,53,79)"
}, {
  "aci": 180,
  "hex": "#3F00FF",
  "rgb": "rgb(63,0,255)"
}, {
  "aci": 181,
  "hex": "#BFAAFF",
  "rgb": "rgb(191,170,255)"
}, {
  "aci": 182,
  "hex": "#2E00BD",
  "rgb": "rgb(46,0,189)"
}, {
  "aci": 183,
  "hex": "#8D7EBD",
  "rgb": "rgb(141,126,189)"
}, {
  "aci": 184,
  "hex": "#1F0081",
  "rgb": "rgb(31,0,129)"
}, {
  "aci": 185,
  "hex": "#605681",
  "rgb": "rgb(96,86,129)"
}, {
  "aci": 186,
  "hex": "#190068",
  "rgb": "rgb(25,0,104)"
}, {
  "aci": 187,
  "hex": "#4E4568",
  "rgb": "rgb(78,69,104)"
}, {
  "aci": 188,
  "hex": "#13004F",
  "rgb": "rgb(19,0,79)"
}, {
  "aci": 189,
  "hex": "#3B354F",
  "rgb": "rgb(59,53,79)"
}, {
  "aci": 190,
  "hex": "#7F00FF",
  "rgb": "rgb(127,0,255)"
}, {
  "aci": 191,
  "hex": "#D4AAFF",
  "rgb": "rgb(212,170,255)"
}, {
  "aci": 192,
  "hex": "#5E00BD",
  "rgb": "rgb(94,0,189)"
}, {
  "aci": 193,
  "hex": "#9D7EBD",
  "rgb": "rgb(157,126,189)"
}, {
  "aci": 194,
  "hex": "#400081",
  "rgb": "rgb(64,0,129)"
}, {
  "aci": 195,
  "hex": "#6B5681",
  "rgb": "rgb(107,86,129)"
}, {
  "aci": 196,
  "hex": "#340068",
  "rgb": "rgb(52,0,104)"
}, {
  "aci": 197,
  "hex": "#564568",
  "rgb": "rgb(86,69,104)"
}, {
  "aci": 198,
  "hex": "#27004F",
  "rgb": "rgb(39,0,79)"
}, {
  "aci": 199,
  "hex": "#42354F",
  "rgb": "rgb(66,53,79)"
}, {
  "aci": 200,
  "hex": "#BF00FF",
  "rgb": "rgb(191,0,255)"
}, {
  "aci": 201,
  "hex": "#EAAAFF",
  "rgb": "rgb(234,170,255)"
}, {
  "aci": 202,
  "hex": "#8D00BD",
  "rgb": "rgb(141,0,189)"
}, {
  "aci": 203,
  "hex": "#AD7EBD",
  "rgb": "rgb(173,126,189)"
}, {
  "aci": 204,
  "hex": "#600081",
  "rgb": "rgb(96,0,129)"
}, {
  "aci": 205,
  "hex": "#765681",
  "rgb": "rgb(118,86,129)"
}, {
  "aci": 206,
  "hex": "#4E0068",
  "rgb": "rgb(78,0,104)"
}, {
  "aci": 207,
  "hex": "#5F4568",
  "rgb": "rgb(95,69,104)"
}, {
  "aci": 208,
  "hex": "#3B004F",
  "rgb": "rgb(59,0,79)"
}, {
  "aci": 209,
  "hex": "#49354F",
  "rgb": "rgb(73,53,79)"
}, {
  "aci": 210,
  "hex": "#FF00FF",
  "rgb": "rgb(255,0,255)"
}, {
  "aci": 211,
  "hex": "#FFAAFF",
  "rgb": "rgb(255,170,255)"
}, {
  "aci": 212,
  "hex": "#BD00BD",
  "rgb": "rgb(189,0,189)"
}, {
  "aci": 213,
  "hex": "#BD7EBD",
  "rgb": "rgb(189,126,189)"
}, {
  "aci": 214,
  "hex": "#810081",
  "rgb": "rgb(129,0,129)"
}, {
  "aci": 215,
  "hex": "#815681",
  "rgb": "rgb(129,86,129)"
}, {
  "aci": 216,
  "hex": "#680068",
  "rgb": "rgb(104,0,104)"
}, {
  "aci": 217,
  "hex": "#684568",
  "rgb": "rgb(104,69,104)"
}, {
  "aci": 218,
  "hex": "#4F004F",
  "rgb": "rgb(79,0,79)"
}, {
  "aci": 219,
  "hex": "#4F354F",
  "rgb": "rgb(79,53,79)"
}, {
  "aci": 220,
  "hex": "#FF00BF",
  "rgb": "rgb(255,0,191)"
}, {
  "aci": 221,
  "hex": "#FFAAEA",
  "rgb": "rgb(255,170,234)"
}, {
  "aci": 222,
  "hex": "#BD008D",
  "rgb": "rgb(189,0,141)"
}, {
  "aci": 223,
  "hex": "#BD7EAD",
  "rgb": "rgb(189,126,173)"
}, {
  "aci": 224,
  "hex": "#810060",
  "rgb": "rgb(129,0,96)"
}, {
  "aci": 225,
  "hex": "#815676",
  "rgb": "rgb(129,86,118)"
}, {
  "aci": 226,
  "hex": "#68004E",
  "rgb": "rgb(104,0,78)"
}, {
  "aci": 227,
  "hex": "#68455F",
  "rgb": "rgb(104,69,95)"
}, {
  "aci": 228,
  "hex": "#4F003B",
  "rgb": "rgb(79,0,59)"
}, {
  "aci": 229,
  "hex": "#4F3549",
  "rgb": "rgb(79,53,73)"
}, {
  "aci": 230,
  "hex": "#FF007F",
  "rgb": "rgb(255,0,127)"
}, {
  "aci": 231,
  "hex": "#FFAAD4",
  "rgb": "rgb(255,170,212)"
}, {
  "aci": 232,
  "hex": "#BD005E",
  "rgb": "rgb(189,0,94)"
}, {
  "aci": 233,
  "hex": "#BD7E9D",
  "rgb": "rgb(189,126,157)"
}, {
  "aci": 234,
  "hex": "#810040",
  "rgb": "rgb(129,0,64)"
}, {
  "aci": 235,
  "hex": "#81566B",
  "rgb": "rgb(129,86,107)"
}, {
  "aci": 236,
  "hex": "#680034",
  "rgb": "rgb(104,0,52)"
}, {
  "aci": 237,
  "hex": "#684556",
  "rgb": "rgb(104,69,86)"
}, {
  "aci": 238,
  "hex": "#4F0027",
  "rgb": "rgb(79,0,39)"
}, {
  "aci": 239,
  "hex": "#4F3542",
  "rgb": "rgb(79,53,66)"
}, {
  "aci": 240,
  "hex": "#FF003F",
  "rgb": "rgb(255,0,63)"
}, {
  "aci": 241,
  "hex": "#FFAABF",
  "rgb": "rgb(255,170,191)"
}, {
  "aci": 242,
  "hex": "#BD002E",
  "rgb": "rgb(189,0,46)"
}, {
  "aci": 243,
  "hex": "#BD7E8D",
  "rgb": "rgb(189,126,141)"
}, {
  "aci": 244,
  "hex": "#81001F",
  "rgb": "rgb(129,0,31)"
}, {
  "aci": 245,
  "hex": "#815660",
  "rgb": "rgb(129,86,96)"
}, {
  "aci": 246,
  "hex": "#680019",
  "rgb": "rgb(104,0,25)"
}, {
  "aci": 247,
  "hex": "#68454E",
  "rgb": "rgb(104,69,78)"
}, {
  "aci": 248,
  "hex": "#4F0013",
  "rgb": "rgb(79,0,19)"
}, {
  "aci": 249,
  "hex": "#4F353B",
  "rgb": "rgb(79,53,59)"
}, {
  "aci": 250,
  "hex": "#333333",
  "rgb": "rgb(51,51,51)"
}, {
  "aci": 251,
  "hex": "#505050",
  "rgb": "rgb(80,80,80)"
}, {
  "aci": 252,
  "hex": "#696969",
  "rgb": "rgb(105,105,105)"
}, {
  "aci": 253,
  "hex": "#828282",
  "rgb": "rgb(130,130,130)"
}, {
  "aci": 254,
  "hex": "#BEBEBE",
  "rgb": "rgb(190,190,190)"
}, {
  "aci": 255,
  "hex": "#FFFFFF",
  "rgb": "rgb(255,255,255)"
}]
'
]

{ #category : #'as yet unclassified' }
DxfLayer class >> colorDefs [
	"@see http://sub-atomic.com/~moses/acadcolors.html"
	^
	#(
	#(0 #(0 0 0))
	#(1 #(255 0 0))
	#(2 #(255 255 0))
	#(3 #(0 255 0))
	#(4 #(0 255 255))
	#(5 #(0 0 255))
	#(6 #(255 0 255))
	#(7 #(255 255 255))
	)
	
]

{ #category : #accessing }
DxfLayer class >> colorOfIndex: anIndex [
	^ (ColorIndexMap at: anIndex ifAbsent: [ Color white. ]) copy
]

{ #category : #'as yet unclassified' }
DxfLayer class >> colorStringMapJson [
	"NeoJSONWriter  toStringPretty:  DxfLayer lookupColorStringMap "
	"NeoJSONReader  fromString:  DxfLayer colorStringMapJson "
	^ '{
	"237" : "684556",
	"34" : "814000",
	"126" : "00684e",
	"86" : "196800",
	"178" : "00004f",
	"249" : "4f353b",
	"216" : "680068",
	"46" : "684e00",
	"13" : "bd7e7e",
	"98" : "004f00",
	"65" : "768156",
	"157" : "455668",
	"105" : "568160",
	"7" : "ffffff",
	"228" : "4f003b",
	"25" : "816056",
	"77" : "566845",
	"169" : "353b4f",
	"136" : "006868",
	"207" : "5f4568",
	"188" : "13004f",
	"56" : "686800",
	"148" : "003b4f",
	"115" : "56816b",
	"238" : "4f0027",
	"35" : "816b56",
	"127" : "45685f",
	"87" : "4e6845",
	"179" : "35354f",
	"217" : "684568",
	"47" : "685f45",
	"99" : "354f35",
	"106" : "006819",
	"66" : "4e6800",
	"158" : "00274f",
	"8" : "414141",
	"14" : "810000",
	"229" : "4f3549",
	"26" : "681900",
	"78" : "274f00",
	"137" : "456868",
	"208" : "3b004f",
	"189" : "3b354f",
	"57" : "686845",
	"149" : "35494f",
	"116" : "006834",
	"239" : "4f3542",
	"36" : "683400",
	"128" : "004f3b",
	"88" : "134f00",
	"218" : "4f004f",
	"48" : "4f3b00",
	"15" : "815656",
	"107" : "45684e",
	"9" : "808080",
	"159" : "35424f",
	"67" : "5f6845",
	"190" : "7f00ff",
	"27" : "684e45",
	"79" : "424f35",
	"138" : "004f4f",
	"209" : "49354f",
	"240" : "ff003f",
	"58" : "4f4f00",
	"117" : "456856",
	"37" : "685645",
	"129" : "354f49",
	"89" : "3b4f35",
	"160" : "003fff",
	"219" : "4f354f",
	"49" : "4f4935",
	"250" : "333333",
	"16" : "680000",
	"108" : "004f13",
	"68" : "3b4f00",
	"191" : "d4aaff",
	"28" : "4f1300",
	"139" : "354f4f",
	"170" : "0000ff",
	"241" : "ffaabf",
	"59" : "4f4f35",
	"118" : "004f27",
	"90" : "00ff00",
	"220" : "ff00bf",
	"38" : "4f2700",
	"161" : "aabfff",
	"180" : "3f00ff",
	"251" : "505050",
	"17" : "684545",
	"109" : "354f3b",
	"69" : "494f35",
	"140" : "00bfff",
	"192" : "5e00bd",
	"29" : "4f3b35",
	"230" : "ff007f",
	"171" : "aaaaff",
	"242" : "bd002e",
	"91" : "aaffaa",
	"0" : "000000",
	"119" : "354f42",
	"150" : "007fff",
	"221" : "ffaaea",
	"39" : "4f4235",
	"70" : "7fff00",
	"162" : "002ebd",
	"200" : "bf00ff",
	"181" : "bfaaff",
	"252" : "696969",
	"18" : "4f0000",
	"141" : "aaeaff",
	"193" : "9d7ebd",
	"231" : "ffaad4",
	"120" : "00ffbf",
	"80" : "3fff00",
	"172" : "0000bd",
	"243" : "bd7e8d",
	"210" : "ff00ff",
	"92" : "00bd00",
	"1" : "ff0000",
	"151" : "aad4ff",
	"222" : "bd008d",
	"71" : "d4ffaa",
	"163" : "7e8dbd",
	"130" : "00ffff",
	"201" : "eeaaff",
	"182" : "2e00bd",
	"253" : "828282",
	"19" : "4f3535",
	"50" : "ffff00",
	"142" : "008dbd",
	"194" : "400081",
	"232" : "bd005e",
	"121" : "aaffea",
	"81" : "bfffaa",
	"173" : "7e7ebd",
	"244" : "81001f",
	"211" : "ffaaff",
	"41" : "ffeaaa",
	"93" : "7ebd7e",
	"100" : "00ff3f",
	"2" : "ffff00",
	"152" : "005ebd",
	"60" : "bfff00",
	"223" : "bd7ead",
	"20" : "ff3f00",
	"72" : "5ebd00",
	"164" : "001f81",
	"131" : "aaffff",
	"202" : "8d00bd",
	"183" : "8d7ebd",
	"254" : "bebebe",
	"51" : "ffffaa",
	"143" : "7eadbd",
	"110" : "00ff7f",
	"195" : "6b5681",
	"233" : "bd7e9d",
	"30" : "ff7f00",
	"122" : "00bd8d",
	"82" : "2ebd00",
	"174" : "000081",
	"245" : "815660",
	"212" : "bd00bd",
	"42" : "bd8d00",
	"94" : "008100",
	"101" : "aaffbf",
	"61" : "eaffaa",
	"153" : "7e9dbd",
	"3" : "00ff00",
	"224" : "810060",
	"21" : "ffbfaa",
	"73" : "9dbd7e",
	"165" : "566081",
	"40" : "ffbf00",
	"132" : "00bdbd",
	"203" : "ad7ebd",
	"184" : "1f0081",
	"255" : "ffffff",
	"52" : "bdbd00",
	"144" : "006081",
	"111" : "aaffd4",
	"196" : "340068",
	"234" : "810040",
	"31" : "ffd4aa",
	"123" : "7ebdad",
	"83" : "8dbd7e",
	"175" : "565681",
	"246" : "680019",
	"213" : "bd7ebd",
	"43" : "bdad7e",
	"95" : "568156",
	"102" : "00bd2e",
	"62" : "8dbd00",
	"154" : "004081",
	"4" : "00ffff",
	"10" : "ff0000",
	"225" : "815676",
	"22" : "bd2e00",
	"74" : "408100",
	"166" : "001968",
	"133" : "7ebdbd",
	"204" : "600081",
	"185" : "605681",
	"53" : "bdbd7e",
	"145" : "567681",
	"112" : "00bd5e",
	"197" : "564568",
	"235" : "81566b",
	"32" : "bd5e00",
	"124" : "008160",
	"84" : "1f8100",
	"176" : "000068",
	"247" : "68454e",
	"214" : "810081",
	"44" : "816000",
	"96" : "006800",
	"103" : "7ebd8d",
	"5" : "0000ff",
	"11" : "ffaaaa",
	"155" : "566b81",
	"63" : "adbd7e",
	"226" : "68004e",
	"23" : "bd8d7e",
	"75" : "6b8156",
	"167" : "454e68",
	"134" : "008181",
	"205" : "765681",
	"186" : "190068",
	"54" : "818100",
	"146" : "004e68",
	"113" : "7ebd9d",
	"198" : "27004f",
	"236" : "680034",
	"33" : "bd9d7e",
	"125" : "568176",
	"85" : "608156",
	"177" : "454568",
	"248" : "4f0013",
	"215" : "815681",
	"45" : "817656",
	"12" : "bd0000",
	"104" : "00811f",
	"6" : "ff00ff",
	"156" : "003468",
	"64" : "608100",
	"97" : "456845",
	"227" : "68455f",
	"24" : "811f00",
	"76" : "346800",
	"168" : "00134f",
	"135" : "568181",
	"206" : "4e0068",
	"187" : "4e4568",
	"55" : "818156",
	"147" : "455f68",
	"114" : "008140",
	"199" : "42354f"
}'
]

{ #category : #'development support' }
DxfLayer class >> exploreColorMap [
	<script>
	self lookupColorMap explore.
]

{ #category : #'class initialization' }
DxfLayer class >> initialize [
	"self initialize"
	self initializeColorIndexMap. 
]

{ #category : #'as yet unclassified' }
DxfLayer class >> initializeColorIndexMap [
	ColorIndexMap := Dictionary new.
	(NeoJSONReader fromString: self colorStringMapJson)
		keysAndValuesDo: [ :key :value | 
			ColorIndexMap at: key asInteger put: (Color colorFrom: value) ]
]

{ #category : #'deprecated - no web site' }
DxfLayer class >> lookupCode1 [
	<script>
	(((Soup fromString: ('http://sub-atomic.com/~moses/acadcolors.html' asZnUrl retrieveContents ))
		 findAllTags: [ :t | t name = 'tr' ]) allButFirst: 3 ) explore.
]

{ #category : #'deprecated - no web site' }
DxfLayer class >> lookupColorMap [
	| map thElements |
	map := Dictionary new.
	thElements := ('http://sub-atomic.com/~moses/acadcolors.html' asZnUrl retrieveContents parseHTML
		allNodesSelect: [ :e | e name = 'th' ]) allButFirst: 9.
	thElements do: [ :th | map at: th contentString asInteger put: (Color colorFrom: (th attributeAt: 'bgcolor')) ].
	^ map
]

{ #category : #'deprecated - no web site' }
DxfLayer class >> lookupColorStringMap [
	| map thElements |
	map := Dictionary new.
	thElements := ('http://sub-atomic.com/~moses/acadcolors.html' asZnUrl retrieveContents parseHTML
		allNodesSelect: [ :e | e name = 'th' ]) allButFirst: 9.
	thElements do: [ :th | map at: th contentString put: (th attributeAt: 'bgcolor') ].
	^ map
]

{ #category : #'development support' }
DxfLayer class >> setupColorIndexMapByNetResource [
	<script>
	ColorIndexMap := self lookupColorMap.
]

{ #category : #accessing }
DxfLayer >> color [
	^ self class colorOfIndex: self colorNumber 
]

{ #category : #accessing }
DxfLayer >> colorNumber [
	^ self numberByNumber: 62 default: 0

]

{ #category : #'as yet unclassified' }
DxfLayer >> initializeDefaults [
	self addCode: 100 data: 'AcDbSymbolTableRecord'.
	self addCode: 100 data: 'AcDbLayerTableRecord'.
	"name"
	self setCode: 2 data: 'Untitled'.
	"mask"
	self setCode: 70 data: 0.
	"color index"
	self setCode: 62 data: 0.
	
]

{ #category : #accessing }
DxfLayer >> lineTypeName [
	^ self encodedStringByNumber: 6 default: ''

]

{ #category : #'as yet unclassified' }
DxfLayer >> lookupName [
	^ self encodedStringByNumber: 2 default: '###ERROR###'
]

{ #category : #accessing }
DxfLayer >> name [
	^ name ifNil: [ name := self lookupName ]
]

{ #category : #printing }
DxfLayer >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	self name printOn: aStream.
	aStream nextPut: $).	
]
