Class {
	#name : #PSJoinProbability,
	#superclass : #PSProbability,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #probability }
PSJoinProbability >> colinearityOf: aPoint with: aLine [
	|k|
	"not in the same direction"
	"calculate the linking probability with lineA is the base line"
	"first calcualte the normalized length of the gap between two line"
	((aLine value pointA inrangeOf: aPoint) | (aLine value pointB inrangeOf: aPoint)) ifTrue:[^1].
	k := (aLine value asVMLine distanceToPoint: aPoint) / (aLine length).
	^ (0 - (lamda*k)) exp
]
