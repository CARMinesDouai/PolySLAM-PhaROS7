Class {
	#name : #VMExampleCreateHyperplanePlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMExampleCreateHyperplanePlotter >> plotOn: aSubProcess [
	| planeA planeB normalVec dot helperA helperB |
	
	self plotFilledPolygon: (VMPolygon fromRectangle: range) extra: 'lc rgb "#CCCCCC"'.
	self plotFilledPolygon: model extra: 'lc rgb "#FFFFFF"'.

	model doWithIndex: [ :vec :i |
		i = 4 ifTrue: [self plotArrow: vec extra: 'lc rgb "#0000ff" lw 2.1'.]
			ifFalse: [self plotArrow: vec extra: 'lc rgb "#000000"'.]].
	
	planeA := VMLineSegment from: model fourth pointA to: model first pointA.
	planeB := VMLineSegment from: model fourth pointA to: model first pointB.
	planeA pointA: planeA pointA + (planeA direction normalized * 0.2).
	self plotLineSegment: planeA extra: 'nohead lc rgb "#000000" dt 2 notitle'.
	self plotLineSegment: planeB extra: 'nohead lc rgb "#000000" dt 2 notitle'.
	"self plotLabel: 'hyperplane A' at: 1.82@1.5.
	self plotLabel: 'hyperplane B' at: 3.26@1.5."
	self plotLabel: 'line A' at: 1.82@1.5.
	self plotLabel: 'line B' at: 3.80@1.5.
	
	"right angle marker"
	normalVec := VMLineSegment from: model fourth pointA to: (model fourth pointA + (model fourth normal normalized * 0.7)).
	self plotLineSegment: normalVec extra: 'nohead lc rgb "#000000" dt 1 notitle'.
	helperA := normalVec pointA + (normalVec direction normalized * 0.15).
	helperB := helperA + (model fourth direction normalized * 0.15).
	self plotLineSegmentFrom: helperA to: helperB extra: 'nohead lc rgb "#000000" dt 1 notitle'.
	self plotLineSegmentFrom: helperB to: helperB + (normalVec direction normalized * -0.15) extra: 'nohead lc rgb "#000000" dt 1 notitle'.
	"self plotArcFrom: normalVec direction angle to: normalVec direction angle - Float halfPi at: model fourth pointA radius: 0.2.
	dot := model fourth pointA + ((model fourth direction normalized + (normalVec direction normalized))*0.08 ).
	self plotDot: dot radius: 0.02 extra: 'lc rgb ''#000000'''."	
	
	"plot angle alpha & beta"
	self plotArcFrom: normalVec direction angle to: planeA direction angle at: model fourth pointA radius: 0.6.
	self plotArcFrom: normalVec direction angle to: planeB direction angle at: model fourth pointA radius: 0.45.
	self plotLabel: '{/Symbol a}' at: 2.74@2.18.
	self plotLabel: '{/Symbol b}' at: 3.05@2.21.
	

]
