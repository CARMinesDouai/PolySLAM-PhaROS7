Extension { #name : #Stream }

{ #category : #'*PolySLAM-Extra' }
Stream >> crlf [
	"apparently gnuplot doesn't like the carriage return character, so we just push a line feed"
	self nextPut: Character cr.
	self nextPut: Character lf.
]
