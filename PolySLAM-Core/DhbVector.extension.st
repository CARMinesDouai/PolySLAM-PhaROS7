Extension { #name : #DhbVector }

{ #category : #'*PolySLAM-Core' }
DhbVector >> asPoint [
	^Point x: (self at: 1) y: (self at: 2).
]
