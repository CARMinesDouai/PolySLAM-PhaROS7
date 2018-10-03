Class {
	#name : #VMExampleSimplifierLineFitting2Plotter,
	#superclass : #VMPlotter,
	#instVars : [
		'vectorChainCollection',
		'lineFittingResults'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #initialization }
VMExampleSimplifierLineFitting2Plotter >> initialize [
	super initialize.
	
	vectorChainCollection := OrderedCollection new. "empty collection by default"
	lineFittingResults := OrderedCollection new. "empty collection by default"
	
]

{ #category : #accessing }
VMExampleSimplifierLineFitting2Plotter >> lineFittingResults: lfrCollection [
	lineFittingResults := lfrCollection
]

{ #category : #plotting }
VMExampleSimplifierLineFitting2Plotter >> plotOn: aProcess [
	| rect |
	
	rect := Rectangle point: -0.5@2.5 point: 4.5@0.
	
	plotInitStream
		nextPutAll: 'set ytics (1.0, 2.0)'; crlf;
		nextPutAll: 'set yrange [0.3:2.3]'; crlf.
	
	vectorChainCollection do: [ :chain |
		self plotArrowCollection: chain.
	].

	self plotLineSegment: (lineFittingResults second lineHistory first asVMLineSegment fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	self plotLineSegment: (lineFittingResults second line asVMLineSegment fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	
	self plotLabel: 'Original Line' at: -1.3 @ 1.85.
	self plotLabel: 'Refined Line' at: -1.45 @ 2.15.

]

{ #category : #accessing }
VMExampleSimplifierLineFitting2Plotter >> vectorChainCollection: aVectorChainCollection [
	vectorChainCollection := aVectorChainCollection
]
