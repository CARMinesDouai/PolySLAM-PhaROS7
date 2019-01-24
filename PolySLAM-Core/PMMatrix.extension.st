Extension { #name : #PMMatrix }

{ #category : #'*PolySLAM-Core' }
PMMatrix >> indicesDo: aBlock [
	1 to: (rows size) do: [ :rowIndex |
		1 to: ((rows at: rowIndex) size) do: [ :columnIndex |
			aBlock value: rowIndex value: columnIndex.
		].
	].
]

{ #category : #'*PolySLAM-Core' }
PMMatrix class >> rows: rows columns: columns [
	"Answer a new Matrix of the given dimensions filled with random numbers"
	|a b|
	a:=	(1 to: rows) collect: [:row |b:=PMVector new:columns .
		1 to: columns do: [:column |
			b  at: column put: 0].
		b].
	^PMMatrix rows: a
]
