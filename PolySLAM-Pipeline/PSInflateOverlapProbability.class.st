Class {
	#name : #PSInflateOverlapProbability,
	#superclass : #PSInflateColinearProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSInflateOverlapProbability >> probability [
	|pair|
	pair := self farestVertices.
	(pair value first dist: pair value second) > ((lineA length) + (lineB length))
		ifTrue:[^0].
	^ super probability 
	"(lineA isCollinearWith: lineB) ifFalse: [ ^ 0 ].
	
	((lineA hasContactWith: lineB) or: (lineB hasContactWith: lineA)) ifTrue:[^ 1].
	^ 0"
]
