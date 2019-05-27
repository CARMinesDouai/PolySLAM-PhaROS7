Class {
	#name : #PSInflateColinearProbability,
	#superclass : #PSInflateProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSInflateColinearProbability >> probability [
	| line|
	lineA chain = lineB chain ifTrue:[^ 0].
	(lineA directionVector dotProduct: (lineB directionVector)) < 0
		ifTrue:[^0].
	line := lineA value asVMLine.
	(line distanceToPoint: lineB value pointA) > self inlier
		ifTrue:[^ 0].
	(line distanceToPoint: lineB value pointB) > self inlier
		ifTrue:[^ 0].
	^ 1
]
