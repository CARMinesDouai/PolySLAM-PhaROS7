Class {
	#name : #PSTrinaryAdjacencyMatrix,
	#superclass : #PSAdjacencyMatrix,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #calculating }
PSTrinaryAdjacencyMatrix >> makeSymetric [
	"not really symetric here, just all elements whoses value = -1 are mirrored"
	|size value|
	size := self numberOfRows.
	1 to: size do:[:i| |j|
		j := i + 1.
		j to: size do:[:k|
			value := (self at:i at:k) min: (self at:k at:i).
			value = -1 ifTrue:[
				self at: i at: k put: value.
				self at: k at: i put: value.
			].
		].
	].
	^ self
	
]
