Class {
	#name : #VMExampleSimplifierLineFitting1Plotter,
	#superclass : #VMPlotter,
	#instVars : [
		'vectorChainCollection',
		'lineFittingResults'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #initialization }
VMExampleSimplifierLineFitting1Plotter >> initialize [
	super initialize.
	
	vectorChainCollection := OrderedCollection new. "empty collection by default"
	lineFittingResults := OrderedCollection new. "empty collection by default"
	
]

{ #category : #accessing }
VMExampleSimplifierLineFitting1Plotter >> lineFittingResults: lfrCollection [
	lineFittingResults := lfrCollection
]

{ #category : #plotting }
VMExampleSimplifierLineFitting1Plotter >> plotOn: aProcess [
	| rect |
	
	rect := Rectangle point: -0.5@2.5 point: 4.5@0.
	
	plotInitStream
		nextPutAll: 'set ytics (1.0, 2.0)'; crlf;
		nextPutAll: 'set yrange [0.3:2.3]'; crlf.
	
	vectorChainCollection do: [ :chain |
		self plotArrowCollection: chain.
	].

	self plotLineSegment: (lineFittingResults first lineHistory first asVMLineSegment fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	self plotLineSegment: (lineFittingResults first line asVMLineSegment fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	
	self plotLabel: 'Original Line' at: -1.83 @ 1.3.
	self plotLabel: 'Refined Line' at: -1.8 @ 1.75.

]

{ #category : #accessing }
VMExampleSimplifierLineFitting1Plotter >> vectorChainCollection: aVectorChainCollection [
	vectorChainCollection := aVectorChainCollection
]
