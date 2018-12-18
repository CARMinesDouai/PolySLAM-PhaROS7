"
This class performs the Iteratice Closest Point (ICP) algorithm.


ToDo:
- remove outliers from computation
- defined criteria for outliers and allow to change the criteria via accessors 


Public API and Key Messages

- alignPointCloud: <inputA> with: <inputB>
	this method performs the full ICP algorithm. both inputs are expected to be collections of points.
	the result (stored as 'outputA') is the transformed collection inputA. the collection inputB remains
	static. both input collections are not modified - the result is stored in a new collection.

-alignPointCloud: <inputA> withNNCollection: <inputB>
	same as above, but inputB is required to be a nearest-neighbor collection, e.g. a VMQuadtreeNode
	
- outputA
	returns the aligned point collection (a copy)
	
-tfMatrix
	returns the VMTFMatrix that transforms inputA to outputA

the remaining methods are used for debugging and manually stepping through the iterative steps of the algorithm.


"
Class {
	#name : #'VMICP_old',
	#superclass : #Object,
	#instVars : [
		'inputA',
		'nnCollection',
		'outputA',
		'matchCollection',
		'svd',
		'stepMatR',
		'stepVecT',
		'tfMatrix',
		'iterationCounter',
		'maxIterations',
		'iterationHistory',
		'matchHistory'
	],
	#category : #'PolySLAM-Core-SLAM - ICP'
}

{ #category : #'as yet unclassified' }
VMICP_old class >> rendererClass [
	^VMICP_oldRenderer.
]

{ #category : #'public - aligning' }
VMICP_old >> alignPointCollection: collectionA with: collectionB [
	"alligns collectionA with collectionB. collectionB. both collections remain unchanged and a new collection based on the transformed collectionA is returned"
	| quadtree |
	"quadtree := (VMQuadTreeNode size: 1@1 center: (collectionB anyOne))
		addAll: collectionB;
		root.
	"
	quadtree := collectionB asVMQuadTree2.
	
	self alignPointCollection: collectionA withNNCollection: quadtree.

]

{ #category : #'public - aligning' }
VMICP_old >> alignPointCollection: collectionA with: collectionB initialGuess: transform [
	"alligns collectionA with collectionB. both collections remain unchanged and a new collection based on the transformed collectionA is returned"
	| quadtree |
	"quadtree := (VMQuadTreeNode size: 1@1 center: (collectionB anyOne))
		addAll: collectionB;
		root."
	quadtree := collectionB asVMQuadTree2.
	
	self setupInputA: collectionA nnCollection: quadtree.
	
	self logCr: 'error before initialGuess=', self computeError printString.
	self applyTransform: transform to: collectionA.
	self logCr: 'error after initialGuess=', self computeError printString.
	
	"self printDebug."
	
	self iterate.

]

{ #category : #'public - aligning' }
VMICP_old >> alignPointCollection: collectionA withNNCollection: aNNCollection [
	"alligns collectionA with collectionB. collectionB. both collections remain unchanged and a new collection based on the transformed collectionA is returned"
	
	self setupInputA: collectionA nnCollection: aNNCollection.
	self iterate.

]

{ #category : #transforming }
VMICP_old >> applyStepTransformTo: dataCollection [
	"applies the transformation to the provided collection (of points) and stores the result in 'outputA'. the original collection is not modified."
	
	self logCr: '    rotation=', (VMTFMatrix r: stepMatR t: stepVecT) angle printString.
	
	"apply the step transformation from the last iteration while creating a new collection of points"
	outputA := dataCollection collect: [ :p |
		| vec |
		
		vec := p asDhbVector.
		vec := stepMatR * vec + stepVecT.
		
		vec asPoint.
	].
	
	"update the global transformation for our initial point collection"
	tfMatrix := (VMTFMatrix r: stepMatR t: stepVecT) * tfMatrix.
	
]

{ #category : #transforming }
VMICP_old >> applyTransform: aVMTFMatrix to: dataCollection [
	"applies the transformation to the provided collection (of points) and stores the result in 'outputA'. the original collection is not modified."
	
	outputA := dataCollection collect: [ :p |
		aVMTFMatrix transformPoint: p
	].
	
	"update the global transformation for our initial point collection"
	tfMatrix := aVMTFMatrix * tfMatrix.
	
]

{ #category : #converting }
VMICP_old >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #computing }
VMICP_old >> computeCentroid: collection [
	"computes the center of mass (average position over all points)"
	| point count |
	
	point := 0@0.
	count := 0.
	
	collection do: [ :obj |
		point := point + obj.
		count := count + 1.
	].
	
	(count = 0) ifTrue: [ ^point ].
	
	^ ((point x) / count) @ ((point y) / count).

]

{ #category : #computing }
VMICP_old >> computeError [
	"the stored match collection from the last iteration step contains the matches from before we
	transformed and updated outputA. therefore we have to compute the current match collection
	first."
	self computeMatchCollection: outputA withNNCollection: nnCollection.
	^matchCollection squaredError.
]

{ #category : #'privat - matching' }
VMICP_old >> computeMatchCollection: sourceCollection withNNCollection: aNNCollection [
	matchCollection := VMMatchCollection new.
	
	sourceCollection do: [ :point |
		matchCollection
			add: (VMMatchPair
				pointA: point
				pointB: (self findCorrespondingPoint: point inNNCollection: aNNCollection)
			).
	].
	
	^matchCollection.


]

{ #category : #'as yet unclassified' }
VMICP_old >> computeOutlierThreshold [
	| indexDistList medianDist rejectionDistance |
	
	indexDistList := matchCollection collectWithIndex: [ :pair :index | {index. pair squaredDistance} ].
	indexDistList := indexDistList sorted: [ :pairA :pairB | (pairA second) < (pairB second) ].
	
	medianDist := indexDistList middle second.
	rejectionDistance := medianDist * 100.
	
	^ rejectionDistance

]

{ #category : #'privat - matching' }
VMICP_old >> computeOutliers [
	"computes which pairs in 'matchCollection' are considered outliers. for debugging and visualization the selected outliers are returned in an OrderedCollection."
	| rejectionDistance outliers numOutliers |
	
	"rejectionDistance := 0.35."
	outliers := OrderedCollection new.
	
	rejectionDistance := self computeOutlierThreshold.
	
	numOutliers := 0.
	
	matchCollection do: [ :matchPair |
		(matchPair squaredDistance >= rejectionDistance) ifTrue: [
			matchPair outlier: true.
			outliers add: matchPair.
			numOutliers := numOutliers + 1.
		] ifFalse: [
			matchPair outlier: false.
		].
	].
	
	Transcript show: '    computeOutliers rejectionDistance=',
		(rejectionDistance printShowingDecimalPlaces: 3),
		', numOutliers=',
		numOutliers printString;
		cr.
	
	self logCr: '    computeOutliers rejectionDistance=',
		(rejectionDistance printShowingDecimalPlaces: 3),
		', numOutliers=',
		numOutliers printString.
	
	^outliers.

]

{ #category : #computing }
VMICP_old >> computeStepTransform: aMatchCollection [
	"the resulting transform is stored in the members 'matR' (rotation) and 'vecT' (translation)."
	| a b c d matH centA centB vecA vecB |
	
	centA := self computeCentroid: (aMatchCollection select: [ :pair | pair outlier not ] thenCollect: [ :pair | pair first ] ).
	centB := self computeCentroid: (aMatchCollection select: [ :pair | pair outlier not ] thenCollect: [ :pair | pair last ] ).
	
	a := 0.0.
	b := 0.0.
	c := 0.0.
	d := 0.0.
	
	aMatchCollection do: [ :obj |
		| vA vB |
		obj outlier ifFalse: [
			vA := obj first - centA.
			vB := obj last - centB.
			
			a := a + ( vA x * (vB x) ).
			b := b + ( vA x * (vB y) ).
			c := c + ( vA y * (vB x) ).
			d := d + ( vA y * (vB y) ).
		].
	].
	
	matH := PMMatrix rows: { { a. b. }. { c. d. } }.
	
	"svd := VMSVD2d matrix: (matH transpose)."
	svd := VMSVD2d matrix: (matH).
	stepMatR := (svd v) * ((svd u) transpose).
	"Transcript
		show: 'v='; cr; show: svd v; cr;
		show: 'u='; cr; show: svd u; cr;
		show: 'R='; cr; show: matR; cr.
	"
	
	
	((stepMatR at: 1 at: 1) sign ~= (stepMatR at: 2 at: 2) sign) ifTrue: [
		Transcript show: 'negated'; cr.
		stepMatR at: 2 at: 1 put: ((stepMatR at: 2 at: 1) negated).
		stepMatR at: 2 at: 2 put: ((stepMatR at: 2 at: 2) negated).
	].
	
	vecA := PMVector new: 2.
	vecB := PMVector new: 2.
	
	vecA at: 1 put: (centA x).
	vecA at: 2 put: (centA y).
	vecB at: 1 put: (centB x).
	vecB at: 2 put: (centB y).
	
	stepVecT := -1 * (stepMatR * vecA) + vecB.
	"vecT := stepMatR * -1.0 * vecA + vecB."

]

{ #category : #'as yet unclassified' }
VMICP_old >> createNNCollection: aCollection [
	| quadtree |
	"quadtree := (VMQuadTreeNode size: 1@1 center: (aCollection anyOne))
		addAll: aCollection;
		root.
	"
	quadtree := aCollection asVMQuadTree2.
	^quadtree.
	

]

{ #category : #'privat - matching' }
VMICP_old >> findCorrespondingPoint: point inNNCollection: collection [
	"NNCollection is a collection that allows us to find the nearest neighbor for a given point"
	^(collection findNearest: point)
		result.
]

{ #category : #accessing }
VMICP_old >> inputA [
	^inputA.
]

{ #category : #accessing }
VMICP_old >> inputA: aCollection [
	inputA := aCollection.
]

{ #category : #computing }
VMICP_old >> iterate [
	| error |
	
	iterationCounter := 0.
	
	[ iterationCounter < maxIterations ] whileTrue: [
		iterationCounter := iterationCounter + 1.
		self iterateOnce.
		error := self computeError.
		self logCr: 'ICP iteration #', iterationCounter printString, ', error=', error printString.
		
		"todo: add abort conditions
			- error too small / improvment too small
			- oscillation
			- same matching as previous iteration (will result in identity transformation)
		"
	].
]

{ #category : #computing }
VMICP_old >> iterateOnce [
	
	self computeMatchCollection: outputA withNNCollection: nnCollection.
	self computeOutliers.
	self computeStepTransform: matchCollection.
	self applyStepTransformTo: outputA.
	
	iterationHistory add: (OrderedCollection new addAll: outputA ).
	matchHistory add: matchCollection.

]

{ #category : #accessing }
VMICP_old >> iterationHistory [
	^iterationHistory.
]

{ #category : #'logging-Deprecated' }
VMICP_old >> logCr: text [
	
	"^super logCr: text."
	
]

{ #category : #accessing }
VMICP_old >> matchCollection [
	^matchCollection.
]

{ #category : #accessing }
VMICP_old >> matchCollection: aMatchCollection [
	matchCollection := aMatchCollection asMatchCollection.
]

{ #category : #accessing }
VMICP_old >> maxIterations: anInteger [
	maxIterations := anInteger.
	
]

{ #category : #accessing }
VMICP_old >> nnCollection [
	^nnCollection.
]

{ #category : #accessing }
VMICP_old >> outputA [
	^outputA.
]

{ #category : #accessing }
VMICP_old >> outputA: aCollection [
	outputA := aCollection.
]

{ #category : #'as yet unclassified' }
VMICP_old >> plot [
	| cmd process crlf inStream debugString |
	cmd := 'gnuplot -p'.
	crlf := Character cr asString, Character lf asString.
	
	process := OSSUnixSubprocess new
		shellCommand: cmd;
		redirectStdin;
		redirectStdout;
		run.
	
	inStream := process stdinStream.
	"inStream := WriteStream with: (OrderedCollection new: 100000)."
	inStream nextPutAll: 'plot ''-'''.
	
	matchHistory doWithIndex: [ :m :i |
		i > 1 ifTrue: [ inStream nextPutAll: ', ""' ].
		inStream nextPutAll: ' using 1:2 with lines'.
	].
	inStream nextPutAll: crlf.
	
	matchHistory doWithIndex: [ :m :i |
		"| data |
		data := m reduce: [ :a :b | a asString, ' ', b asString, crlf ].
		inStream 
			nextPutAll: data;
			nextPutAll: 'e', crlf."
		m doWithIndex: [ :obj :index |
			inStream
				nextPutAll: index printString;
				nextPutAll: ' ';
				nextPutAll: obj squaredDistance printString;
				nextPutAll: crlf.
		].
		inStream nextPutAll: 'e', crlf.
	].

	inStream close.
	"debugString := (inStream contents collect: [:s|s] from: 1 to: 2000) reduce: [ :a :b | a asString, b asString ]."
	1 halt.
	process waitForExit; closeAndCleanStreams.
	
]

{ #category : #printing }
VMICP_old >> printDebug [
	"prints the content of inputA and the nnCollection as well as the current tfMatrix (which is also the
	initial guess). 	this method is used to dump the initial state to Transcript, so that we can recreate
	the state in test cases (e.g. sunit tests or in the playground)."
	Transcript show: 'colA := { '.
	inputA do: [ :point |
		Transcript show: point printString, '. '.
	].
	Transcript
		show: ' } asOrderedCollection';
		cr.
	
	Transcript show: 'nnCol := { '.
	nnCollection do: [ :point |
		Transcript show: point printString, '. '.
	].
	Transcript
		show: ' } asOrderedCollection';
		cr.
	
	Transcript
		show: 'initialGuess := VMTFMatrix angle: ',
			tfMatrix angle printString,
			' translation: ',
			(tfMatrix translate at: 1) printString,
			' @ ',
			(tfMatrix translate at: 2) printString;
			cr.

	

]

{ #category : #privat }
VMICP_old >> setupInputA: aCollection nnCollection: aNNCollection [

	tfMatrix := VMTFMatrix identity.
	iterationCounter := 0.
	maxIterations := 20.
	inputA := aCollection.
	nnCollection := aNNCollection.
	outputA := inputA.
	iterationHistory := OrderedCollection new.
	matchHistory := OrderedCollection new.
	
	self logCr: 'ICP setupInput: AAA nnCollection: BBB'.
	self logCr: '    AAA size=', inputA size printString, ', nnColl. size=', nnCollection size printString.
	

]

{ #category : #accessing }
VMICP_old >> stepMatR [
	^stepMatR.
]

{ #category : #accessing }
VMICP_old >> stepMatR: aMatrix [
	stepMatR := aMatrix.
]

{ #category : #accessing }
VMICP_old >> stepVecT [
	^stepVecT.
]

{ #category : #accessing }
VMICP_old >> stepVecT: aVector [
	stepVecT := aVector.
]

{ #category : #accessing }
VMICP_old >> svd [
	^svd
]

{ #category : #accessing }
VMICP_old >> tfMatrix [
	^tfMatrix.
]

{ #category : #accessing }
VMICP_old >> tfMatrix: aVMTFMatrix [
	tfMatrix := aVMTFMatrix.
]
