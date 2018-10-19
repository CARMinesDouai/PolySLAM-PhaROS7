Extension { #name : #PMVector }

{ #category : #'*PolySLAM-Core' }
PMVector >> asPoint [
	^Point x: (self at: 1) y: (self at: 2).
]
