Class {
	#name : #PSInflateColinearProbability,
	#superclass : #PSInflateProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSInflateColinearProbability >> probability [
	|pair line|
	lineA chain = lineB chain ifTrue:[^ 0].
	pair := self farestVertices.
	
	(pair value first dist: pair value second) > (lineA length + (lineB length))
		ifTrue:[^0].
	line := lineA value asVMLine.
	(line distanceToPoint: lineB value pointA) > self inlier
		ifTrue:[^ 0].
	(line distanceToPoint: lineB value pointB) > self inlier
		ifTrue:[^ 0].
	^ 1
]
