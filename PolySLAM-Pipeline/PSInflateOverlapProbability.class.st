Class {
	#name : #PSInflateOverlapProbability,
	#superclass : #PSInflateColinearProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSInflateOverlapProbability >> probability [
	|pair|
	pair := self farestVertices.
	(pair value first dist: pair value second) > (lineA length + (lineB length))
		ifTrue:[^0].
	^ super probability 
]
