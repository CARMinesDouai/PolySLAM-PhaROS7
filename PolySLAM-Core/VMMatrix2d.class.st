Class {
	#name : #VMMatrix2d,
	#superclass : #DhbMatrix,
	#category : #'PolySLAM-Core-LinAlgebra'
}

{ #category : #creation }
VMMatrix2d class >> angle: theta [
	^(self rows: {
			{ (theta cos).  (theta sin) }.
			{ (theta sin negated).  (theta cos) }.
		})
		yourself.
	 
]

{ #category : #creation }
VMMatrix2d class >> identity [
	^(self rows: {  {1.  0}.  {0.  1}  })
		yourself.
]

{ #category : #creation }
VMMatrix2d class >> zeros [
	^(self rows: {  {0.  0}.  {0.  0}  })
		yourself.
]
