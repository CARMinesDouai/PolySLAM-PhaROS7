Extension { #name : #VMPoint }

{ #category : #'*PolySLAM-Pipeline-Algo' }
VMPoint >> asPoint [
	^ (self x) @ (self y)
]
