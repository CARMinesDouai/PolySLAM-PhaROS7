"
This class is derived from Rectangle, and computes  #center using float-point arithmetic, instead of integer arithmetic.
"
Class {
	#name : #VMRectangle,
	#superclass : #Rectangle,
	#category : #'PolySLAM-Core-kernel'
}

{ #category : #accessing }
VMRectangle >> center [
	"unlike in the original Rectangle, this method computes the center as floats, not integers"
	^self topLeft + self bottomRight / 2
]
