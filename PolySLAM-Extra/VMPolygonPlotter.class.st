Class {
	#name : #VMPolygonPlotter,
	#superclass : #VMPlotter,
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #plotting }
VMPolygonPlotter >> plotOn: aSubProcess [
	| bounds |
	bounds := model bounds.
	
	"increase the rectangle by 10% (5% in every direction)"
	range ifNil: [ range := bounds expandBy: (bounds width max: bounds height) * 0.10. ].
	
	self plotFilledPolygon: (VMPolygon fromRectangle: range) extra: 'lc rgb "#CCCCCC"'.
	self plotFilledPolygon: model extra: 'lc rgb "#FFFFFF"'.
	self plotArrowCollection: model.
]
