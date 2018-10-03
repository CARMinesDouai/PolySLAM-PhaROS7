Class {
	#name : #VMBSPTreePlotter,
	#superclass : #VMPlotter,
	#instVars : [
		'maxLevel',
		'bounds',
		'showHyperplanes',
		'showArrowHeads',
		'showGrid'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #'as yet unclassified' }
VMBSPTreePlotter class >> model: aBSPTree maxLevel: anInteger [
	^ (self new)
		model: aBSPTree;
		maxLevel: anInteger;
		yourself.
]

{ #category : #initialization }
VMBSPTreePlotter >> initialize [
	super initialize.
	
	maxLevel := 10000.
	showHyperplanes := true.
	showArrowHeads := true.
	showGrid := true.
]

{ #category : #accessing }
VMBSPTreePlotter >> maxLevel: anInteger [
	maxLevel := anInteger
]

{ #category : #plotting }
VMBSPTreePlotter >> plotHyperplane: node planes: lrCollection depth: depth [
	| plane |
		plane := self truncatePlane: node hyperplane asVMLineSegment on: lrCollection.
		plane
			ifNil: [Transcript show: 'warning: plane is nil'; cr.]
			ifNotNil: [
				self plotLineSegment: plane extra: 'nohead dt 2 lt rgb "#000000" notitle'.
				self plotLabel: depth printString at: plane center + (plane normal normalized * 0.1).
			].

]

{ #category : #plotting }
VMBSPTreePlotter >> plotLeaf: node [
	node isLeaf ifTrue: [
		node sector isNotNil ifTrue: [
			self plotFilledPolygon: node sector extra: 'lc rgb "#FFFFFF"'.
			showArrowHeads
				ifTrue: [ self plotArrowCollection: node sector. ]
				ifFalse: [ self plotHeadlessArrowCollection: node sector. ].
		].
	].

]

{ #category : #plotting }
VMBSPTreePlotter >> plotOn: aSubProcess [
	| lrCollection |
	
	bounds := model bounds.
	"increase the rectangle by 10% (5% in every direction)"
	bounds := bounds expandBy: (bounds width max: bounds height) * 0.05.
	
	range ifNil: [ range := bounds expandBy: (bounds width max: bounds height) * 0.05 ].
	
	self plotFilledPolygon: (VMPolygon fromRectangle: range) extra: 'lc rgb "#CCCCCC"'.
	showGrid ifTrue: [
		self plotGridFrom: range topLeft asIntegerPoint to: range bottomRight asIntegerPoint by: 1 color: Color darkGray.
		self plotGridFrom: range topLeft asIntegerPoint to: range bottomRight asIntegerPoint by: 5 color: Color black.
	].
	"self printDebug."
	
	plotInitStream
		nextPutAll: 'set xrange [', range left printString,':', range right printString,']'; crlf;
		nextPutAll: 'set yrange [', range top printString,':', range bottom printString,']'; crlf.
	
	lrCollection := VMLRCollection new.
	lrCollection left addAll: {
		VMLine pointA: bounds topRight pointB: bounds bottomRight.
		VMLine pointA: bounds bottomLeft pointB: bounds topLeft.
		VMLine pointA: bounds bottomRight pointB: bounds bottomLeft.
		VMLine pointA: bounds topLeft pointB: bounds topRight.
	}.
	self recursivePlot: model planes: lrCollection level: 0.
]

{ #category : #plotting }
VMBSPTreePlotter >> recursivePlot: node planes: lrCollection level: depth [
	| copyA copyB |
	
	depth > maxLevel ifTrue: [ ^ self ].
	
	node isLeaf ifTrue: [ ^ self plotLeaf: node ].
	
	copyA := (lrCollection copy).
	copyA left add: node hyperplane.
	copyB := (lrCollection copy).
	copyB right add: node hyperplane.
	
	self recursivePlot: node leftChild planes: copyA level: depth + 1.
	self recursivePlot: node rightChild planes: copyB level: depth + 1.
	
	showHyperplanes ifTrue: [
		self plotHyperplane: node planes: lrCollection depth: depth. ].
	
]

{ #category : #accessing }
VMBSPTreePlotter >> showArrowHeads [
	^ showArrowHeads
]

{ #category : #accessing }
VMBSPTreePlotter >> showArrowHeads: aBoolean [
	showArrowHeads := aBoolean.
]

{ #category : #accessing }
VMBSPTreePlotter >> showGrid [
	^ showGrid
]

{ #category : #accessing }
VMBSPTreePlotter >> showGrid: aBoolean [
	showGrid := aBoolean.
]

{ #category : #accessing }
VMBSPTreePlotter >> showHyperplanes [
	^showHyperplanes
]

{ #category : #accessing }
VMBSPTreePlotter >> showHyperplanes: aBoolean [
	showHyperplanes := aBoolean.
]

{ #category : #plotting }
VMBSPTreePlotter >> truncatePlane: plane on: lrCollection [
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
