Class {
	#name : #VMExampleSimplifierLineFitting3Plotter,
	#superclass : #VMPlotter,
	#instVars : [
		'vectorChainCollection',
		'lineFittingResults'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMExampleSimplifierLineFitting3Plotter >> lineFittingResults: lfrCollection [
	lineFittingResults := lfrCollection
]

{ #category : #plotting }
VMExampleSimplifierLineFitting3Plotter >> plotOn: aProcess [
	| rect |
	
	rect := Rectangle point: -0.5@2.29 point: 4.5@0.4.
	
	plotInitStream
		nextPutAll: 'set ytics (1.0, 2.0)'; crlf;
		nextPutAll: 'set yrange [0.3:2.3]'; crlf.
	
	vectorChainCollection do: [ :chain |
		self plotArrowCollection: chain.
	].
	
	"the two lines from the line fitting process"
	self plotLineSegment: (lineFittingResults second line asVMLineSegment fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	self plotLineSegment: (lineFittingResults third line asVMLineSegment fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	
	"the two lines from the neighboring one-element-frontier-chains"
	self plotLineSegment: (VMLineSegment from: 4.1@0.35 to: 4.1@2.3) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	self plotLineSegment: ((VMLineSegment from: 0.02@0.501 to: -1.5@0.5) fitIntoRectangle: (Rectangle point: -1.8@1 point: 0.5@0)) extra: 'nohead dt 2 lt rgb "#000000" notitle'.

]

{ #category : #accessing }
VMExampleSimplifierLineFitting3Plotter >> vectorChainCollection: aVectorChainCollection [
	vectorChainCollection := aVectorChainCollection
]
