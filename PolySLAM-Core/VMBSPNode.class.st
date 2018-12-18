Class {
	#name : #VMBSPNode,
	#superclass : #VMBSPBase,
	#instVars : [
		'hyperplane',
		'leftChild',
		'rightChild'
	],
	#category : #'PolySLAM-Core-Nearest Neighbor Search'
}

{ #category : #'as yet unclassified' }
VMBSPNode class >> parent: aNodeOrNil plane: aHyperplane [
	
	^(self new)
		parent: aNodeOrNil;
		hyperplane: aHyperplane;
		yourself.
]

{ #category : #'as yet unclassified' }
VMBSPNode class >> parent: aNodeOrNil plane: aHyperplane leftChild: leftLeaf rightChild: rightLeaf [
	
	^(self new)
		parent: aNodeOrNil;
		hyperplane: aHyperplane;
		leftChild: leftLeaf;
		rightChild: rightLeaf;
		yourself.
]

{ #category : #'as yet unclassified' }
VMBSPNode class >> parent: aNodeOrNil plane: aHyperplane level: level [
	
	^(self new)
		parent: aNodeOrNil;
		hyperplane: aHyperplane;
		level: level;
		yourself.
]

{ #category : #'as yet unclassified' }
VMBSPNode class >> parent: aNodeOrNil plane: aHyperplane level: level maxDepth: maxDepth [
	
	^(self new)
		parent: aNodeOrNil;
		hyperplane: aHyperplane;
		level: level;
		maxDepth: maxDepth;
		yourself.
]

{ #category : #'rendering support' }
VMBSPNode class >> rendererClass [
	^VMBSPNodeRenderer
]

{ #category : #converting }
VMBSPNode >> asCollectionOfSectors [
	| collection |
	
	collection := VMPolygonCollection new.
	
	leftChild ifNotNil: [ collection addAll: leftChild asCollectionOfSectors ].
	rightChild ifNotNil: [ collection addAll: rightChild asCollectionOfSectors ].
	
	^collection

]

{ #category : #accessing }
VMBSPNode >> bounds [
	^ leftChild bounds merge: rightChild bounds
]

{ #category : #enumerating }
VMBSPNode >> do: aBlock [
	leftChild ifNotNil: [ leftChild do: aBlock ].
	rightChild ifNotNil: [ rightChild do: aBlock ].
]

{ #category : #accessing }
VMBSPNode >> findHyperplaneFor: aLineSeg [
	
	hyperplane fuzzyPoint: aLineSeg pointA
		ifOnLeftSideDo: [
			hyperplane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ ^ leftChild findHyperplaneFor: aLineSeg ]
				ifOnRightSideDo: [ ^ hyperplane ]
				ifOnLineDo: [ ^ leftChild findHyperplaneFor: aLineSeg ]
		]
		ifOnRightSideDo: [
			hyperplane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ ^ hyperplane ]
				ifOnRightSideDo: [ ^ rightChild findHyperplaneFor: aLineSeg ]
				ifOnLineDo: [ ^ rightChild findHyperplaneFor: aLineSeg ]
		]
		ifOnLineDo: [
			hyperplane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ ^ leftChild findHyperplaneFor: aLineSeg ]
				ifOnRightSideDo: [ ^ rightChild findHyperplaneFor: aLineSeg ]
				ifOnLineDo: [ ^ hyperplane ]
		].
]

{ #category : #operations }
VMBSPNode >> findNearest: aPoint [
	"returns the closest point to 'aPoint' in a point-to-line segment manner.
	if no point is found (all leaves are empty) the return value is nil"
	| first second closestPoint closestPointSecond squareDistance |
	
	"check the side on which the point lies first"
	(hyperplane isPointOnLeftSide: aPoint)
		ifTrue: [ first := leftChild. second := rightChild. ]
		ifFalse: [ first := rightChild. second := leftChild. ].
	closestPoint := first findNearest: aPoint.
	
	"if the first side returned no result (i.e. empty leaf node), return the result from the other side immediately"
	closestPoint object
		ifNil: [ ^ second findNearest: aPoint ].
	
	"check if the resulting point from the first try is farther away from the plane then 'aPoint'.
	if so, then it is impossible to find a closer point on the other side of the plane and we can
	return immediately"
	squareDistance := hyperplane squareDistanceToPoint: closestPoint object.
	(squareDistance < (hyperplane squareDistanceToPoint: aPoint))
		ifTrue: [ ^closestPoint ].
	
	closestPointSecond := second findNearest: aPoint.
	closestPointSecond object ifNil: [ ^closestPoint ].
	
	((aPoint squaredDistanceTo: closestPoint object) > (aPoint squaredDistanceTo: closestPointSecond object))
		ifTrue: [ ^closestPointSecond ].
	
	^ closestPoint

]

{ #category : #accessing }
VMBSPNode >> findSectorByLineSeg: aLineSeg [
	| temp |
	hyperplane fuzzyPoint: aLineSeg pointA
		ifOnLeftSideDo: [
			hyperplane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ Transcript show: 'left (l-l)'; cr. ^leftChild findSectorByLineSeg: aLineSeg ]
				ifOnRightSideDo: [ Transcript show: 'nil (l-r)'; cr. ^nil ]
				ifOnLineDo:[ Transcript show: 'left(l-o)'; cr. ^leftChild findSectorByLineSeg: aLineSeg ].
		]
		ifOnRightSideDo: [
			hyperplane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ Transcript show: 'nil (r-l)'; cr. ^nil ]
				ifOnRightSideDo: [ Transcript show: 'right(r-r)'; cr. ^rightChild findSectorByLineSeg: aLineSeg ]
				ifOnLineDo:[ Transcript show: 'right(r-o)'; cr. ^rightChild findSectorByLineSeg: aLineSeg ].
		]
		ifOnLineDo:[
			Transcript show: 'online(o-o)'; cr.
			temp := rightChild findSectorByLineSeg: aLineSeg.
			temp ifNotNil: [ Transcript show: 'left tree'; cr. ^temp ].
			temp := leftChild findSectorByLineSeg: aLineSeg.
			temp ifNotNil: [ Transcript show: 'right tree'; cr. ^temp ].
			Transcript show: 'tree nil'; cr.
			^nil.
		].

]

{ #category : #accessing }
VMBSPNode >> findSectorsByLineSeg: aLineSeg [
	hyperplane fuzzyPoint: aLineSeg pointA
		ifOnLeftSideDo: [
			hyperplane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ Transcript show: 'left (l-l)'; cr. ^leftChild findSectorsByLineSeg: aLineSeg ]
				ifOnRightSideDo: [ Transcript show: 'nil (l-r)'; cr. ^{} ]
				ifOnLineDo:[ Transcript show: 'left(l-o)'; cr. ^leftChild findSectorsByLineSeg: aLineSeg ].
		]
		ifOnRightSideDo: [
			hyperplane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ Transcript show: 'nil (r-l)'; cr. ^{} ]
				ifOnRightSideDo: [ Transcript show: 'right(r-r)'; cr. ^rightChild findSectorsByLineSeg: aLineSeg ]
				ifOnLineDo:[ Transcript show: 'right(r-o)'; cr. ^rightChild findSectorsByLineSeg: aLineSeg ].
		]
		ifOnLineDo:[
			| leftResult  rightResult |
			Transcript show: 'online(o-o)'; cr.
			rightResult := rightChild findSectorsByLineSeg: aLineSeg.
			leftResult := leftChild findSectorsByLineSeg: aLineSeg.
			^(OrderedCollection new)
				addAll: leftResult;
				addAll: rightResult;
				yourself.
		].

]

{ #category : #accessing }
VMBSPNode >> hyperplane [
	^hyperplane
]

{ #category : #accessing }
VMBSPNode >> hyperplane: aHyperplane [
	hyperplane := aHyperplane asVMLine.
]

{ #category : #testing }
VMBSPNode >> ifEmpty: aBlock [
	(leftChild ifEmpty: aBlock)
		ifFalse: [ ^ true ].
	^ rightChild ifEmpty: aBlock
]

{ #category : #initialization }
VMBSPNode >> initialize [
	super initialize.
	
	leftChild := self class leafClass new.
	leftChild level: level + 1.
	leftChild parent: self.
	rightChild := self class leafClass new.
	rightChild level: level + 1.
	rightChild parent: self.
	

]

{ #category : #inserting }
VMBSPNode >> insert: aPolygon [
	| splitter |
	
	splitter := VMPolygonSplitter new.
	splitter split: aPolygon onPlane: hyperplane.
	
	"Transcript
		show: 'splitter left=', splitter leftPolygons size printString;
		show: ', right=', splitter rightPolygons size printString;
		show: ', plane=', hyperplane printString;
		cr.
	splitter leftPolygons do: [ :p |
		Transcript show: '  left: ', p printString; cr.
	].
	splitter rightPolygons do: [ :p |
		Transcript show: '  right: ', p printString; cr.
	]."
	
	splitter leftPolygons do: [ :aSector |
		leftChild := leftChild insert: aSector.
	].
	
	splitter rightPolygons do: [ :aSector |
		rightChild := rightChild insert: aSector.
	].

]

{ #category : #accessing }
VMBSPNode >> leftChild [
	^leftChild
]

{ #category : #accessing }
VMBSPNode >> leftChild: aNodeOrLeaf [
	leftChild := aNodeOrLeaf
]

{ #category : #accessing }
VMBSPNode >> level: anInteger [
	level := anInteger.
	leftChild level: anInteger + 1.
	rightChild level: anInteger + 1.
]

{ #category : #accessing }
VMBSPNode >> maxDepth: depth [
	super maxDepth: depth.
	leftChild maxDepth: depth.
	rightChild maxDepth: depth.
]

{ #category : #accessing }
VMBSPNode >> parent: aNode [
	super parent: aNode.
	
	leftChild parent: self.
	rightChild parent: self.
]

{ #category : #accessing }
VMBSPNode >> rightChild [
	^rightChild
]

{ #category : #accessing }
VMBSPNode >> rightChild: aNodeOrLeaf [
	rightChild := aNodeOrLeaf
]

{ #category : #accessing }
VMBSPNode >> sectorCount [
	^ leftChild sectorCount + rightChild sectorCount
]

{ #category : #accessing }
VMBSPNode >> size [
	^ leftChild size + rightChild size
]
