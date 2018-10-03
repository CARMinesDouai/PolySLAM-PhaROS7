Class {
	#name : #VMExampleFlatAnglePlotter,
	#superclass : #VMVectorCollectionPlotter,
	#instVars : [
		'lineA',
		'lineB'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMExampleFlatAnglePlotter >> lineA: aLine [
	lineA := aLine.
]

{ #category : #accessing }
VMExampleFlatAnglePlotter >> lineB: aLine [
	lineB := aLine.
]

{ #category : #'as yet unclassified' }
VMExampleFlatAnglePlotter >> plotOn: aSubProcess [
	| rect iPoint |
	
	super plotOn: aSubProcess.
	rect := Rectangle point: -1.4@2.2 point: 4.5@0.4.
	
	lineA ifNil: [ ^self ].
	lineB ifNil: [ ^self ].
	
	self plotLineSegment: (lineA fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	self plotLineSegment: (lineB fitIntoRectangle: rect) extra: 'nohead dt 2 lt rgb "#000000" notitle'.
	
	iPoint := (VMIntersection intersectLine: lineA withLine: lineB) intersectionPoint.
	
	self plotLineSegmentFrom: iPoint + (0@0.45) to: iPoint + (0@0.02) extra: 'lt rgb "#000000" notitle'.
	self plotLabel: 'actual intersection point' at: iPoint + (-2.0@0.6).
	
	self plotLineSegmentFrom: 1.8@0.9 to: 1.8@1.38 extra: 'lt rgb "#000000" notitle'.
	self plotLabel: 'expected intersection point' at: (0.8@0.75).

]
