"
This class plots the hyperplanes of a BSP tree. polygons are not plotted, use VMPlotPolygonCollection for that.
"
Class {
	#name : #VMPlotBSPTree,
	#superclass : #VMPlotObject,
	#instVars : [
		'bounds',
		'hyperplaneSegments',
		'showHyperplanes',
		'showLabels',
		'showArrowHeads'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #computing }
VMPlotBSPTree >> computeBounds [
	plotter range
		ifNil: [
			bounds := model bounds.
			"increase the rectangle by 10% (5% in every direction)"
			bounds := bounds expandBy: (bounds width max: bounds height) * 0.05.]
		ifNotNil: [
			bounds := plotter range].

]

{ #category : #'as yet unclassified' }
VMPlotBSPTree >> initialize [
	super initialize.
	
	showHyperplanes := true.
	showArrowHeads := true.
	showLabels := true.
]

{ #category : #plotting }
VMPlotBSPTree >> plotHyperplane: node planes: lrCollection depth: depth [
	| plane |
		plane := self truncatePlane: node hyperplane asVMLineSegment on: lrCollection.
		plane
			ifNil: [Transcript show: 'warning: plane is nil'; cr.]
			ifNotNil: [
				plane length > 0 ifTrue: [
					hyperplaneSegments add: plane.
					showLabels ifTrue: [ self plotLabel: depth printString at: plane center + (plane normal normalized * 0.1). ]. ]. ].
]

{ #category : #plotting }
VMPlotBSPTree >> plotHyperplaneSegments [
	self plotVectorCollection: hyperplaneSegments extra: 'nohead dt 2 lt rgb ''#000000'' notitle'.
	Transcript show: 'hyperplanes size=', hyperplaneSegments size printString; cr.
	"self plotLineSegment: plane extra: 'nohead dt 2 lt rgb ''#000000'' notitle'."
]

{ #category : #plotting }
VMPlotBSPTree >> plotLeaf: node [
	node isLeaf ifTrue: [
		node sector isNotNil ifTrue: [
			self plotFilledPolygon: node sector extra: 'lc rgb "#FFFFFF"'.
			"showArrowHeads
				ifTrue: [ self plotArrowCollection: node sector. ]
				ifFalse: [ self plotHeadlessArrowCollection: node sector. ]."
			
			self plotVectorCollection: (node sector select: [:v | v isObstacle]) color: Color black.
		].
	].

]

{ #category : #plotting }
VMPlotBSPTree >> plotParent: parent [
	| lrCollection |
	super plotParent: parent.
	
	self computeBounds.
	hyperplaneSegments := OrderedCollection new.
	
	lrCollection := VMLRCollection new.
	lrCollection left addAll: {
		VMLine pointA: bounds topRight pointB: bounds bottomRight.
		VMLine pointA: bounds bottomLeft pointB: bounds topLeft.
		VMLine pointA: bounds bottomRight pointB: bounds bottomLeft.
		VMLine pointA: bounds topLeft pointB: bounds topRight.
	}.
	self recursivePlot: model planes: lrCollection level: model level.
	self plotHyperplaneSegments.
	

]

{ #category : #plotting }
VMPlotBSPTree >> recursivePlot: node planes: lrCollection level: depth [
	| copyA copyB |
	
	"depth > maxLevel ifTrue: [ ^ self ]."
	
	node isLeaf ifTrue: [ ^ self plotLeaf: node ].
	
	copyA := (lrCollection copy).
	copyA left add: node hyperplane.
	copyB := (lrCollection copy).
	copyB right add: node hyperplane.
	
	self recursivePlot: node leftChild planes: copyA level: depth + 1.
	self recursivePlot: node rightChild planes: copyB level: depth + 1.
	
	"showHyperplanes ifTrue: [
		self plotHyperplane: node planes: lrCollection depth: depth. ].
	"

]

{ #category : #plotting }
VMPlotBSPTree >> truncatePlane: plane on: lrCollection [
	"truncates the vector 'plane' on the hyperplanes in lrCollection.
	will return nil if the resulting vector is zero-length or completly removed.
	otherwise returns the truncated vector."
	| vec intersection tMin tMax |
	
	vec := plane fitIntoRectangle: bounds.
	tMin := 0.0. "vec's left border. 0.0 means pointA, 0.5 means half-way between pointA and pointB, etc."
	tMax := 1.0. "vec's right border. 1.0 means pointB, 0.5 means half-way between pointA and pointB, etc."
	
	lrCollection left do: [ :v |
		intersection := VMIntersection intersectLine: vec withLine: v.
		intersection isParallel ifFalse: [
			(v normal deltaAngle: vec) abs > Float halfPi
				ifTrue: [
					tMax := intersection factorT min: tMax.
				] ifFalse: [
					tMin := intersection factorT max: tMin.
				].
		].
	].
	
	lrCollection right do: [ :v |
		intersection := VMIntersection intersectLine: vec withLine: v.
		intersection isParallel ifFalse: [
			(v normal deltaAngle: vec) abs > Float halfPi
				ifTrue: [
					tMin := intersection factorT max: tMin.
				] ifFalse: [
					tMax := intersection factorT min: tMax.
				].
		].
	].
	
	(tMin >= tMax) ifTrue: [ ^ nil ].
	^ vec species
		pointA: (vec pointA + (vec direction * tMin))
		pointB: (vec pointA + (vec direction * tMax))

]
