Extension { #name : #Duration }

{ #category : #'*PolySLAM-Core' }
Duration >> printTotalSeconds [
	^ self totalSeconds asFloat asTimeString
]
